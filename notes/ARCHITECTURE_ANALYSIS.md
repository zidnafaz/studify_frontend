# Deep Architecture Analysis: Flutter State Management
## Root Cause Analysis & Recommendations

---

## 🔴 **EXECUTIVE SUMMARY**

**Primary Issue:** `setState() or markNeedsBuild() called during build` error terjadi karena **reentrant build cycle** yang disebabkan oleh:
1. **Timing Issue**: `fetchClassroom()` dipanggil di `initState()` tanpa `addPostFrameCallback`
2. **Nested NotifyListeners**: `fetchClassroom()` dipanggil di dalam method lain yang sudah memanggil `notifyListeners()`
3. **Global Loading State**: Single `_isLoading` flag menyebabkan rebuild cascade
4. **Future.microtask Patch**: Solusi sementara yang menutupi masalah struktural

**Root Cause:** Arsitektur provider tidak memisahkan **UI state** dari **data state**, dan tidak menggunakan **loading state per-operation**.

---

## 📊 **1. ROOT CAUSE ANALYSIS**

### 1.1 Error Location & Flow

```
classroom_info_screen.dart:27
  initState() 
    → _fetchClassroomDetail() [SYNC CALL]
      → fetchClassroom(classroomId) [ASYNC]
        → _safeNotifyListeners() [line 58]
          → Future.microtask(() => notifyListeners())
            → Consumer<ClassroomProvider> rebuild
              → build() method executes
                → ❌ ERROR: notifyListeners() called during build
```

**Masalah Kritis:**
- `_fetchClassroomDetail()` dipanggil **langsung** di `initState()` tanpa `addPostFrameCallback`
- `fetchClassroom()` memanggil `_safeNotifyListeners()` yang menggunakan `Future.microtask`
- `Future.microtask` **tidak menjamin** build sudah selesai
- `Consumer<ClassroomProvider>` di line 286 bisa rebuild saat build masih berlangsung

### 1.2 Flutter Build Phase Mechanism

Flutter build cycle:
```
1. build() method called
2. Widget tree constructed
3. InheritedWidget (Provider) updated
4. Dependencies registered
5. Build completes
6. Post-frame callbacks executed
```

**Error terjadi karena:**
- `notifyListeners()` dipanggil **selama fase 1-4** (build phase)
- `Future.microtask` **bukan** post-frame callback, hanya defer ke event loop berikutnya
- Jika Consumer sedang build, `notifyListeners()` akan trigger rebuild **selama build**

### 1.3 Race Condition Analysis

**Scenario yang menyebabkan error:**

```dart
// classroom_info_screen.dart:27
initState() {
  _fetchClassroomDetail(); // ❌ Dipanggil langsung
}

// classroom_provider.dart:55
Future<void> fetchClassroom(int classroomId) async {
  _isLoading = true;
  _safeNotifyListeners(); // ❌ Microtask scheduled
  
  // ... async operation ...
  
  _safeNotifyListeners(); // ❌ Microtask scheduled lagi
}
```

**Race Condition:**
1. Widget build dimulai
2. `initState()` dipanggil → `_fetchClassroomDetail()` → `fetchClassroom()`
3. `_safeNotifyListeners()` schedule microtask
4. Build method `build()` masih berjalan
5. Microtask executes → `notifyListeners()` → Consumer rebuild
6. **ERROR**: Rebuild dipanggil selama build phase

---

## 🏗️ **2. ARCHITECTURE ISSUES**

### 2.1 Provider-Service-Model Pattern

**Current Structure:**
```
UI (Widget)
  ↓
Provider (ChangeNotifier)
  ↓
Service (DioClient)
  ↓
API
```

**Masalah:**
- ✅ Pattern benar secara konseptual
- ❌ Implementasi tidak konsisten
- ❌ Tidak ada separation of concerns untuk loading states
- ❌ Provider melakukan terlalu banyak (business logic + state management)

### 2.2 State Management Anti-Patterns

#### **Anti-Pattern #1: Global Loading State**

```dart
// classroom_provider.dart:13
bool _isLoading = false; // ❌ Single flag untuk semua operations
```

**Masalah:**
- Semua operations share satu `_isLoading` flag
- `fetchClassrooms()` dan `fetchClassroom()` bisa conflict
- Tidak bisa track multiple async operations
- Rebuild cascade: semua Consumer rebuild meski hanya 1 operation

**Impact:**
- UI flicker saat multiple operations
- Loading indicator muncul untuk semua operations
- Performance degradation

