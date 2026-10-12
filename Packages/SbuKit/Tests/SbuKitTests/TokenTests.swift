import Foundation
import SwiftUI
import Testing
import UIKit
@testable import SbuKit

/// Checks that SbuKit ships every token of `Design/tokens.json` with the right values.
struct TokenTests {
    private struct Tokens: Decodable {
        struct ColorGroup: Decodable { let tokens: [ColorToken] }
        struct ColorToken: Decodable {
            let name: String
            let value: [String: String]
        }
        struct MetricGroup: Decodable { let tokens: [MetricToken] }
        struct MetricToken: Decodable {
            let name: String
            let value: String
        }

        let color: ColorGroup
        let spacing: MetricGroup
        let radius: MetricGroup
        let stroke: MetricGroup
    }

    private let tokens: Tokens

    init() throws {
        // Packages/SbuKit/Tests/SbuKitTests/TokenTests.swift -> repository root.
        let root = URL(filePath: #filePath).deletingLastPathComponent().appending(path: "../../../..").standardized
        let data = try Data(contentsOf: root.appending(path: "Design/tokens.json"))
        tokens = try JSONDecoder().decode(Tokens.self, from: data)
    }

    @Test func everyColorTokenHasAnAsset() {
        #expect(SbuTheme.colorTokenNames == tokens.color.tokens.map(\.name))
    }

    @Test(arguments: ["light", "dark"])
    func colorAssetsMatchTokenValues(theme: String) throws {
        let traits = UITraitCollection(userInterfaceStyle: theme == "dark" ? .dark : .light)
        for token in tokens.color.tokens {
            let color = try #require(UIColor(named: token.name, in: SbuTheme.bundle, compatibleWith: traits), "Missing asset \(token.name)")
            #expect(hex(color.resolvedColor(with: traits)) == token.value[theme]?.lowercased(), "\(token.name) \(theme)")
        }
    }

    @Test func metricsMatchTokenValues() {
        for token in tokens.spacing.tokens + tokens.radius.tokens + tokens.stroke.tokens {
            let expected = token.value.hasSuffix("%")
                ? (Double(token.value.dropLast()) ?? .nan) / 100
                : Double(token.value.replacing("px", with: "")) ?? .nan
            #expect(SbuTheme.metricTokens[token.name].map(Double.init) == expected, "\(token.name)")
        }
    }

    @Test func onAccentLevelIsLightInk() throws {
        let ink = try #require(tokens.color.tokens.first { $0.name == "ink" }?.value["light"])
        #expect(hex(UIColor(SbuTheme.onAccentLevel)) == ink)
    }

    private func hex(_ color: UIColor) -> String {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let bytes = [red, green, blue].map { Int(($0 * 255).rounded()) }
        return "#" + bytes.map { String($0, radix: 16).leftPadded(to: 2) }.joined()
    }
}

private extension String {
    func leftPadded(to length: Int) -> String {
        String(repeating: "0", count: max(length - count, 0)) + self
    }
}
