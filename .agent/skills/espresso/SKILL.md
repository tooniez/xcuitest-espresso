---
name: espresso
description: Writes and extends Espresso UI tests for the Android app in this repo. Use when adding Android UI tests, fixing flaky Espresso, wiring view IDs, CountingIdlingResource for async work, or when the user mentions Espresso, androidTest, ActivityScenarioRule, or instrumentation tests.
---

# Espresso (Mobile UI Automation Demo)

## Project map

| Item | Path |
|------|------|
| App | `android/app/src/main/` |
| UI tests | `android/app/src/androidTest/java/com/example/mobileuiautomationdemo/` |
| Layouts | `android/app/src/main/res/layout/` |
| Run tests | `./scripts/run-android.sh` |
| Fixtures | `test-data/` (`products.json`, `weather.json`) |

Do **not** run builds or tests yourself — ask the user to run `./scripts/run-android.sh` after changes.

For iOS parity, use the [xctest](../xctest/SKILL.md) skill.

## Conventions

1. **Selectors** — Use `@+id/...` in layouts; query with `withId(R.id....)` in tests.
2. **No sleeps** — Espresso syncs with the main thread; register `CountingIdlingResource` for coroutines/network.
3. **Test source set** — Instrumented UI tests live in `androidTest`, not `test` (unit).
4. **Runner** — `AndroidJUnitRunner` (see `android/app/build.gradle.kts`).
5. **Package** — `com.example.mobileuiautomationdemo`.

## View IDs (home + weather)

| Element | `@+id` |
|---------|--------|
| Welcome | `welcome_title` |
| Product name | `product_name` |
| Price | `product_price` |
| Get Weather button | `get_weather_button` |
| Status line | `weather_status` |
| Result | `weather_result` |

Add in layout XML:

```xml
<Button
    android:id="@+id/get_weather_button"
    ... />
```

## Adding a test

```
Task progress:
- [ ] Add @+id in layout if missing
- [ ] Add *EspressoTest.kt in androidTest/
- [ ] Mirror scenario in XCUITest (see xctest skill) for shared flows
- [ ] Update test-data/ if assertions use shared JSON
- [ ] Ask user to run ./scripts/run-android.sh
```

### Static screen (smoke)

```kotlin
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
    }
}
```

Prefer `withId` over `withText` alone when an id exists.

### Async / network (weather pattern)

Open-Meteo HTTPS — needs network; may fail offline in CI. Note in PRs when adding similar tests.

Expose idling resource from the activity; register in test `try/finally`:

```kotlin
activityRule.scenario.onActivity { activity ->
    IdlingRegistry.getInstance()
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
        IdlingRegistry.getInstance()
            .unregister(activity.getWeatherRequestIdlingResource())
    }
}
```

Activity pattern — `increment()` before async work, `decrement()` in `finally`:

```kotlin
private val weatherRequestIdlingResource = CountingIdlingResource("weather_request")

weatherRequestIdlingResource.increment()
lifecycleScope.launch {
    try { /* work */ } finally { weatherRequestIdlingResource.decrement() }
}
```

Never `Thread.sleep`.

## Dependencies

From `android/app/build.gradle.kts`:

- `androidx.test.espresso:espresso-core:3.7.0`
- `androidx.test.espresso:espresso-idling-resource:3.7.0`
- `androidx.test.ext:junit`, `androidx.test:runner`, `androidx.test:rules`

## Naming

- **Class:** `FeatureEspressoTest`
- **Methods:** `feature_expectedOutcome` (snake_case)

## Anti-patterns

- `Thread.sleep` / fixed delays
- `withText` when `@+id` is available
- UI tests in `src/test` instead of `src/androidTest`
- Network tests in CI without documenting connectivity requirement
- Forgetting to unregister idling resources in `finally`

## Further reading

- [reference.md](reference.md) — matchers, idling checklist, troubleshooting
- [docs/test-strategy.md](../../docs/test-strategy.md)
- [docs/android-setup.md](../../docs/android-setup.md)
- [docs/troubleshooting.md](../../docs/troubleshooting.md)
