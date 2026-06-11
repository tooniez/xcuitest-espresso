package com.example.mobileuiautomationdemo

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL

object WeatherClient {
    private const val BASE_URL = "https://api.open-meteo.com/v1/forecast"
    private const val CITY = "San Francisco"
    private const val LATITUDE = 37.7749
    private const val LONGITUDE = -122.4194

    suspend fun fetchCurrentTemperatureFahrenheit(): String = withContext(Dispatchers.IO) {
        val url = URL(
            "$BASE_URL?latitude=$LATITUDE&longitude=$LONGITUDE" +
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
            val current = JSONObject(body).getJSONObject("current")
            val temperature = current.getDouble("temperature_2m")
            "$CITY: ${formatTemperature(temperature)}°F"
        } finally {
            connection.disconnect()
        }
    }

    private fun formatTemperature(value: Double): String {
        return if (value % 1.0 == 0.0) {
            value.toInt().toString()
        } else {
            String.format("%.1f", value)
        }
    }
}

class WeatherException(message: String) : Exception(message)
