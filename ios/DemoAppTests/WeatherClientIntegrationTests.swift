import XCTest
@testable import DemoApp

final class WeatherClientIntegrationTests: XCTestCase {
    override func tearDown() {
        WeatherClient.resetForTesting()
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    func testFetchCurrentTemperatureFahrenheitUsesStubbedHTTPResponse() async throws {
        let fixture = try TestFixtures.loadJSON(named: "open-meteo-forecast-response")
        WeatherClient.forecastBaseURL = "https://example.test/v1/forecast"
        WeatherClient.urlSession = MockURLSessionFactory.makeSession()

        MockURLProtocol.requestHandler = { request in
            XCTAssertTrue(request.url?.absoluteString.contains("/v1/forecast") == true)
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, fixture)
        }

        let summary = try await WeatherClient.fetchCurrentTemperatureFahrenheit()

        XCTAssertEqual(summary, "San Francisco: 63°F")
    }
}
