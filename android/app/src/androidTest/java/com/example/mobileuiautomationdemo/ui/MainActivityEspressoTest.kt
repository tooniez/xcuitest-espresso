package com.example.mobileuiautomationdemo.ui

import androidx.test.espresso.Espresso.onView
import androidx.test.espresso.assertion.ViewAssertions.matches
import androidx.test.espresso.matcher.ViewMatchers.isDisplayed
import androidx.test.espresso.matcher.ViewMatchers.withId
import androidx.test.espresso.matcher.ViewMatchers.withText
import androidx.test.ext.junit.rules.ActivityScenarioRule
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.example.mobileuiautomationdemo.MainActivity
import com.example.mobileuiautomationdemo.R
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class MainActivityEspressoTest {

    @get:Rule
    val activityRule = ActivityScenarioRule(MainActivity::class.java)

    @Test
    fun homeScreen_showsWelcomeAndProductDetails() {
        onView(withId(R.id.welcome_title))
            .check(matches(isDisplayed()))
            .check(matches(withText("Welcome to Mobile UI Demo")))

        onView(withId(R.id.product_name))
            .check(matches(withText("Example Product")))

        onView(withId(R.id.product_price))
            .check(matches(withText("$9.99")))
    }
}
