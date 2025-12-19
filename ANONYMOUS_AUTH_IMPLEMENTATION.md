# Anonymous but Controlled Authentication - Implementation Summary

## ✅ What's Been Implemented

### 1. **Updated User Model** (`lib/core/models/user.dart`)
```dart
User {
  id               // Backend UUID
  role             // 'student' or 'counselor'
  email            // Optional for students, required for counselors
  
  // Student fields
  anonymousId      // ANON-12345 (what counselor sees)
  displayName      // Optional nickname
  
  // Counselor fields
  fullName         // Required name
  licenseNumber    // Professional license
  isVerified       // Admin verification status
}
```

### 2. **Updated Report Model** (`lib/core/models/report.dart`)
```dart
Report {
  id
  trackingCode     // ABC123DEF
  userId           // Links to student account (backend only)
  anonymousId      // ANON-12345 (counselor view)
  incidentType
  description
  urgencyLevel     // critical, high, medium, low
  status           // submitted, under_review, resolved, escalated
  assignedCounselorId
  ...
}
```

### 3. **Authentication Service** (`lib/core/services/auth_service.dart`)
Handles anonymous but controlled registration:

**For Students:**
- `registerStudent()` - Creates account with anonymousId
- No real name required
- Optional email for recovery
- Gets ANON-##### ID automatically

**For Counselors:**
- `registerCounselor()` - Requires full name + license
- Email verification required
- Admin must approve (isVerified flag)

**Both:**
- `login()` - Email/password authentication
- JWT token storage
- Session management

### 4. **Authentication Controller** (`lib/app/controllers/auth_controller.dart`)
Manages authentication state:
- `registerStudent()` - Student signup flow
- `registerCounselor()` - Counselor signup flow  
- `login()` - Universal login
- `logout()` - Clear session
- `currentUser` - Observable user state
- `displayName` - Get public-facing name

### 5. **Updated Report Controller** (`lib/app/controllers/report_controller.dart`)
Now links reports to user accounts:
- Automatically adds `userId` and `anonymousId` to reports
- Maintains anonymity (counselors only see ANON-ID)
- Groups reports by same student

## 🔄 How It Works

### **Student Journey:**
```
1. Opens app → Registers (no name required)
   ↓
2. Gets userId: "550e8400..." + anonymousId: "ANON-19284"
   ↓
3. Submits report → Backend stores userId, displays ANON-19284 to counselor
   ↓
4. Submits another report → Counselor sees same ANON-19284
   ↓
5. Receives counselor messages via userId (counselor never learns identity)
```

### **Counselor Journey:**
```
1. Opens app → Registers with real name + license
   ↓
2. Admin approves account (isVerified = true)
   ↓
3. Views reports → Sees anonymousIds (ANON-12345, ANON-67890)
   ↓
4. Can track patterns → "ANON-19284 has 3 escalating reports"
   ↓
5. Messages students → Uses anonymousId, never sees real identity
```

## 🎯 Benefits

### **For Students:**
✅ Truly anonymous - no real name required  
✅ Account benefits - track multiple reports  
✅ Optional recovery - email for password reset  
✅ Privacy protected - counselors never see identity

### **For Counselors:**
✅ Verified professionals - admin approval  
✅ Case tracking - group reports by anonymousId  
✅ Pattern detection - spot escalating situations  
✅ Accountability - all actions logged

### **For System:**
✅ Spam prevention - accounts stop abuse  
✅ Case linking - connect related reports  
✅ Analytics - track patterns without exposing identity  
✅ Legal compliance - maintain records + anonymity

## 📋 Next Steps

### **To Connect to Real Backend:**

1. **Replace mock functions in AuthService with actual API calls:**
```dart
// In lib/core/services/auth_service.dart
Future<Map<String, dynamic>> registerStudent(...) async {
  final response = await http.post(
    Uri.parse('$API_URL/api/auth/register/student'),
    body: jsonEncode({
      'password': password,
      'email': email,
      'displayName': displayName,
    }),
  );
  // Handle response
}
```

2. **Add HTTP package to pubspec.yaml:**
```yaml
dependencies:
  http: ^1.1.0
```

3. **Create API constants:**
```dart
// lib/core/constants/api_constants.dart
class ApiConstants {
  static const String baseUrl = 'https://your-api.com';
  static const String registerStudent = '/api/auth/register/student';
  static const String registerCounselor = '/api/auth/register/counselor';
  static const String login = '/api/auth/login';
  static const String submitReport = '/api/reports';
}
```

4. **Backend API endpoints needed:**
```
POST /api/auth/register/student
POST /api/auth/register/counselor
POST /api/auth/login
GET  /api/auth/profile
POST /api/reports
GET  /api/reports/:trackingCode
GET  /api/reports (counselor: all reports)
PATCH /api/reports/:id/status
```

## 🔐 Security Notes

- JWT tokens stored in GetStorage (encrypted)
- Passwords never stored locally
- anonymousId generated server-side (prevent manipulation)
- userId never exposed in UI
- Counselor verification required before access
- All API calls should use HTTPS
- Token expiration handling needed

## 📝 Database Schema Needed

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY,
  anonymous_id VARCHAR(20) UNIQUE,
  email VARCHAR(255) UNIQUE,
  password_hash VARCHAR(255),
  role ENUM('student', 'counselor'),
  display_name VARCHAR(50),
  full_name VARCHAR(100),
  license_number VARCHAR(50),
  is_verified BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE reports (
  id UUID PRIMARY KEY,
  tracking_code VARCHAR(10) UNIQUE,
  user_id UUID REFERENCES users(id),
  anonymous_id VARCHAR(20),
  incident_type VARCHAR(100),
  description TEXT,
  urgency_level VARCHAR(20),
  status VARCHAR(20),
  assigned_counselor_id UUID REFERENCES users(id),
  submitted_at TIMESTAMP DEFAULT NOW()
);
```

## 🎨 UI Updates Needed

Update role selection screen to:
1. Show separate forms for student vs counselor registration
2. Student form: password + optional email/nickname
3. Counselor form: email + password + full name + license number
4. Add login option for returning users

Current status: Models and controllers ready, UI needs updating.