#### **Anti-Pattern #2: Nested Async Calls dengan NotifyListeners**

```dart
// classroom_provider.dart:340
Future<void> removeMember(...) async {
  _isLoading = true;
  notifyListeners(); // ❌ Notify #1
  
  await _classroomService.removeMember(...);
  await fetchClassroom(classroomId); // ❌ Nested call
  
  // fetchClassroom akan memanggil _safeNotifyListeners() lagi
  // = Multiple notifyListeners() calls
  
  _isLoading = false;
  notifyListeners(); // ❌ Notify #2
}
```

**Masalah:**
- `removeMember()` memanggil `fetchClassroom()` yang juga memanggil `notifyListeners()`
- Multiple rebuilds untuk satu operation
- Tidak ada debouncing atau batching

#### **Anti-Pattern #3: Inconsistent Post-Frame Callback Usage**

```dart
// ✅ BENAR: home_screen.dart:114
WidgetsBinding.instance.addPostFrameCallback((_) {
  Provider.of<ClassroomProvider>(context, listen: false)
      .fetchClassrooms();
});

// ❌ SALAH: classroom_info_screen.dart:27
initState() {
  _fetchClassroomDetail(); // Langsung dipanggil
}
```

**Masalah:**
- Tidak konsisten dalam menangani async operations di `initState()`
- Beberapa menggunakan `addPostFrameCallback`, yang lain tidak
- Error hanya muncul di yang tidak menggunakan callback

#### **Anti-Pattern #4: Future.microtask sebagai Patch**

```dart
// classroom_provider.dart:24
void _safeNotifyListeners() {
  Future.microtask(() {
    notifyListeners();
  });
}
```

**Masalah:**
- `Future.microtask` **bukan** solusi untuk build phase issue
- Hanya menunda ke event loop berikutnya, bukan post-frame
- Masih bisa trigger rebuild selama build phase
- Menutupi masalah struktural, bukan menyelesaikannya

**Kenapa tidak bekerja:**
- `Future.microtask` execute **sebelum** post-frame callbacks
- Jika build masih berjalan, microtask bisa execute **selama** build
- Tidak ada jaminan build sudah selesai

---

## 🔍 **3. DETAILED CODE ANALYSIS**

### 3.1 ClassroomProvider Issues

#### Issue #1: Mixed Loading States

```dart
// Line 13: Single loading flag
bool _isLoading = false;

// Line 32: fetchClassrooms() menggunakan _isLoading
// Line 55: fetchClassroom() menggunakan _isLoading yang sama
// Line 134: fetchClassSchedules() menggunakan _isLoading yang sama
```

**Problem:**
- Jika `fetchClassrooms()` dan `fetchClassroom()` dipanggil bersamaan:
  - Keduanya set `_isLoading = true`
  - Keduanya memanggil `notifyListeners()`
  - Consumer rebuild multiple times
  - Race condition pada state

#### Issue #2: Nested fetchClassroom Calls

```dart
// Line 340: removeMember()
await fetchClassroom(classroomId); // Nested call

// Line 373: transferOwnership()
await fetchClassroom(classroomId); // Nested call
```

**Problem:**
- `fetchClassroom()` sudah memanggil `_safeNotifyListeners()` 2x (start + end)
- Method parent juga memanggil `notifyListeners()` 2x
- Total: **4 rebuilds** untuk satu operation
- Performance issue + potential build phase error

#### Issue #3: Inconsistent NotifyListeners

```dart
// fetchClassroom() menggunakan _safeNotifyListeners()
_safeNotifyListeners(); // Line 58, 63, 67, 72

// fetchClassrooms() menggunakan notifyListeners() langsung
notifyListeners(); // Line 35, 40, 44, 49
```

**Problem:**
- Tidak konsisten: beberapa method pakai `_safeNotifyListeners()`, yang lain tidak
- `fetchClassrooms()` bisa juga menyebabkan error yang sama
- Tidak ada standar yang jelas

### 3.2 Widget Usage Issues

#### Issue #1: classroom_info_screen.dart

```dart
// Line 27: initState() langsung memanggil async method
initState() {
  super.initState();
  _fetchClassroomDetail(); // ❌ Tidak pakai addPostFrameCallback
}

// Line 30: Async method tanpa protection
Future<void> _fetchClassroomDetail() async {
  // ...
  await classroomProvider.fetchClassroom(widget.classroom.id);
  // ...
}
```

