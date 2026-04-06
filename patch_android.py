import os, re

def patch_file(path, regex, replacement):
    if os.path.exists(path):
        with open(path, "r") as f: content = f.read()
        new_content = re.sub(regex, replacement, content)
        if new_content != content:
            with open(path, "w") as f: f.write(new_content)
            print(f"✅ Patched {path}")
        else:
            print(f"ℹ️ No change needed for {path}")

# 1. Patch Root build.gradle
for p in ["android/build.gradle", "android/build.gradle.kts"]:
    patch_file(p, r"ext\.kotlin_version\s*=\s*['\"].*?['\"]", "ext.kotlin_version = '1.9.22'")
    patch_file(p, r"com\.android\.tools\.build:gradle:[^'\"]*", "com.android.tools.build:gradle:8.0.2")
    patch_file(p, r'id\("org\.jetbrains\.kotlin\.android"\) version "[^"]*"', 'id("org.jetbrains.kotlin.android") version "1.9.22"')

# 2. Patch Gradle Wrapper
patch_file("android/gradle/wrapper/gradle-wrapper.properties", r"distributionUrl=.*", "distributionUrl=https\\://services.gradle.org/distributions/gradle-8.0-all.zip")

# 3. Patch App build.gradle
for p in ["android/app/build.gradle", "android/app/build.gradle.kts"]:
    if not os.path.exists(p): continue
    # Enforce SDK versions
    if p.endswith(".kts"):
        patch_file(p, r"compileSdkVersion\s*=\s*\d+", "compileSdkVersion = 34")
        patch_file(p, r"targetSdkVersion\s*=\s*\d+", "targetSdkVersion = 34")
        patch_file(p, r"minSdkVersion\s*=\s*\d+", "minSdkVersion = 21")
    else:
        patch_file(p, r"compileSdkVersion\s+\d+", "compileSdkVersion 34")
        patch_file(p, r"targetSdkVersion\s+\d+", "targetSdkVersion 34")
        patch_file(p, r"minSdkVersion\s+\d+", "minSdkVersion 21")
    
    # Enable MultiDex and Desugaring
    with open(p, "r") as f: c = f.read()
    if "multiDexEnabled" not in c:
        if p.endswith(".kts"):
            c = c.replace("defaultConfig {", "defaultConfig {\n        multiDexEnabled = true")
            c = c.replace("compileOptions {", "compileOptions {\n        isCoreLibraryDesugaringEnabled = true")
            c += "\ndependencies {\n    coreLibraryDesugaring(\"com.android.tools:desugar_jdk_libs:2.0.4\")\n}\n"
        else:
            c = c.replace("defaultConfig {", "defaultConfig {\n        multiDexEnabled true")
            c = c.replace("compileOptions {", "compileOptions {\n        coreLibraryDesugaringEnabled true")
            c += "\ndependencies {\n    coreLibraryDesugaring \"com.android.tools:desugar_jdk_libs:2.0.4\"\n}\n"
        with open(p, "w") as f: f.write(c)
        print(f"🚀 Enabled MultiDex & Desugaring in {p}")
