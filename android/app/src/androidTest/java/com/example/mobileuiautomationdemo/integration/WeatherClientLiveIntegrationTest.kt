package com.example.mobileuiautomationdemo.integration

import androidx.test.ext.junit.runners.AndroidJUnit4
import com.example.mobileuiautomationdemo.WeatherClient
import kotlinx.coroutines.runBlocking
import org.junit.After
import org.junit.Assert.assertTrue
import org.junit.Ignore
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Hits the real Open-Meteo API. Run locally when demoing Charles Proxy; skipped in CI.
 */
@RunWith(AndroidJUnit4::class)
class WeatherClientLiveIntegrationTest {

    @After
    fun tearDown() {
        WeatherClient.resetForTesting()
    }

    @Ignore("Requires network — run manually for Charles Proxy demos")
    @Test
    fun fetchCurrentTemperatureFahrenheit_hitsOpenMeteo() = runBlocking {
        val summary = WeatherClient.fetchCurrentTemperatureFahrenheit()

        assertTrue(summary.contains("San Francisco"))
        assertTrue(summary.contains("°F"))
    }
}
