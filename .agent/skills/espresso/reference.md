# Espresso Reference

## Common matchers

```kotlin
import androidx.test.espresso.Espresso.onView
import androidx.test.espresso.action.ViewActions.click
import androidx.test.espresso.assertion.ViewAssertions.matches
import androidx.test.espresso.matcher.ViewMatchers.*

onView(withId(R.id.product_name))
    .check(matches(withText("Example Product")))

onView(withId(R.id.weather_result))
    .check(matches(isDisplayed()))
    .check(matches(withText(containsString("San Francisco"))))

import org.hamcrest.Matchers.matchesRegex
onView(withId(R.id.weather_result))
    .check(matches(withText(matchesRegex(".*\\d+(\\.\\d+)?°F"))))
```

## Idling resource checklist

1. Create `CountingIdlingResource("unique_name")` in activity or injectable helper.
2. `increment()` before async work; `decrement()` in `finally`.
3. Test: register via `IdlingRegistry` before actions, unregister in `finally`.
4. Dependency: `androidx.test.espresso:espresso-idling-resource` (in `build.gradle.kts`).

## test-data

`test-data/products.json` — home screen asserts `name` and `$9.99`. For data-driven tests, load from `androidTest` assets or raw resources; document the path in the test class.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| Element not found | Verify `@+id` in layout; confirm `ActivityScenarioRule` launches correct activity |
| Flaky after tap | Register `CountingIdlingResource` for coroutines/network |
| Idling resource timeout | Ensure every `increment()` has matching `decrement()` in all paths |
| Fails in CI only | Weather tests need internet; emulator must be running |
| Project out of sync | `./scripts/scaffold-android.sh` |

## CI

`github/workflows/android-ui-tests.yml` → `./scripts/run-android.sh`
