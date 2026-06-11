package com.example.mobileuiautomationdemo

import androidx.test.espresso.Espresso.onView
import androidx.test.espresso.action.ViewActions.click
import androidx.test.espresso.assertion.ViewAssertions.matches
import androidx.test.espresso.matcher.ViewMatchers.isDisplayed
import androidx.test.espresso.matcher.ViewMatchers.withId
import androidx.test.espresso.matcher.ViewMatchers.withText
import androidx.test.ext.junit.rules.ActivityScenarioRule
import androidx.test.ext.junit.runners.AndroidJUnit4
import org.hamcrest.Matchers.containsString
import org.hamcrest.Matchers.matchesRegex
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class MainActivityWeatherEspressoTest {

    @get:Rule
    val activityRule = ActivityScenarioRule(MainActivity::class.java)

    @Test
    fun getWeather_showsSanFranciscoTemperatureInFahrenheit() {
        activityRule.scenario.onActivity { activity ->
            androidx.test.espresso.IdlingRegistry.getInstance()
                .register(activity.getWeatherRequestIdlingResource())
        }

        try {
            onView(withId(R.id.get_weather_button)).perform(click())

            onView(withId(R.id.weather_result))
                .check(matches(isDisplayed()))
                .check(matches(withText(containsString("San Francisco"))))
                .check(matches(withText(matchesRegex(".*\\d+(\\.\\d+)?°F"))))
        } finally {
            activityRule.scenario.onActivity { activity ->
                androidx.test.espresso.IdlingRegistry.getInstance()
                    .unregister(activity.getWeatherRequestIdlingResource())
            }
        }
    }
}