**Problem:**
- `initState()` memanggil async method langsung
- Build method bisa execute sebelum async selesai
- `fetchClassroom()` memanggil `_safeNotifyListeners()` yang schedule microtask
- Microtask bisa execute selama build → ERROR

#### Issue #2: Consumer di Build Method

```dart
// classroom_info_screen.dart:286
return Consumer<ClassroomProvider>(
  builder: (context, classroomProvider, child) {
    final classroom = classroomProvider.selectedClassroom ?? ...;
    // ...
  },
);
```

**Problem:**
- `Consumer` rebuild setiap kali `notifyListeners()` dipanggil
- Jika `notifyListeners()` dipanggil selama build, Consumer akan rebuild
- Reentrant build cycle

### 3.3 Provider Registration Issues

```dart
// main.dart:29
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => ClassroomProvider()),
    ChangeNotifierProvider(create: (_) => PersonalScheduleProvider()),
    ChangeNotifierProvider(create: (_) => CombinedScheduleProvider()),
  ],
)
```

**Analysis:**
- ✅ Provider registration benar
- ✅ Menggunakan `ChangeNotifierProvider` dengan benar
- ❌ Tidak ada lifecycle management
- ❌ Provider instance dibuat fresh setiap kali (tidak masalah untuk stateless)

---

## 🎯 **4. BEST PRACTICE COMPARISON**

### 4.1 Standard Provider Pattern

**Recommended Pattern:**
```dart
class ClassroomProvider with ChangeNotifier {
  // Separate loading states per operation
  bool _isLoadingClassrooms = false;
  bool _isLoadingClassroom = false;
  bool _isLoadingSchedules = false;
  
  // Or use enum-based state
  LoadingState _classroomsState = LoadingState.idle;
  LoadingState _classroomState = LoadingState.idle;
  
  // Safe notify with build phase check
  void _notifyIfSafe() {
    if (SchedulerBinding.instance.schedulerPhase == 
        SchedulerPhase.idle) {
      notifyListeners();
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }
}
```

### 4.2 Async Loading Pattern

**Recommended:**
```dart
// ✅ BENAR: initState dengan addPostFrameCallback
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadData();
  });
}

// ✅ BENAR: Atau gunakan FutureBuilder/StreamBuilder
FutureBuilder<Classroom>(
  future: _loadClassroom(),
  builder: (context, snapshot) { ... }
)
```

### 4.3 State Separation

**Recommended:**
```dart
// Separate UI state from data state
class ClassroomProvider with ChangeNotifier {
  // Data state
  List<Classroom> _classrooms = [];
  Classroom? _selectedClassroom;
  
  // UI state (per operation)
  Map<String, LoadingState> _loadingStates = {};
  
  bool isLoading(String operation) {
    return _loadingStates[operation] == LoadingState.loading;
  }
}
```

---

## 🔧 **5. RECOMMENDED SOLUTIONS**

### 5.1 Immediate Fix (Non-Breaking)

#### Fix #1: Use addPostFrameCallback di initState

```dart
// classroom_info_screen.dart:25
@override
void initState() {
  super.initState();
  // ✅ FIX: Gunakan addPostFrameCallback
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _fetchClassroomDetail();
  });
}
```

#### Fix #2: Replace Future.microtask dengan SchedulerBinding

```dart
// classroom_provider.dart:24
void _safeNotifyListeners() {
  // ✅ FIX: Gunakan SchedulerBinding untuk check build phase
  if (SchedulerBinding.instance.schedulerPhase == 
      SchedulerPhase.idle) {
    notifyListeners();
  } else {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
```

**Kenapa lebih baik:**
- `SchedulerPhase.idle` = build sudah selesai
- `addPostFrameCallback` = execute setelah frame selesai
- Lebih reliable daripada `Future.microtask`

#### Fix #3: Consistent Pattern untuk Semua Methods

```dart
// ✅ Apply _safeNotifyListeners() ke SEMUA methods
Future<void> fetchClassrooms() async {
  _isLoading = true;
  _errorMessage = null;
  _safeNotifyListeners(); // ✅ Konsisten
  
  // ... rest of code
}
```

### 5.2 Architectural Refactor (Breaking Changes)

#### Refactor #1: Separate Loading States

