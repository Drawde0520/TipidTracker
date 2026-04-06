import os, re, glob

def read_file(path):
    if os.path.exists(path):
        with open(path, "r") as f:
            return f.read()
    return None

def write_file(path, content):
    with open(path, "w") as f:
        f.write(content)

def find_file(base, name):
    """Find a file, checking both .gradle and .gradle.kts variants."""
    kts = os.path.join(base, name + ".kts")
    groovy = os.path.join(base, name)
    if os.path.exists(kts):
        return kts
    if os.path.exists(groovy):
        return groovy
    return None

# ============================================================
# STEP 0: Debug - Print what flutter create generated
# ============================================================
print("=" * 60)
print("DEBUG: Listing android/ directory structure")
print("=" * 60)
for root, dirs, files in os.walk("android"):
    level = root.replace("android", "").count(os.sep)
    indent = " " * 2 * level
    print(f"{indent}{os.path.basename(root)}/")
    subindent = " " * 2 * (level + 1)
    for file in files:
        filepath = os.path.join(root, file)
        size = os.path.getsize(filepath)
        print(f"{subindent}{file} ({size} bytes)")

# ============================================================
# STEP 1: Print the contents of key build files BEFORE patching
# ============================================================
root_build = find_file("android", "build.gradle")
app_build = find_file("android/app", "build.gradle")
settings_file = find_file("android", "settings.gradle")
wrapper = "android/gradle/wrapper/gradle-wrapper.properties"

for label, path in [("ROOT build", root_build), ("APP build", app_build), 
                     ("SETTINGS", settings_file), ("WRAPPER", wrapper)]:
    content = read_file(path) if path else None
    print(f"\n{'=' * 60}")
    print(f"DEBUG: {label} file = {path}")
    print(f"{'=' * 60}")
    if content:
        print(content[:2000])  # First 2000 chars
    else:
        print("FILE NOT FOUND")

# ============================================================
# STEP 2: Patch based on actual file type
# ============================================================

# --- Root build file ---
if root_build:
    c = read_file(root_build)
    is_kts = root_build.endswith(".kts")
    
    if is_kts:
        # Modern KTS root build files use plugins {} block
        # We need to update the Kotlin version in the plugins block
        c = re.sub(
            r'id\("org\.jetbrains\.kotlin\.android"\)\s+version\s+"[^"]*"',
            'id("org.jetbrains.kotlin.android") version "1.9.22"',
            c
        )
        # Also handle: kotlin("android") version "x.x.x"
        c = re.sub(
            r'kotlin\("android"\)\s+version\s+"[^"]*"',
            'kotlin("android") version "1.9.22"',
            c
        )
    else:
        # Groovy style
        c = re.sub(r"ext\.kotlin_version\s*=\s*['\"].*?['\"]", "ext.kotlin_version = '1.9.22'", c)
        c = re.sub(r"com\.android\.tools\.build:gradle:[^'\"]*", "com.android.tools.build:gradle:8.0.2", c)
    
    write_file(root_build, c)
    print(f"\n✅ Patched root build file: {root_build}")

# --- Settings file (modern Flutter uses settings.gradle.kts with plugin management) ---
if settings_file:
    c = read_file(settings_file)
    is_kts = settings_file.endswith(".kts")
    
    if is_kts:
        # Update Kotlin version in settings plugins block
        c = re.sub(
            r'id\("org\.jetbrains\.kotlin\.android"\)\s+version\s+"[^"]*"',
            'id("org.jetbrains.kotlin.android") version "1.9.22"',
            c
        )
        c = re.sub(
            r'kotlin\("android"\)\s+version\s+"[^"]*"',
            'kotlin("android") version "1.9.22"',
            c
        )
    
    write_file(settings_file, c)
    print(f"✅ Patched settings file: {settings_file}")

