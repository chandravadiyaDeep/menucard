#!/usr/bin/env python3
"""Configure release signing for Flutter's generated Kotlin Gradle project."""
from pathlib import Path

gradle = Path("android/app/build.gradle.kts")
source = gradle.read_text(encoding="utf-8")

if 'create("release")' not in source:
    signing_block = """
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

"""
    if "android {" not in source:
        raise SystemExit("Could not locate the generated android block.")
    source = source.replace(
        "android {",
        """android {
    // Read signing credentials from the CI-only key.properties file.
    val keystoreProperties = java.util.Properties()
    val keystorePropertiesFile = rootProject.file("key.properties")
    if (keystorePropertiesFile.exists()) {
        java.io.FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
    }

""" + signing_block,
        1,
    )

debug_config = 'signingConfig = signingConfigs.getByName("debug")'
release_config = 'signingConfig = signingConfigs.getByName("release")'
if debug_config in source:
    source = source.replace(debug_config, release_config, 1)
elif release_config not in source:
    raise SystemExit("Could not locate the generated release build signing configuration.")

gradle.write_text(source, encoding="utf-8")
print("Production release signing configured.")
