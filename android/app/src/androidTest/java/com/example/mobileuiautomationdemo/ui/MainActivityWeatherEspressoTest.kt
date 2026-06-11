package com.example.mobileuiautomationdemo.ui

import androidx.test.espresso.Espresso.onView
import androidx.test.espresso.IdlingRegistry
import androidx.test.espresso.action.ViewActions.click
import androidx.test.espresso.assertion.ViewAssertions.matches
import androidx.test.espresso.matcher.ViewMatchers.isDisplayed
import androidx.test.espresso.matcher.ViewMatchers.withId
import androidx.test.espresso.matcher.ViewMatchers.withText
import androidx.test.ext.junit.rules.ActivityScenarioRule
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.example.mobileuiautomationdemo.MainActivity
import com.example.mobileuiautomationdemo.R
import com.example.mobileuiautomationdemo.WeatherClient
import org.junit.After
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class MainActivityWeatherEspressoTest {

    @get:Rule
    val activityRule = ActivityScenarioRule(MainActivity::class.java)

    @Before
    fun setUp() {
        WeatherClient.mockSummary = "San Francisco: 63°F"
    }

    @After
    fun tearDown() {
        WeatherClient.resetForTesting()
    }

    @Test
    fun getWeather_showsMockedSanFranciscoTemperature() {
        activityRule.scenario.onActivity { activity ->
            IdlingRegistry.getInstance().register(activity.getWeatherRequestIdlingResource())
        }

        try {
            onView(withId(R.id.get_weather_button)).perform(click())

            onView(withId(R.id.weather_result))
                .check(matches(isDisplayed()))
                .check(matches(withText("San Francisco: 63°F")))
        } finally {
            activityRule.scenario.onActivity { activity ->
                IdlingRegistry.getInstance().unregister(activity.getWeatherRequestIdlingResource())
            }
        }
    }
}
