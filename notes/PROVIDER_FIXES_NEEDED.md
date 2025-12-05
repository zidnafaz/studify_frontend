# Provider Fixes Needed - Analysis

## 📊 **CURRENT STATUS**

### ✅ **Already Fixed:**
- `ClassroomProvider` - ✅ Sudah menggunakan `_safeNotifyListeners()`
- `classroom_info_screen.dart` - ✅ Sudah menggunakan `addPostFrameCallback`

### ❌ **Needs Fix:**

#### 1. **PersonalScheduleProvider**
- **Status**: ❌ Masih menggunakan `notifyListeners()` langsung
- **Methods yang perlu fix**: 4 methods
  - `fetchPersonalSchedules()` - 4x `notifyListeners()`
  - `createPersonalSchedule()` - 4x `notifyListeners()`
  - `updatePersonalSchedule()` - 4x `notifyListeners()`
  - `deletePersonalSchedule()` - 4x `notifyListeners()`
- **Total**: 16 occurrences

#### 2. **CombinedScheduleProvider**
- **Status**: ❌ Masih menggunakan `notifyListeners()` langsung
- **Methods yang perlu fix**: 2 methods
  - `fetchCombinedSchedules()` - 4x `notifyListeners()`
  - `clear()` - 1x `notifyListeners()`
- **Total**: 5 occurrences

#### 3. **AuthProvider**
- **Status**: ⚠️ **PRIORITY LOW** - Biasanya dipanggil dari user action, bukan build phase
- **Methods yang perlu fix**: 5 methods
  - `checkAuthStatus()` - 2x `notifyListeners()`
  - `register()` - 4x `notifyListeners()`
  - `login()` - 5x `notifyListeners()`
  - `logout()` - 1x `notifyListeners()`
  - `refreshToken()` - 1x `notifyListeners()`
  - `clearError()` - 1x `notifyListeners()`
- **Total**: 14 occurrences
- **Note**: `checkAuthStatus()` dipanggil di `AuthWrapper.initState()` dengan `addPostFrameCallback` ✅, tapi tetap perlu fix untuk konsistensi

---

## 🎯 **RECOMMENDATION**

### **Priority 1: High Risk (Fix Immediately)**
1. ✅ **ClassroomProvider** - **DONE**
2. ❌ **PersonalScheduleProvider** - **NEEDS FIX**
3. ❌ **CombinedScheduleProvider** - **NEEDS FIX**

**Reason**: Provider ini sering dipanggil dari `initState()` atau build phase, berisiko tinggi menyebabkan "setState during build" error.

### **Priority 2: Medium Risk (Fix for Consistency)**
4. ⚠️ **AuthProvider** - **OPTIONAL** (biasanya dipanggil dari user action, tapi `checkAuthStatus()` dipanggil di initState)

---

## 📝 **IMPLEMENTATION PLAN**

### Step 1: Create `_safeNotifyListeners()` Helper

**Template untuk semua provider:**
```dart
import 'package:flutter/scheduler.dart';

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

### Step 2: Replace All `notifyListeners()` with `_safeNotifyListeners()`

**Find & Replace Pattern:**
```dart
// Find:
notifyListeners();

// Replace:
_safeNotifyListeners();
```

---

## 🔍 **WIDGET CHECKLIST**

### ✅ **Already Using addPostFrameCallback:**
- `home_screen.dart` - ✅
- `classroom_info_screen.dart` - ✅
- `classroom_detail_screen.dart` - ✅
- `classroom_list_screen.dart` - ✅
- `personal_schedule_screen.dart` - ✅

### ⚠️ **Need to Check:**
- `repeat_selection_sheet.dart` - Need to verify
- `edit_personal_schedule_sheet.dart` - Need to verify
- `edit_class_schedule_sheet.dart` - Need to verify
- `class_schedule_detail_sheet.dart` - Need to verify

---

## 📊 **IMPACT ANALYSIS**

### **Risk Level:**
- **High**: PersonalScheduleProvider, CombinedScheduleProvider
  - Sering dipanggil dari `initState()` di home screen
  - Bisa trigger error jika dipanggil selama build phase
  
- **Medium**: AuthProvider
  - `checkAuthStatus()` dipanggil di `AuthWrapper.initState()` dengan `addPostFrameCallback` ✅
  - Method lain biasanya dipanggil dari user action (button click)
  - Tapi tetap perlu fix untuk konsistensi

### **Benefits of Fixing:**
1. ✅ **Consistency** - Semua provider menggunakan pattern yang sama
2. ✅ **Prevention** - Mencegah error di masa depan
3. ✅ **Maintainability** - Code lebih mudah di-maintain
4. ✅ **Best Practice** - Mengikuti Flutter best practices

---

## ✅ **CONCLUSION**

**Yes, semua provider lain juga perlu diterapkan fix yang sama untuk:**
1. **Konsistensi** - Semua provider menggunakan pattern yang sama
2. **Prevention** - Mencegah error "setState during build" di masa depan
3. **Best Practice** - Mengikuti Flutter best practices

**Priority:**
1. **PersonalScheduleProvider** - HIGH (sering dipanggil dari initState)
2. **CombinedScheduleProvider** - HIGH (sering dipanggil dari initState)
3. **AuthProvider** - MEDIUM (biasanya dari user action, tapi perlu konsistensi)

