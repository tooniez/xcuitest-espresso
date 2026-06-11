import XCTest
@testable import DemoApp

final class WeatherClientTests: XCTestCase {
    override func tearDown() {
        WeatherClient.resetForTesting()
        super.tearDown()
    }

    func testParseForecastResponseFormatsSanFranciscoTemperatureFromFixture() throws {
        let data = try TestFixtures.loadJSON(named: "open-meteo-forecast-response")

        let summary = try WeatherClient.parseForecastResponse(data: data)

        XCTAssertEqual(summary, "San Francisco: 63°F")
    }

    func testFormatTemperatureWholeNumberOmitsDecimal() {
        XCTAssertEqual(WeatherClient.formatTemperature(72), "72")
    }

    func testFormatTemperatureFractionalKeepsOneDecimal() {
        XCTAssertEqual(WeatherClient.formatTemperature(63.2), "63.2")
    }

    func testFormatSummaryCombinesCityAndTemperature() {
        XCTAssertEqual(WeatherClient.formatSummary(temperature: 58), "San Francisco: 58°F")
    }

    func testParseForecastResponseMissingCurrentThrows() {
        let data = Data("{\"latitude\":0}".utf8)

        XCTAssertThrowsError(try WeatherClient.parseForecastResponse(data: data)) { error in
            XCTAssertEqual(error as? WeatherClientError, .missingTemperature)
        }
    }
}
