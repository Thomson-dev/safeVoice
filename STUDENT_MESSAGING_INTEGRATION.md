# Student Messaging Integration Guide

## Overview
This document explains how the student messaging feature is integrated into the SafeVoice app, allowing students to chat with counselors about their reports.

## Student Flow

### 1. **Student Submits Report**
```
Student Home → Report Incident → Submit
```
- Student fills out incident form
- Backend creates:
  - **Report** (with tracking code like `TRACK-C2BD47F9`)
  - **Case** (with case ID like `CASE-5798D9DC`)
- Student receives tracking code

### 2. **Student Opens "My Reports"**
```
Student Home → Track Report → Enter Tracking Code
```
- Student enters their tracking code
- App fetches report details from API: `GET /reports/{trackingCode}`
- Displays report status, details, and timeline

### 3. **Student Taps "Messages"**
```
Track Report Screen → Open Chat Button
```
- Student clicks "Open Chat" button in the Messages card
- App navigates to `ChatWithCounselorScreen` with `reportId`

### 4. **Chat Screen Opens**
```
ChatWithCounselorScreen(reportId: "694661bf1fc8781b06552050")
```
- Loads existing messages: `GET /messages/report/{reportId}`
- Auto-refreshes every 5 seconds
- Student can send messages: `POST /messages/student`

## Implementation Details

### Files Modified

#### 1. **track_report_screen.dart**
**Location:** `lib/features/student/screens/track_report_screen.dart`

**Changes:**
- Added import for `chat_with_counselor_screen.dart`
- Updated `_buildMessagesCard()` to include "Open Chat" button
- Added `_openChat()` method to navigate to chat screen

```dart
void _openChat(Map<String, dynamic> report) {
  final reportId = report['id'] ?? report['_id'] ?? report['reportId'];
  
  if (reportId == null || reportId.toString().isEmpty) {
    // Show error snackbar
    return;
  }

  Get.to(
    () => ChatWithCounselorScreen(reportId: reportId.toString()),
    transition: Transition.rightToLeft,
  );
}
```

#### 2. **chat_with_counselor_screen.dart**
**Location:** `lib/features/student/screens/chat_with_counselor_screen.dart`

**Enhancements:**
- ✅ Auto-refresh messages every 5 seconds
- ✅ Scroll to bottom when new messages arrive
- ✅ Beautiful gradient message bubbles
- ✅ Timestamp display (Today, Yesterday, X days ago)
- ✅ Loading states and empty states
- ✅ Optimistic UI updates (messages appear immediately)
- ✅ Error handling with delayed snackbars
- ✅ Refresh button in app bar
- ✅ Send button with loading indicator

**Key Features:**
```dart
// Auto-refresh timer
_refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
  fetchMessages(silent: true);
});

// Optimistic message sending
messages.add({
  'content': content,
  'fromCounselor': false,
  'createdAt': DateTime.now().toIso8601String(),
});

// Auto-scroll to bottom
_scrollController.animateTo(
  _scrollController.position.maxScrollExtent,
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeOut,
);
```

### API Endpoints Used

#### Get Messages
```
GET /messages/report/{reportId}
```
**Response:**
```json
{
  "messages": [
    {
      "content": "Hello, how can I help you?",
      "fromCounselor": true,
      "createdAt": "2025-12-20T10:30:00.000Z"
    },
    {
      "content": "I need help with my situation",
      "fromCounselor": false,
      "createdAt": "2025-12-20T10:31:00.000Z"
    }
  ]
}
```

#### Send Student Message
```
POST /messages/student
```
**Request:**
```json
{
  "reportId": "694661bf1fc8781b06552050",
  "content": "Thank you for your help"
}
```

### UI/UX Features

#### Track Report Screen - Messages Card
- **Before:** Static "No messages yet" text
- **After:** Interactive card with "Open Chat" button
- Gradient button matching app theme
- Clear call-to-action

#### Chat Screen Features
1. **Header**
   - Title: "Chat with Counselor"
   - Subtitle: "Secure & Confidential"
   - Refresh button

2. **Message Bubbles**
   - **Student messages:** Blue gradient, right-aligned
   - **Counselor messages:** White, left-aligned with "Counselor" label
   - Rounded corners with tail effect
   - Timestamps (smart formatting)
   - Max width 75% of screen

3. **Input Area**
   - Rounded text field
   - Send button with gradient background
   - Loading indicator when sending
   - Multi-line support (up to 4 lines)

4. **Empty State**
   - Large chat bubble icon
   - "No messages yet" heading
   - "Start a conversation" subtext

5. **Loading State**
   - Centered spinner
   - "Loading messages..." text

## Error Handling

### Snackbar Delays
All snackbars are delayed by 100ms to prevent "setState during build" errors:

```dart
Future.delayed(const Duration(milliseconds: 100), () {
  Get.snackbar('Error', 'Failed to send message', ...);
});
```

### Report ID Validation
Before opening chat, the app validates that a report ID exists:

```dart
if (reportId == null || reportId.toString().isEmpty) {
  Get.snackbar('Error', 'Unable to open chat. Report ID not found.');
  return;
}
```

### Silent Refresh
Auto-refresh doesn't show errors to avoid spamming the user:

```dart
fetchMessages(silent: true); // No error snackbars
```

## Testing Checklist

- [ ] Student can submit a report and receive tracking code
- [ ] Student can search for report using tracking code
- [ ] "Open Chat" button appears in Messages card
- [ ] Clicking "Open Chat" navigates to chat screen
- [ ] Chat screen loads existing messages
- [ ] Student can send messages
- [ ] Messages appear immediately (optimistic UI)
- [ ] Messages auto-refresh every 5 seconds
- [ ] Timestamps display correctly
- [ ] Scroll automatically goes to bottom
- [ ] Refresh button works
- [ ] Error handling works (no report ID, network errors)
- [ ] Empty state displays when no messages
- [ ] Loading state displays while fetching

## Future Enhancements

1. **Push Notifications**
   - Notify student when counselor sends a message
   - Use Firebase Cloud Messaging

2. **Read Receipts**
   - Show when counselor has read student's message
   - Add "seen" indicator

3. **Typing Indicators**
   - Show "Counselor is typing..." when counselor is composing

4. **File Attachments**
   - Allow students to send images/documents
   - Integrate with Cloudinary

5. **Message Search**
   - Search through message history
   - Filter by date range

6. **Offline Support**
   - Cache messages locally
   - Queue messages when offline

## Troubleshooting

### Messages not loading
- Check network connection
- Verify report ID is correct
- Check API endpoint is accessible
- Look for errors in console logs

### Messages not sending
- Verify authentication token is valid
- Check report ID exists in database
- Ensure message content is not empty
- Check API logs for errors

### Auto-refresh not working
- Verify timer is created in `initState`
- Check that timer is not cancelled prematurely
- Ensure `fetchMessages(silent: true)` is being called

### Scroll not working
- Verify `ScrollController` is attached to `ListView`
- Check that `_scrollController.hasClients` is true
- Ensure scroll is called in `addPostFrameCallback`

## Code Quality Notes

- ✅ All snackbars delayed to prevent build errors
- ✅ Proper disposal of controllers and timers
- ✅ Optimistic UI for better UX
- ✅ Silent refresh to avoid error spam
- ✅ Responsive design (75% max width for messages)
- ✅ Accessibility (proper labels and semantics)
- ✅ Error boundaries (try-catch blocks)
- ✅ Loading states for all async operations
