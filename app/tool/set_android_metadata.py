#!/usr/bin/env python3
"""Apply MenuCard branding to Flutter-generated Android files."""
from pathlib import Path

manifest = Path("android/app/src/main/AndroidManifest.xml")
if not manifest.exists():
    raise SystemExit("Flutter did not generate the Android manifest.")
manifest.write_text(
    manifest.read_text(encoding="utf-8").replace('android:label="menucard"', 'android:label="MenuCard"'),
    encoding="utf-8",
)

gradle = Path("android/app/build.gradle.kts")
if not gradle.exists():
    raise SystemExit("Flutter did not generate android/app/build.gradle.kts.")
gradle.write_text(
    gradle.read_text(encoding="utf-8").replace(
        "minSdk = flutter.minSdkVersion",
        "minSdk = 24 // Required by the selected V1 Android plugins.",
    ),
    encoding="utf-8",
)
print("MenuCard Android metadata configured.")
