package com.example.mobileuiautomationdemo

import org.junit.Assert.assertEquals
import org.junit.Assert.assertThrows
import org.junit.Test

class WeatherClientTest {

    @Test
    fun parseForecastResponse_formatsSanFranciscoTemperatureFromFixture() {
        val json = readTestResource("open-meteo-forecast-response.json")

        assertEquals("San Francisco: 63°F", WeatherClient.parseForecastResponse(json))
    }

    @Test
    fun formatTemperature_wholeNumber_omitsDecimal() {
        assertEquals("72", WeatherClient.formatTemperature(72.0))
    }

    @Test
    fun formatTemperature_fractional_keepsOneDecimal() {
        assertEquals("63.2", WeatherClient.formatTemperature(63.2))
    }

    @Test
    fun formatSummary_combinesCityAndTemperature() {
        assertEquals("San Francisco: 58°F", WeatherClient.formatSummary(58.0))
    }

    @Test
    fun parseForecastResponse_missingCurrent_throws() {
        assertThrows(Exception::class.java) {
            WeatherClient.parseForecastResponse("""{"latitude":0}""")
        }
    }

    private fun readTestResource(name: String): String {
        val stream = checkNotNull(javaClass.classLoader?.getResourceAsStream(name)) {
            "Missing test resource: $name"
        }
        return stream.bufferedReader().use { it.readText() }
    }
}
