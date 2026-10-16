import Foundation
import Network
import Observation

/// Looks for TVs on the Wi-Fi: Bonjour always, SSDP only with the multicast entitlement.
///
/// The first browse is what makes iOS ask for the Local Network permission; if the user
/// says no, `isLocalNetworkDenied` turns on and the screen explains how to allow it.
@Observable
final class TVDiscovery {
    /// TVs found so far, one per TV, sorted by name.
    private(set) var tvs: [DiscoveredTV] = []
    /// The user turned off Local Network for Sbu Remote in Settings.
    private(set) var isLocalNetworkDenied = false
    private(set) var isSearching = false

    @ObservationIgnored private var browsers: [NWBrowser] = []
    @ObservationIgnored private var group: NWConnectionGroup?
    @ObservationIgnored private var records: [String: [BonjourRecord]] = [:]
    @ObservationIgnored private var replies: [String: SSDPResponse] = [:]

    func start() {
        guard !isSearching else { return }
        isSearching = true
        for type in BonjourRecord.browsedTypes {
            startBrowser(type: type)
        }
        if NetworkFeatures.isMulticastEntitled {
            startSSDP()
        }
    }

    func stop() {
        browsers.forEach { $0.cancel() }
        browsers = []
        group?.cancel()
        group = nil
        isSearching = false
    }

    private func startBrowser(type: String) {
        let parameters = NWParameters()
        parameters.includePeerToPeer = false
        let browser = NWBrowser(for: .bonjourWithTXTRecord(type: type, domain: nil), using: parameters)
        browser.stateUpdateHandler = { [weak self] state in
            Task { @MainActor in self?.browserChanged(to: state) }
        }
        browser.browseResultsChangedHandler = { [weak self] results, _ in
            let found = results.compactMap(BonjourRecord.init(result:))
            Task { @MainActor in self?.update(type: type, records: found) }
        }
        browser.start(queue: .main)
        browsers.append(browser)
    }

    private func browserChanged(to state: NWBrowser.State) {
        switch state {
        case .waiting(let error), .failed(let error):
            if LocalNetworkAccess.isDenied(error) { isLocalNetworkDenied = true }
        case .ready:
            isLocalNetworkDenied = false
        default:
            break
        }
    }

    private func update(type: String, records found: [BonjourRecord]) {
        records[type] = found
        publish()
    }

    private func publish() {
        tvs = DiscoveredTV.merge(bonjour: records.values.flatMap(\.self), ssdp: Array(replies.values))
    }

    /// M-SEARCH to the SSDP group, once per brand. Needs the multicast entitlement (#360).
    private func startSSDP() {
        guard let multicast = try? NWMulticastGroup(for: [.hostPort(host: .init(SSDPMessage.multicastHost), port: .init(integerLiteral: SSDPMessage.port))]) else { return }
        let group = NWConnectionGroup(with: multicast, using: .udp)
        group.setReceiveHandler(maximumMessageSize: 4096, rejectOversizedMessages: true) { [weak self] _, content, _ in
            guard let content, let reply = SSDPResponse(content) else { return }
            Task { @MainActor in self?.received(reply) }
        }
        group.stateUpdateHandler = { [weak group] state in
            guard case .ready = state, let group else { return }
            for target in SSDPMessage.searchTargets.values {
                group.send(content: SSDPMessage.search(target: target)) { _ in }
            }
        }
        group.start(queue: .main)
        self.group = group
    }

    private func received(_ reply: SSDPResponse) {
        guard let key = reply.uniqueServiceName ?? reply.host else { return }
        replies[key] = reply
        publish()
    }
}

private extension BonjourRecord {
    nonisolated init?(result: NWBrowser.Result) {
        guard case .service(let name, let type, _, _) = result.endpoint else { return nil }
        var txt: [String: String] = [:]
        if case .bonjour(let record) = result.metadata {
            txt = record.dictionary
        }
        self.init(type: type.hasSuffix(".") ? String(type.dropLast()) : type, name: name, txt: txt)
    }
}
