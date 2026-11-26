# MenuCard V1 Android Release

## Automated checks
Every change to the Android app on main runs Flutter formatting, static analysis, tests and a release-mode APK build. The workflow creates an Android Gradle project using Flutter stable because Android platform scaffolding is generated during CI.

A successful main-branch APK artifact is a release-mode test candidate. Without the owner's signing keystore, it uses Flutter's generated debug signing key and is not a Play Store or production distribution build.

## Required production signing secrets
Before creating a version tag such as v1.0.0, configure these repository Actions secrets:

- ANDROID_KEYSTORE_BASE64 — base64-encoded upload/release keystore file.
- ANDROID_KEYSTORE_PASSWORD — keystore password.
- ANDROID_KEY_ALIAS — key alias.
- ANDROID_KEY_PASSWORD — key password.

The release workflow intentionally fails on a version tag if any signing secret is missing. It does not silently publish a debug-signed APK as production.

Create and retain the keystore securely using Android keytool. Keep at least two secure backups. Never commit the keystore, passwords, key.properties, or base64 material to Git. Encode the keystore file as one base64 string before saving it as the secret.

For PowerShell, an example encoding command is:

    [Convert]::ToBase64String([IO.File]::ReadAllBytes("D:\secure\menucard-upload.jks"))

Do not send the keystore or passwords in chat or commit them to this repository.

## Release process
1. Wait for the main-branch quality workflow to pass.
2. Test the APK on supported Android devices and verify create/edit/delete, persistence after force-close, backup/restore, photo export, ZIP package upload, QR scan and the customer web page.
3. Configure the four signing secrets above.
4. Create and push a version tag, for example v1.0.0.
5. The tag workflow repeats formatting, analyzer, tests, builds a signed release APK and attaches the APK and SHA-256 checksum to the GitHub Release.

## Important
A successful CI build is not a substitute for physical-device QA, Play Console policy checks, privacy review, or testing the actual static host and cache behavior. Do not describe the APK as production-ready until those checks are completed.
