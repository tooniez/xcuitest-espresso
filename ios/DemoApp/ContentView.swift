import SwiftUI

struct ContentView: View {
    @State private var weatherStatus = "Tap Get Weather to load the forecast."
    @State private var weatherResult: String?
    @State private var isLoadingWeather = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Welcome to Mobile UI Demo")
                .accessibilityIdentifier("welcome_title")
                .font(.title2)

            Text("Example Product")
                .accessibilityIdentifier("product_name")

            Text("$9.99")
                .accessibilityIdentifier("product_price")

            Button("Get Weather") {
                Task {
                    await loadWeather()
                }
            }
            .accessibilityIdentifier("get_weather_button")
            .disabled(isLoadingWeather)

            Text(weatherStatus)
                .accessibilityIdentifier("weather_status")
                .font(.footnote)
                .foregroundStyle(.secondary)

            if let weatherResult {
                Text(weatherResult)
                    .accessibilityIdentifier("weather_result")
            }
        }
        .padding()
    }

    @MainActor
    private func loadWeather() async {
        isLoadingWeather = true
        weatherStatus = "Loading weather…"
        weatherResult = nil

        do {
            weatherResult = try await WeatherClient.fetchCurrentTemperatureFahrenheit()
            weatherStatus = "Tap Get Weather to load the forecast."
        } catch {
            weatherStatus = "Could not load weather"
        }

        isLoadingWeather = false
    }
}

#Preview {
    ContentView()
}
