import Foundation

enum WeatherClientError: Error {
    case invalidResponse
    case missingTemperature
}

enum WeatherClient {
    static let defaultForecastBaseURL = "https://api.open-meteo.com/v1/forecast"
    static let city = "San Francisco"
    private static let latitude = 37.7749
    private static let longitude = -122.4194

    /// Override in unit/integration tests (URLProtocol or mock base URL).
    static var forecastBaseURL = defaultForecastBaseURL

    /// Override in integration tests to route through MockURLProtocol.
    static var urlSession: URLSession = .shared

    /// Same-process tests can stub the network call.
    static var mockSummary: String?

    static func fetchCurrentTemperatureFahrenheit() async throws -> String {
        if let mockSummary {
            return mockSummary
        }
        if let launchMock = launchArgumentMockSummary() {
            return launchMock
        }

        var components = URLComponents(string: forecastBaseURL)
        components?.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "current", value: "temperature_2m"),
            URLQueryItem(name: "temperature_unit", value: "fahrenheit"),
        ]

        guard let url = components?.url else {
            throw WeatherClientError.invalidResponse
        }

        let (data, response) = try await urlSession.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              (200 ... 299).contains(httpResponse.statusCode) else {
            throw WeatherClientError.invalidResponse
        }

        return try parseForecastResponse(data: data)
    }

    static func parseForecastResponse(data: Data) throws -> String {
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let current = json?["current"] as? [String: Any]
        guard let temperature = current?["temperature_2m"] as? Double else {
            throw WeatherClientError.missingTemperature
        }
        return formatSummary(temperature: temperature)
    }

    static func formatSummary(temperature: Double) -> String {
        "\(city): \(formatTemperature(temperature))°F"
    }

    static func formatTemperature(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(value))
        }
        return String(format: "%.1f", value)
    }

    /// XCUITest runs in a separate process; pass `-MockWeather <summary>` via launch arguments.
    static func launchArgumentMockSummary() -> String? {
        let arguments = ProcessInfo.processInfo.arguments
        guard let index = arguments.firstIndex(of: "-MockWeather"),
              index + 1 < arguments.count else {
            return nil
        }
        return arguments[index + 1]
    }

    static func resetForTesting() {
        forecastBaseURL = defaultForecastBaseURL
        urlSession = .shared
        mockSummary = nil
    }
}
