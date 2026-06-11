package com.example.mobileuiautomationdemo

import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import androidx.test.espresso.idling.CountingIdlingResource
import kotlinx.coroutines.launch

class MainActivity : AppCompatActivity() {

    private val weatherRequestIdlingResource = CountingIdlingResource("weather_request")

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val weatherButton = findViewById<Button>(R.id.get_weather_button)
        val weatherStatus = findViewById<TextView>(R.id.weather_status)
        val weatherResult = findViewById<TextView>(R.id.weather_result)

        weatherButton.setOnClickListener {
            weatherRequestIdlingResource.increment()
            weatherStatus.setText(R.string.weather_status_loading)
            weatherResult.visibility = View.GONE

            lifecycleScope.launch {
                try {
                    val summary = WeatherClient.fetchCurrentTemperatureFahrenheit()
                    weatherResult.text = summary
                    weatherResult.visibility = View.VISIBLE
                    weatherStatus.setText(R.string.weather_status_idle)
                } catch (_: Exception) {
                    weatherStatus.setText(R.string.weather_status_error)
                } finally {
                    weatherRequestIdlingResource.decrement()
                }
            }
        }
    }

    fun getWeatherRequestIdlingResource(): CountingIdlingResource = weatherRequestIdlingResource
}
