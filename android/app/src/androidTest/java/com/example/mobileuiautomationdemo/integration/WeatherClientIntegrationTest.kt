package com.example.mobileuiautomationdemo.integration

import androidx.test.ext.junit.runners.AndroidJUnit4
import com.example.mobileuiautomationdemo.WeatherClient
import kotlinx.coroutines.runBlocking
import okhttp3.mockwebserver.MockResponse
import okhttp3.mockwebserver.MockWebServer
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class WeatherClientIntegrationTest {

    private lateinit var server: MockWebServer

    @Before
    fun setUp() {
        server = MockWebServer()
        server.start()
        server.enqueue(
            MockResponse()
                .setResponseCode(200)
                .setBody(readTestResource("open-meteo-forecast-response.json"))
        )
        WeatherClient.forecastBaseUrl = server.url("/v1/forecast").toString().removeSuffix("/")
    }

    @After
    fun tearDown() {
        WeatherClient.resetForTesting()
        server.shutdown()
    }

    @Test
    fun fetchCurrentTemperatureFahrenheit_usesMockServerResponse() = runBlocking {
        val summary = WeatherClient.fetchCurrentTemperatureFahrenheit()

        assertEquals("San Francisco: 63°F", summary)
    }

    private fun readTestResource(name: String): String {
        val stream = checkNotNull(javaClass.classLoader?.getResourceAsStream(name)) {
            "Missing test resource: $name"
        }
        return stream.bufferedReader().use { it.readText() }
    }
}