# --- Gradle wrapper ---
if os.path.exists(wrapper):
    c = read_file(wrapper)
    # Don't corrupt the URL - use proper escaping
    c = re.sub(
        r"distributionUrl=.*",
        r"distributionUrl=https\://services.gradle.org/distributions/gradle-8.0-all.zip",
        c
    )
    write_file(wrapper, c)
    print(f"✅ Patched wrapper: {wrapper}")

# --- App build file ---
if app_build:
    c = read_file(app_build)
    is_kts = app_build.endswith(".kts")
    
    if is_kts:
        # Modern Flutter KTS uses flutter properties like flutter.compileSdkVersion
        # Replace flutter references with hard values
        c = re.sub(r'flutter\.compileSdkVersion', '34', c)
        c = re.sub(r'flutter\.targetSdkVersion', '34', c)
        c = re.sub(r'flutter\.minSdkVersion', '21', c)
        # Also handle already-numeric versions
        c = re.sub(r'compileSdk\s*=\s*\d+', 'compileSdk = 34', c)
        c = re.sub(r'targetSdk\s*=\s*\d+', 'targetSdk = 34', c)
        c = re.sub(r'minSdk\s*=\s*\d+', 'minSdk = 21', c)
        
        # MultiDex
        if "multiDexEnabled" not in c:
            c = c.replace("defaultConfig {", "defaultConfig {\n        multiDexEnabled = true")
        
        # Desugaring - need to add to compileOptions AND dependencies
        if "isCoreLibraryDesugaringEnabled" not in c:
            c = c.replace("compileOptions {", "compileOptions {\n        isCoreLibraryDesugaringEnabled = true")
        
        if "desugar_jdk_libs" not in c:
            # Add dependency at the end of the dependencies block
            # Find the last } in the file and insert before it
            c = re.sub(
                r'(dependencies\s*\{)',
                r'\1\n    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")',
                c,
                count=1
            )
            # If there's no dependencies block, add one at the end
            if "desugar_jdk_libs" not in c:
                c += '\n\ndependencies {\n    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")\n}\n'
        
    else:
        # Groovy style
        c = re.sub(r'flutter\.compileSdkVersion', '34', c)
        c = re.sub(r'flutter\.targetSdkVersion', '34', c)
        c = re.sub(r'flutter\.minSdkVersion', '21', c)
        c = re.sub(r'compileSdkVersion\s+\d+', 'compileSdkVersion 34', c)
        c = re.sub(r'targetSdkVersion\s+\d+', 'targetSdkVersion 34', c)
        c = re.sub(r'minSdkVersion\s+\d+', 'minSdkVersion 21', c)
        
        if "multiDexEnabled" not in c:
            c = c.replace("defaultConfig {", "defaultConfig {\n        multiDexEnabled true")
        
        if "coreLibraryDesugaringEnabled" not in c:
            c = c.replace("compileOptions {", "compileOptions {\n        coreLibraryDesugaringEnabled true")
        
        if "desugar_jdk_libs" not in c:
            c = re.sub(
                r'(dependencies\s*\{)',
                r'\1\n    coreLibraryDesugaring "com.android.tools:desugar_jdk_libs:2.0.4"',
                c,
                count=1
            )
            if "desugar_jdk_libs" not in c:
                c += '\n\ndependencies {\n    coreLibraryDesugaring "com.android.tools:desugar_jdk_libs:2.0.4"\n}\n'
    
    write_file(app_build, c)
    print(f"✅ Patched app build file: {app_build}")

# ============================================================
# STEP 3: Print the contents of key build files AFTER patching
# ============================================================
for label, path in [("ROOT build", root_build), ("APP build", app_build),
                     ("SETTINGS", settings_file)]:
    content = read_file(path) if path else None
    print(f"\n{'=' * 60}")
    print(f"AFTER PATCH: {label} file = {path}")
    print(f"{'=' * 60}")
    if content:
        print(content[:2000])
    else:
        print("FILE NOT FOUND")

print("\n🏁 Patching complete!")
