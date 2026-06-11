# Reporting

## Local output

| Platform | Default location | Format |
|----------|------------------|--------|
| Android | Gradle build dir `android/app/build/reports/` | HTML (Android Tests), XML |
| iOS | `reports/ios/DemoApp.xcresult` | Xcode Result Bundle |

`run-ios.sh` writes the result bundle under `reports/ios/`. Android HTML reports are produced by Gradle after `connectedDebugAndroidTest`.

## Viewing reports

**Android HTML**

```bash
open android/app/build/reports/androidTests/connected/debug/index.html
```

**iOS Result Bundle**

```bash
open reports/ios/DemoApp.xcresult
# Or in Xcode: Report navigator after a test run
```

## CI artifacts

Upload directories in workflows for post-run inspection:

```yaml
- uses: actions/upload-artifact@v4
  if: always()
  with:
    name: android-ui-reports
    path: android/app/build/reports/

- uses: actions/upload-artifact@v4
  if: always()
  with:
    name: ios-ui-results
    path: reports/ios/
```

## Future improvements

- JUnit XML export for unified dashboards
- Allure or similar multi-platform reporter
- Slack/email notifications on main branch failures
