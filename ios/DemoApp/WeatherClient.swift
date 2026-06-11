import Foundation

enum WeatherClientError: Error {
    case invalidResponse
    case missingTemperature
}

enum WeatherClient {
    private static let baseURL = "https://api.open-meteo.com/v1/forecast"
    private static let city = "San Francisco"
    private static let latitude = 37.7749
    private static let longitude = -122.4194

    static func fetchCurrentTemperatureFahrenheit() async throws -> String {
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "current", value: "temperature_2m"),
            URLQueryItem(name: "temperature_unit", value: "fahrenheit"),
        ]

        guard let url = components?.url else {
            throw WeatherClientError.invalidResponse
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              (200 ... 299).contains(httpResponse.statusCode) else {
            throw WeatherClientError.invalidResponse
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let current = json?["current"] as? [String: Any]
        guard let temperature = current?["temperature_2m"] as? Double else {
            throw WeatherClientError.missingTemperature
        }

        return "\(city): \(formatTemperature(temperature))°F"
    }

    private static func formatTemperature(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(value))
        }
        return String(format: "%.1f", value)
    }
}
