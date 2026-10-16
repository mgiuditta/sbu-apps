import Foundation

/// Sony Bravia (not Android TV) client: PIN or pre-shared key, IRCC for keys, REST for the rest.
///
/// Bravia IP control has no TLS, so pairing asks the user to confirm plain text first
/// (`TransportPolicy`), as for legacy Samsung and LG models.
final class SonyClient: TVClient {
    let tv: SavedTV
    var onDisconnect: (@MainActor () -> Void)?
    private(set) var reportedDetails: TVDetails?

    let holdsKeysNatively = false
    var supportedKeys: Set<RemoteKey> {
        codes.isEmpty ? Set(RemoteKey.allCases) : Set(RemoteKey.allCases.filter { SonyReply.code(for: $0, in: codes) != nil })
    }

    private let credentials: CredentialStore
    private var credential: TVCredential?
    private var codes: [String: String] = [:]
    private let session: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 6
        configuration.httpCookieStorage = nil
        return URLSession(configuration: configuration)
    }()

    init(tv: SavedTV, credentials: CredentialStore = .shared) {
        self.tv = tv
        self.credentials = credentials
    }

    func connect() async throws {
        guard let saved = await credentials.credential(for: tv.id), saved.cookie != nil || saved.preSharedKey != nil else {
            throw TVClientError.notPaired
        }
        credential = saved
        if saved.cookie != nil {
            // Renews the two-week cookie; a 401 means the TV forgot Sbu Remote.
            let (_, response) = try await post(.accessControl, SonyRequest.register)
            if let cookie = cookie(from: response), cookie != saved.cookie {
                credential?.cookie = cookie
                if let credential { try? await credentials.save(credential, for: tv.id) }
            }
        }
        let (data, _) = try await post(.system, SonyRequest.remoteControllerInfo)
        codes = SonyReply(data)?.remoteCodes ?? [:]
    }

    func startPairing(allowingPlain: Bool) async throws -> PairingStep {
        guard allowingPlain else { throw TVClientError.needsPlainConfirmation }
        credential = nil
        let (_, response) = try await post(.accessControl, SonyRequest.register, authenticated: false, allowUnauthorized: true)
        if response.statusCode == 200, let cookie = cookie(from: response) {
            try await finish(with: TVCredential(cookie: cookie, requiresSecure: false))
            return .paired
        }
        return .code(length: 4, isHexadecimal: false)
    }

    func finishPairing(code: String) async throws {
        var request = try makeRequest(.accessControl, SonyRequest.register)
        request.setValue(SonyRequest.pinAuthorization(code), forHTTPHeaderField: "Authorization")
        let response = try await perform(request)
        guard response.1.statusCode == 200, let cookie = cookie(from: response.1) else { throw TVClientError.rejected }
        try await finish(with: TVCredential(cookie: cookie, requiresSecure: false))
    }

    /// Pairs with the pre-shared key set on the TV under Controllo IP, instead of a PIN.
    func pair(preSharedKey: String) async throws {
        let key = preSharedKey.trimmingCharacters(in: .whitespaces)
        guard !key.isEmpty else { throw TVClientError.rejected }
        credential = TVCredential(preSharedKey: key, requiresSecure: false)
        do {
            try await finish(with: TVCredential(preSharedKey: key, requiresSecure: false))
        } catch TVClientError.notPaired {
            throw TVClientError.rejected
        }
    }

    func disconnect() {
        codes = [:]
    }

    func send(_ key: RemoteKey, _ action: KeyAction) async throws {
        guard action == .click else { return }
        guard let code = SonyReply.code(for: key, in: codes) else { throw TVClientError.unsupported }
        guard let url = SonyRequest.irccURL(host: tv.host) else { throw TVClientError.unreachable }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = SonyRequest.ircc(code)
        request.setValue("text/xml; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue(SonyRequest.irccAction, forHTTPHeaderField: "SOAPACTION")
        authenticate(&request)
        let (_, response) = try await perform(request)
        try check(response)
    }

    func sendText(_ text: String) async throws {
        _ = try await post(.appControl, SonyRequest.text(text))
    }

    func submitText() async throws {
        try await send(.select, .click)
    }

    func apps() async throws -> [TVShortcut] {
        let (data, _) = try await post(.appControl, SonyRequest.applications)
        return SonyReply(data)?.applications ?? []
    }

    func launch(_ app: TVShortcut) async throws {
        _ = try await post(.appControl, SonyRequest.launch(uri: app.id))
    }

    func inputs() async throws -> [TVShortcut] {
        let (data, _) = try await post(.avContent, SonyRequest.inputs)
        return SonyReply(data)?.inputs ?? []
    }

    func switchInput(_ input: TVShortcut) async throws {
        _ = try await post(.avContent, SonyRequest.switchInput(uri: input.id))
    }

    /// Works when "Avvio remoto" is on in the TV's network settings.
    func powerOn() async throws {
        if credential == nil { credential = await credentials.credential(for: tv.id) }
        _ = try await post(.system, SonyRequest.powerOn)
    }

    // MARK: - HTTP

    private func finish(with credential: TVCredential) async throws {
        self.credential = credential
        let (data, _) = try await post(.system, SonyRequest.remoteControllerInfo)
        codes = SonyReply(data)?.remoteCodes ?? [:]
        try await credentials.save(credential, for: tv.id)
        if let (info, _) = try? await post(.system, SonyRequest.systemInformation) {
            reportedDetails = SonyReply(info)?.systemInformation
        }
    }

    private func makeRequest(_ service: SonyRequest.Service, _ body: Data) throws -> URLRequest {
        guard let url = SonyRequest.url(host: tv.host, service: service) else { throw TVClientError.unreachable }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }

    private func post(_ service: SonyRequest.Service, _ body: Data, authenticated: Bool = true, allowUnauthorized: Bool = false) async throws -> (Data, HTTPURLResponse) {
        var request = try makeRequest(service, body)
        if authenticated { authenticate(&request) }
        let result = try await perform(request)
        if !allowUnauthorized { try check(result.1) }
        return result
    }

    private func authenticate(_ request: inout URLRequest) {
        if let key = credential?.preSharedKey {
            request.setValue(key, forHTTPHeaderField: "X-Auth-PSK")
        } else if let cookie = credential?.cookie {
            request.setValue(cookie, forHTTPHeaderField: "Cookie")
        }
    }

    private func perform(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw TVClientError.unexpectedReply }
            return (data, http)
        } catch let error as TVClientError {
            throw error
        } catch {
            throw TVClientError.unreachable
        }
    }

    private func check(_ response: HTTPURLResponse) throws {
        switch response.statusCode {
        case 200: return
        case 401, 403: throw TVClientError.notPaired
        default: throw TVClientError.unexpectedReply
        }
    }

    private func cookie(from response: HTTPURLResponse) -> String? {
        (response.value(forHTTPHeaderField: "Set-Cookie")).flatMap(SonyRequest.authCookie(fromSetCookie:))
    }
}
