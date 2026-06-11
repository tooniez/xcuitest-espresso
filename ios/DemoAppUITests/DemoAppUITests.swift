import XCTest

final class DemoAppUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testHomeScreenShowsWelcomeAndProductDetails() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Welcome to Mobile UI Demo"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Example Product"].exists)
        XCTAssertTrue(app.staticTexts["$9.99"].exists)
    }

    @MainActor
    func testGetWeatherShowsMockedSanFranciscoTemperature() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-MockWeather", "San Francisco: 63°F"]
        app.launch()

        app.buttons["get_weather_button"].tap()

        let weatherResult = app.staticTexts["weather_result"]
        XCTAssertTrue(weatherResult.waitForExistence(timeout: 5))
        XCTAssertEqual(weatherResult.label, "San Francisco: 63°F")
    }
}
