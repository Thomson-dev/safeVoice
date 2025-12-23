# Additional Fix: setState/markNeedsBuild During Build Error

## New Error After Initial Fix
After fixing the original `LateInitializationError`, a new error appeared:
```
setState() or markNeedsBuild() called during build.
This Overlay widget cannot be marked as needing to build because the framework is already in the process of building widgets.
```

## Root Cause
The error occurred in `ReportDetailScreen` where:
1. `initState()` was calling `_fetchDetailsForCase()`
2. `_fetchDetailsForCase()` calls `reportController.fetchCaseDetails()`
3. `fetchCaseDetails()` was showing snackbars immediately
4. Snackbars trigger overlay updates during the build phase → ERROR

## Solution Applied

### 1. ✅ Delayed Data Fetching in ReportDetailScreen
**File:** `lib/features/counselor/screens/report_detail_screen.dart`

```dart
@override
void initState() {
  super.initState();
  // ... extract caseId ...
  
  if (caseId != null && caseId.isNotEmpty) {
    _caseId = caseId;
    // Delay fetching until after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDetailsForCase(caseId!);
    });
  }
  _tabController = TabController(length: 3, vsync: this);
}
```

### 2. ✅ Removed Debug Snackbars from ReportController
**File:** `lib/app/controllers/report_controller.dart`

Removed debug snackbars from:
- `fetchCaseDetails()` - Removed "Case details loaded" snackbar
- `fetchCounselorCases()` - Removed "Fetched cases" snackbar

### 3. ✅ Delayed Error Snackbar
**File:** `lib/app/controllers/report_controller.dart`

```dart
catch (e) {
  print('ReportController: Error fetching case details - $e');
  // Delay error snackbar to avoid showing during build
  Future.delayed(const Duration(milliseconds: 100), () {
    Get.snackbar('Error', '...', ...);
  });
  return null;
}
```

## Key Principle

**NEVER call Get.snackbar (or any overlay/dialog) during:**
- Widget `initState()`
- Widget `build()` method
- Controller `onInit()` (without delay)
- Any synchronous code path that runs during widget construction

**ALWAYS use one of these patterns:**
1. `WidgetsBinding.instance.addPostFrameCallback((_) { ... })`
2. `Future.delayed(const Duration(milliseconds: 100), () { ... })`
3. Call from user interaction callbacks (onPressed, onTap, etc.)

## Files Modified
1. `lib/features/counselor/screens/report_detail_screen.dart` - Added postFrameCallback
2. `lib/app/controllers/report_controller.dart` - Removed debug snackbars, delayed error snackbar

## Success Criteria
✅ No "setState during build" errors
✅ Case details load correctly
✅ Error messages still appear (just delayed)
✅ App remains responsive