```dart
class ClassroomProvider with ChangeNotifier {
  // ✅ Separate loading states
  bool _isLoadingClassrooms = false;
  bool _isLoadingClassroom = false;
  bool _isLoadingSchedules = false;
  
  bool get isLoadingClassrooms => _isLoadingClassrooms;
  bool get isLoadingClassroom => _isLoadingClassroom;
  bool get isLoadingSchedules => _isLoadingSchedules;
  
  // ✅ Per-operation loading
  Future<void> fetchClassrooms() async {
    _isLoadingClassrooms = true;
    _safeNotifyListeners();
    // ...
  }
  
  Future<void> fetchClassroom(int id) async {
    _isLoadingClassroom = true;
    _safeNotifyListeners();
    // ...
  }
}
```

#### Refactor #2: Remove Nested fetchClassroom Calls

```dart
// ✅ FIX: removeMember() tidak perlu fetchClassroom lagi
Future<void> removeMember({...}) async {
  _isLoading = true;
  _safeNotifyListeners();
  
  try {
    await _classroomService.removeMember(...);
    
    // ✅ Update local state instead of refetch
    final index = _classrooms.indexWhere((c) => c.id == classroomId);
    if (index != -1) {
      // Refresh classroom from list atau update manually
      _classrooms[index] = await _classroomService.getClassroom(classroomId);
    }
    
    _isLoading = false;
    _safeNotifyListeners();
  } catch (e) {
    // ...
  }
}
```

#### Refactor #3: Use AsyncValue Pattern (Riverpod-style)

```dart
class AsyncValue<T> {
  final T? data;
  final Object? error;
  final bool isLoading;
  
  const AsyncValue.loading() : this._(null, null, true);
  const AsyncValue.data(T data) : this._(data, null, false);
  const AsyncValue.error(Object error) : this._(null, error, false);
  
  const AsyncValue._(this.data, this.error, this.isLoading);
}

class ClassroomProvider with ChangeNotifier {
  AsyncValue<List<Classroom>> _classrooms = const AsyncValue.loading();
  AsyncValue<Classroom> _selectedClassroom = const AsyncValue.loading();
  
  AsyncValue<List<Classroom>> get classrooms => _classrooms;
  AsyncValue<Classroom> get selectedClassroom => _selectedClassroom;
}
```

---

## 📋 **6. ACTIONABLE RECOMMENDATIONS**

### Priority 1: Critical Fixes (Do Immediately)

1. **Fix classroom_info_screen.dart:27**
   ```dart
   @override
   void initState() {
     super.initState();
     WidgetsBinding.instance.addPostFrameCallback((_) {
       _fetchClassroomDetail();
     });
   }
   ```

2. **Replace Future.microtask dengan SchedulerBinding**
   ```dart
   void _safeNotifyListeners() {
     if (SchedulerBinding.instance.schedulerPhase == 
         SchedulerPhase.idle) {
       notifyListeners();
     } else {
       SchedulerBinding.instance.addPostFrameCallback((_) {
         notifyListeners();
       });
     }
   }
   ```

3. **Apply _safeNotifyListeners() ke semua methods**
   - Ganti semua `notifyListeners()` dengan `_safeNotifyListeners()`
   - Konsistensi penting untuk menghindari error

### Priority 2: Architectural Improvements (Next Sprint)

1. **Separate Loading States**
   - Buat loading state per operation
   - Hindari global `_isLoading` flag

2. **Remove Nested fetchClassroom Calls**
   - Update local state instead of refetch
   - Atau gunakan optimistic update pattern

3. **Add Debouncing untuk NotifyListeners**
   ```dart
   Timer? _notifyTimer;
   
   void _debouncedNotifyListeners() {
     _notifyTimer?.cancel();
     _notifyTimer = Timer(const Duration(milliseconds: 16), () {
       _safeNotifyListeners();
     });
   }
   ```

### Priority 3: Long-term Refactor (Future)

1. **Consider Riverpod atau Bloc**
   - Riverpod: Built-in async state management
   - Bloc: Event-driven architecture
   - Lebih robust untuk complex state

2. **Implement Repository Pattern**
   - Separate data layer dari provider
   - Provider hanya handle UI state
   - Repository handle data fetching

3. **Add State Machine**
   - Use enum untuk state management
   - Clear state transitions
   - Easier to debug

---

## 🧪 **7. TESTING RECOMMENDATIONS**

### Test Cases untuk Verify Fix

1. **Test Build Phase Safety**
   ```dart
   testWidgets('should not call notifyListeners during build', (tester) async {
     await tester.pumpWidget(MyApp());
     // Navigate to classroom detail
     // Verify no errors
   });
   ```

