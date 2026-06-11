import Foundation

enum TestFixtures {
    static func loadJSON(named name: String) throws -> Data {
        let bundle = Bundle(for: BundleMarker.self)
        guard let url = bundle.url(forResource: name, withExtension: "json") else {
            throw NSError(
                domain: "TestFixtures",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Missing fixture: \(name).json"]
            )
        }
        return try Data(contentsOf: url)
    }
}

private final class BundleMarker {}
