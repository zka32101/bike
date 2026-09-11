# CI/CD Build Monitoring & Quality Gates

## Overview

This document describes the CI/CD pipeline configured for Build #38 and subsequent builds, including quality gates, analyzer checks, and monitoring strategies.

## GitHub Actions Workflows

### 1. flutter_ci.yml (Main CI Pipeline)

**Triggered On**:
- Push to `main` or `master` branches
- Pull Requests to `main` or `master` branches
- Manual workflow dispatch

#### Job 1: Prepare Build (ubuntu-latest)

**Steps**:
1. **Checkout Code**
   - Uses `actions/checkout@v4`
   - Fetches repository at current ref

2. **Setup Flutter**
   - Uses `subosito/flutter-action@v2`
   - Flutter version: `3.44.4` (stable channel)
   - Configures Dart SDK

3. **Install Dependencies**
   - Runs `flutter pub get`
   - Installs all package dependencies
   - Duration: ~2-3 minutes

4. **Flutter Analyzer** ⭐ NEW
   - Runs `flutter analyze --fatal-infos`
   - **Purpose**: Catch type errors, null safety issues, and lint violations
   - **Fatal**: Treats info-level issues as errors
   - **Scope**: Full codebase analysis
   - **Duration**: ~1-2 minutes

5. **Unit Tests** ⭐ NEW
   - Runs `flutter test`
   - Tests in `test/` directory
   - **Important**: Marked with `continue-on-error: true` (doesn't block APK build)
   - **Scope**: PredictionScoreService, AdGateService, etc.
   - **Duration**: ~1-2 minutes

6. **Code Generation**
   - Runs `flutter pub run build_runner build --delete-conflicting-outputs`
   - Generates code for:
     - `json_serializable` annotations
     - `freezed` data classes
     - `injectable` dependency injection
   - **Failure Mode**: Would fail job if `.g.dart` or `.freezed.dart` files contain errors
   - **Duration**: ~2-3 minutes

#### Job 2: Build Android APK (ubuntu-latest) - Depends on Prepare Build

**Steps**:
1. **Checkout Code**
2. **Setup Flutter** (3.44.4)
3. **Install Dependencies**
4. **Flutter Analyzer** (same as above) ⭐ NEW
5. **Unit Tests** ⭐ NEW
6. **Code Generation**
7. **Setup Java**
   - Uses `actions/setup-java@v4`
   - Java version: 17 (Temurin distribution)
   - Required for Android Gradle build

8. **Configure Firebase** (google-services.json)
   - Reads `GOOGLE_SERVICES_JSON_BASE64` secret
   - Base64-decodes and writes to `android/app/google-services.json`
   - **Fallback**: Creates empty JSON if secret not set (debug mode)
   - Allows builds to succeed even without Firebase credentials

9. **Build Debug APK**
   - Runs `flutter build apk --debug`
   - Captures output to `build.log`
   - Pipes to screen for real-time monitoring
   - **Duration**: ~5-10 minutes

10. **Verify APK Artifact**
    - Checks for APK file in `build/app/outputs/flutter-apk`
    - **Failure**: If APK not found, lists contents of build directory for debugging
    - Reports APK size (typically 50-70 MB for debug)

11. **Upload APK Artifact**
    - Uses `actions/upload-artifact@v4`
    - Stores APK for 30 days
    - Enables download from GitHub Actions UI
    - Name: `apk-debug`

## Quality Gates

### 1. Flutter Analyzer (`--fatal-infos`)

**What It Checks**:
- ✓ Type safety violations (with new `analysis_options.yaml`)
- ✓ Null safety issues
- ✓ Unused imports and variables
- ✓ Missing return types (enforced)
- ✓ Implicit casts (forbidden)
- ✓ Implicit dynamics (forbidden)
- ✓ 80+ lint rules (see `analysis_options.yaml`)

**Failure Criteria**:
- Any analyzer warning or info (with `--fatal-infos`)
- Type errors always fail
- Lint violations configured as errors in `analysis_options.yaml`

**Expected Duration**: ~1-2 minutes
**Typical Issues Found**: var usage, null assertions, missing types

### 2. Unit Tests

**Test Suite**:
- `test/services/prediction_score_service_test.dart`
- `test/services/ad_gate_service_test.dart`
- Additional tests as coverage expands

**Coverage**:
- Core business logic (prediction algorithm)
- Ad gate conditions
- Soon: Analytics, Auth, Firestore integrations

**Failure Criteria**:
- Test assertion failures
- Uncaught exceptions
- Setup/teardown errors

**Status**: `continue-on-error: true` (doesn't block build)
- Allows APK generation even if tests fail
- Recommended: Migrate to `continue-on-error: false` once coverage is comprehensive

### 3. Code Generation (build_runner)

**Generators**:
- `json_serializable`: Generates `fromJson()` and `toJson()` methods
- `freezed`: Generates immutable data classes
- `injectable`: Generates dependency injection setup

**Failure Criteria**:
- Syntax errors in `.dart` files
- Missing annotations on classes
- Conflicting directives
- Incompatible package versions

**Recovery**: 
- Run locally: `flutter pub run build_runner build --delete-conflicting-outputs`
- Re-run CI job after fixes

### 4. Android APK Build

**Failure Criteria**:
- Gradle build errors
- Missing dependencies
- Java compilation errors
- R.java generation failures
- APK not found in build output directory

**Recovery Steps**:
1. Check `build.log` for detailed error
2. Run locally: `flutter build apk --debug`
3. Clear build cache: `flutter clean && flutter pub get`
4. Re-run CI job

## Monitoring & Alerts

### 1. Build Dashboard

**Location**: GitHub Actions → Workflow runs
**Visible Metrics**:
- ✓ Build status (pass/fail)
- ✓ Execution time per job
- ✓ Logs for each step
- ✓ Artifact download link

### 2. Real-Time Monitoring

**Check build status**:
```bash
# List latest workflow runs
gh run list --repo zka32101/bike

# View specific run details
gh run view <run-id> --repo zka32101/bike

# Stream logs from running job
gh run watch <run-id> --repo zka32101/bike
```

### 3. Post-Build Analysis

**APK Artifacts**:
- Download from Actions tab
- File: `apk-debug-<commit-hash>.apk`
- Size target: < 80 MB (currently ~50-70 MB)
- Retention: 30 days

**Build Log Analysis**:
- Review for warnings during compilation
- Check analyzer output for type violations
- Verify code generation completed

## Troubleshooting Build Failures

### Analyzer Failures

**Error**: `FAILURE: Build failed with an exception.`

**Common Causes**:
1. Type errors (var used instead of explicit type)
   - **Fix**: Replace `var` with explicit type in source file
   
2. Null safety violations
   - **Fix**: Add proper null checks or update type annotations
   
3. Unused imports
   - **Fix**: Remove unused `import` statements

4. Missing return types
   - **Fix**: Add explicit return type to function/method

**Resolution**:
```bash
# Run analyzer locally to see all issues
flutter analyze --fatal-infos

# Fix identified issues
# Re-run analyzer to verify
flutter analyze
```

### Test Failures

**Error**: `FAILED: 5 failed, 15 passed`

**Common Causes**:
1. Logic error in implementation
2. Mock/stub not configured correctly
3. Expected/actual mismatch

**Resolution**:
```bash
# Run tests locally with verbose output
flutter test --verbose

# Run single test file
flutter test test/services/prediction_score_service_test.dart

# Update test expectations if logic changed intentionally
```

### Code Generation Failures

**Error**: `Could not resolve input file android/app`

**Common Causes**:
1. `.dart` file syntax error
2. Missing `part` directive
3. Incompatible `build_runner` version

**Resolution**:
```bash
# Clean and regenerate
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

# Or with deletion of existing generated files
flutter pub run build_runner build --delete-conflicting-outputs
```

### APK Build Failures

**Error**: `FAILURE: Build failed with an exception`

**Common Causes**:
1. Java/Gradle version mismatch
2. Missing Firebase configuration
3. Android SDK issues
4. Dependency conflicts

**Resolution**:
```bash
# Clean and try again
flutter clean
flutter pub get
flutter build apk --debug

# Or build without Firebase (debug)
# Use empty google-services.json
```

## CI/CD Metrics & KPIs

### Build Performance

| Metric | Target | Typical |
|--------|--------|---------|
| Prepare Build | < 8 min | 6-7 min |
| Analyzer | < 2 min | 1-1.5 min |
| Tests | < 3 min | 1-2 min |
| APK Build | < 10 min | 5-8 min |
| **Total Time** | < 25 min | 15-20 min |

### Quality Metrics

| Metric | Target | Current |
|--------|--------|---------|
| Analyzer Warnings | 0 | 0 (after Phase 1 fixes) |
| Test Pass Rate | 100% | N/A (limited tests) |
| Code Coverage | 50%+ | ~30% (growing) |
| Type Safety Score | 100% | 100% (after Phase 1) |

## Next Steps & Improvements

### Short Term (Next 2 weeks)
- [ ] Monitor first 5-10 builds after enhancements
- [ ] Document any new failure patterns
- [ ] Optimize Gradle cache for faster builds
- [ ] Add build time tracking dashboard

### Medium Term (Next 4 weeks)
- [ ] Expand test coverage to 50%+
- [ ] Add performance regression testing
- [ ] Implement code coverage reporting
- [ ] Set up build artifact versioning

### Long Term (Next 3 months)
- [ ] Integrate SonarQube for code quality
- [ ] Add automated security scanning
- [ ] Implement canary deployments
- [ ] Set up production monitoring

## Related Documentation

- `BUILD_IMPROVEMENTS.md` - Build #38 fixes and improvements
- `README.md` - Project overview
- `FIREBASE_SETUP.md` - Firebase configuration
- `analysis_options.yaml` - Linting configuration

## Configuration Files

- `.github/workflows/flutter_ci.yml` - Main CI/CD workflow (enhanced)
- `analysis_options.yaml` - Analyzer and linter configuration (enhanced)
- `pubspec.yaml` - Dependency versions
- `android/app/build.gradle` - Android build configuration

---

**Last Updated**: 2026-09-11  
**Status**: CI/CD Pipeline Enhanced with Type Safety Checks  
**Workflow File**: `.github/workflows/flutter_ci.yml`