2. **Test Concurrent Operations**
   ```dart
   test('should handle concurrent fetchClassrooms and fetchClassroom', () async {
     final provider = ClassroomProvider();
     unawaited(provider.fetchClassrooms());
     unawaited(provider.fetchClassroom(1));
     // Verify no race conditions
   });
   ```

3. **Test Nested Calls**
   ```dart
   test('removeMember should not cause multiple rebuilds', () async {
     // Verify notifyListeners called exactly 2 times
   });
   ```

---

## 📊 **8. METRICS & MONITORING**

### Metrics to Track

1. **Rebuild Count**
   - Track berapa kali Consumer rebuild
   - Target: Minimal rebuilds per operation

2. **Build Phase Errors**
   - Monitor error "setState during build"
   - Should be zero after fix

3. **Performance**
   - Measure time dari operation start sampai UI update
   - Compare before/after fix

---

## ✅ **9. CONCLUSION**

### Root Cause Summary

1. **Primary**: `fetchClassroom()` dipanggil di `initState()` tanpa `addPostFrameCallback`
2. **Secondary**: `Future.microtask` bukan solusi yang tepat untuk build phase issue
3. **Tertiary**: Global loading state menyebabkan rebuild cascade

### Solution Summary

1. **Immediate**: Fix `initState()` dengan `addPostFrameCallback`
2. **Short-term**: Replace `Future.microtask` dengan `SchedulerBinding`
3. **Long-term**: Refactor untuk separate loading states dan remove nested calls

### Expected Outcome

- ✅ Zero "setState during build" errors
- ✅ Consistent async loading pattern
- ✅ Better performance (fewer rebuilds)
- ✅ More maintainable codebase

---

## 📝 **10. CODE EXAMPLES**

### Example 1: Fixed classroom_info_screen.dart

```dart
@override
void initState() {
  super.initState();
  // ✅ FIX: Use addPostFrameCallback
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _fetchClassroomDetail();
  });
}

Future<void> _fetchClassroomDetail() async {
  final classroomProvider = Provider.of<ClassroomProvider>(
    context,
    listen: false,
  );

  if (mounted) {
    setState(() {
      _isLoading = true;
    });
  }

  try {
    await classroomProvider.fetchClassroom(widget.classroom.id);
    
    if (mounted) {
      setState(() {
        _detailedClassroom = classroomProvider.selectedClassroom;
        _isLoading = false;
      });
    }
  } catch (e) {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
```

### Example 2: Improved _safeNotifyListeners

```dart
import 'package:flutter/scheduler.dart';

void _safeNotifyListeners() {
  // ✅ Check if we're in build phase
  final scheduler = SchedulerBinding.instance;
  
  if (scheduler.schedulerPhase == SchedulerPhase.idle) {
    // Safe to notify immediately
    notifyListeners();
  } else {
    // Schedule for after build completes
    scheduler.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
```

### Example 3: Separate Loading States

```dart
class ClassroomProvider with ChangeNotifier {
  // ✅ Separate loading states
  bool _isLoadingClassrooms = false;
  bool _isLoadingClassroom = false;
  bool _isLoadingSchedules = false;
  
  bool get isLoadingClassrooms => _isLoadingClassrooms;
  bool get isLoadingClassroom => _isLoadingClassroom;
  bool get isLoadingSchedules => _isLoadingSchedules;
  
  Future<void> fetchClassrooms() async {
    if (_isLoadingClassrooms) return; // Prevent duplicate calls
    
    _isLoadingClassrooms = true;
    _errorMessage = null;
    _safeNotifyListeners();
    
    try {
      _classrooms = await _classroomService.getClassrooms();
      _isLoadingClassrooms = false;
      _safeNotifyListeners();
    } catch (e) {
      _isLoadingClassrooms = false;
      _errorMessage = e.toString();
      _safeNotifyListeners();
      rethrow;
    }
  }
  
  Future<void> fetchClassroom(int classroomId) async {
    if (_isLoadingClassroom) return; // Prevent duplicate calls
    
    _isLoadingClassroom = true;
    _errorMessage = null;
    _safeNotifyListeners();
    
    try {
      _selectedClassroom = await _classroomService.getClassroom(classroomId);
      _isLoadingClassroom = false;
      _safeNotifyListeners();
    } catch (e) {
      _isLoadingClassroom = false;
      _errorMessage = e.toString();
      _safeNotifyListeners();
      rethrow;
    }
  }
}
```

---

**End of Analysis**

