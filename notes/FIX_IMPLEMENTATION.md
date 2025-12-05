# Implementation Guide: Architecture Fixes

## ✅ **FIXES APPLIED**

### 1. Fixed `_safeNotifyListeners()` Method
**File:** `lib/providers/classroom_provider.dart`

**Before:**
```dart
void _safeNotifyListeners() {
  Future.microtask(() {
    notifyListeners();
  });
}
```

**After:**
```dart
void _safeNotifyListeners() {
  final scheduler = SchedulerBinding.instance;
  
  if (scheduler.schedulerPhase == SchedulerPhase.idle) {
    notifyListeners();
  } else {
    scheduler.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
```

**Why this works:**
- `SchedulerPhase.idle` = build phase sudah selesai
- `addPostFrameCallback` = execute setelah frame selesai
- Lebih reliable daripada `Future.microtask`

### 2. Fixed `classroom_info_screen.dart` initState
**File:** `lib/presentation/screens/classroom/classroom_info_screen.dart`

**Before:**
```dart
@override
void initState() {
  super.initState();
  _fetchClassroomDetail(); // ❌ Langsung dipanggil
}
```

**After:**
```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _fetchClassroomDetail(); // ✅ Setelah build selesai
  });
}
```

**Why this works:**
- `addPostFrameCallback` memastikan build phase sudah selesai
- Async operations tidak akan trigger rebuild selama build
- Konsisten dengan pattern di `home_screen.dart`

---

## 🔄 **NEXT STEPS (Recommended)**

### Step 1: Apply `_safeNotifyListeners()` to All Methods

**Current Status:**
- ✅ `fetchClassroom()` - sudah pakai `_safeNotifyListeners()`
- ❌ `fetchClassrooms()` - masih pakai `notifyListeners()` langsung
- ❌ `fetchClassSchedules()` - masih pakai `notifyListeners()` langsung
- ❌ `createClassroom()` - masih pakai `notifyListeners()` langsung
- ❌ Semua method lain - masih pakai `notifyListeners()` langsung

**Action Required:**
Ganti semua `notifyListeners()` dengan `_safeNotifyListeners()` di:
- `fetchClassrooms()` (line 35, 40, 44, 49)
- `createClassroom()` (line 84, 93, 98, 103)
- `joinClassroom()` (line 112, 118, 123, 128)
- `fetchClassSchedules()` (line 137, 142, 146, 151)
- `createClassSchedule()` (line 173, 195, 200, 205)
- `updateClassSchedule()` (line 226, 249, 254, 259)
- `deleteClassSchedule()` (line 271, 281, 285, 290)
- `leaveClassroom()` (line 299, 310, 314, 319)
- `removeMember()` (line 331, 343, 347, 352)
- `transferOwnership()` (line 364, 376, 380, 385)
- `updateClassroomDescription()` (line 397, 417, 421, 426)
- `clearError()` (line 433)
- `clearSchedules()` (line 438)

**Quick Fix Script:**
```dart
// Find and replace:
notifyListeners();
// With:
_safeNotifyListeners();
```

### Step 2: Fix Nested fetchClassroom Calls

**Issue:** `removeMember()` dan `transferOwnership()` memanggil `fetchClassroom()` yang juga memanggil `notifyListeners()`

**Current:**
```dart
Future<void> removeMember(...) async {
  _isLoading = true;
  notifyListeners(); // Notify #1
  
  await _classroomService.removeMember(...);
  await fetchClassroom(classroomId); // ❌ Nested call, akan notify lagi
  
  _isLoading = false;
  notifyListeners(); // Notify #2
}
```

**Recommended Fix:**
```dart
Future<void> removeMember(...) async {
  _isLoading = true;
  _safeNotifyListeners();
  
  try {
    await _classroomService.removeMember(...);
    
    // ✅ Update local state instead of refetch
    final index = _classrooms.indexWhere((c) => c.id == classroomId);
    if (index != -1) {
      // Option 1: Refetch only if needed
      _classrooms[index] = await _classroomService.getClassroom(classroomId);
    }
    
    // Update selectedClassroom if it's the same
    if (_selectedClassroom?.id == classroomId) {
      _selectedClassroom = await _classroomService.getClassroom(classroomId);
    }
    
    _isLoading = false;
    _safeNotifyListeners();
  } catch (e) {
    _isLoading = false;
    _errorMessage = e.toString();
    _safeNotifyListeners();
    rethrow;
  }
}
```

### Step 3: Separate Loading States (Optional but Recommended)

**Current:**
```dart
bool _isLoading = false; // Single flag untuk semua
```

**Recommended:**
```dart
bool _isLoadingClassrooms = false;
bool _isLoadingClassroom = false;
bool _isLoadingSchedules = false;

bool get isLoadingClassrooms => _isLoadingClassrooms;
bool get isLoadingClassroom => _isLoadingClassroom;
bool get isLoadingSchedules => _isLoadingSchedules;
```

**Benefits:**
- Tidak ada conflict antara operations
- UI bisa show loading state yang spesifik
- Lebih mudah di-debug

---

## 🧪 **TESTING CHECKLIST**

Setelah apply fixes, test:

1. ✅ Navigate ke classroom detail screen
   - Should not show "setState during build" error
   - Should load classroom data correctly

2. ✅ Navigate ke classroom info screen
   - Should not show "setState during build" error
   - Should load classroom detail correctly

3. ✅ Test concurrent operations
   - Fetch classrooms + fetch classroom detail simultaneously
   - Should not cause errors

4. ✅ Test nested operations
   - Remove member → should update classroom correctly
   - Transfer ownership → should update classroom correctly

---

## 📊 **EXPECTED RESULTS**

### Before Fix:
- ❌ Error: "setState() or markNeedsBuild() called during build"
- ❌ Inconsistent async loading pattern
- ❌ Multiple rebuilds per operation

### After Fix:
- ✅ Zero "setState during build" errors
- ✅ Consistent async loading pattern
- ✅ Controlled rebuilds (only when needed)

---

## 🔍 **MONITORING**

After deployment, monitor:
1. Error logs untuk "setState during build"
2. Performance metrics (rebuild count)
3. User reports untuk UI glitches

---

## 📝 **NOTES**

- `SchedulerBinding.instance.schedulerPhase` check lebih reliable daripada `Future.microtask`
- `addPostFrameCallback` adalah standard Flutter pattern untuk post-build operations
- Konsistensi penting: semua async operations di `initState()` harus pakai `addPostFrameCallback`

