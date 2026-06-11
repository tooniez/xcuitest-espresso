package com.example.mobileuiautomationdemo

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL

object WeatherClient {
    const val DEFAULT_FORECAST_BASE_URL = "https://api.open-meteo.com/v1/forecast"
    const val CITY = "San Francisco"
    private const val LATITUDE = 37.7749
    private const val LONGITUDE = -122.4194

    /** Override in instrumentation tests (MockWebServer). */
    @Volatile
    var forecastBaseUrl: String = DEFAULT_FORECAST_BASE_URL

    /** Same-process UI tests can stub the network call. */
    @Volatile
    var mockSummary: String? = null

    suspend fun fetchCurrentTemperatureFahrenheit(): String = withContext(Dispatchers.IO) {
        mockSummary?.let { return@withContext it }

        val url = URL(
            "$forecastBaseUrl?latitude=$LATITUDE&longitude=$LONGITUDE" +
                "&current=temperature_2m&temperature_unit=fahrenheit"
        )
        val connection = (url.openConnection() as HttpURLConnection).apply {
            requestMethod = "GET"
            connectTimeout = 15_000
            readTimeout = 15_000
        }

        try {
            val responseCode = connection.responseCode
            if (responseCode != HttpURLConnection.HTTP_OK) {
                throw WeatherException("HTTP $responseCode")
            }

            val body = connection.inputStream.bufferedReader().use { it.readText() }
            parseForecastResponse(body)
        } finally {
            connection.disconnect()
        }
    }

    fun parseForecastResponse(body: String): String {
        val current = JSONObject(body).getJSONObject("current")
        val temperature = current.getDouble("temperature_2m")
        return formatSummary(temperature)
    }

    fun formatSummary(temperature: Double): String =
        "$CITY: ${formatTemperature(temperature)}°F"

    fun formatTemperature(value: Double): String {
        return if (value % 1.0 == 0.0) {
            value.toInt().toString()
        } else {
            String.format("%.1f", value)
        }
    }

    fun resetForTesting() {
        forecastBaseUrl = DEFAULT_FORECAST_BASE_URL
        mockSummary = null
    }
}

class WeatherException(message: String) : Exception(message)
