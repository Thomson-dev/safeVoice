# Testing Trusted Contacts API Integration

## Quick Test Guide

### Prerequisites
1. Backend server running on `http://localhost:3002`
2. Valid authentication token
3. Flutter app running

## Test Sequence

### 1. Get Your Auth Token
After logging in as a student, check the console logs or use:
```dart
// In your app
final token = Get.find<AuthService>().getAuthToken();
print('Token: $token');
```

### 2. Test DELETE Endpoint

#### Using cURL:
```bash
# First, get a contact ID by listing contacts
curl -X GET http://localhost:3002/api/student/contacts \
  -H "Authorization: Bearer <YOUR_TOKEN>"

# Then delete using the contact ID
curl -X DELETE http://localhost:3002/api/student/contacts/603abc... \
  -H "Authorization: Bearer <YOUR_TOKEN>"
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Contact deleted"
}
```

#### Using PowerShell:
```powershell
# List contacts
Invoke-RestMethod -Method Get -Uri http://localhost:3002/api/student/contacts `
  -Headers @{"Authorization"="Bearer <YOUR_TOKEN>"}

# Delete contact
Invoke-RestMethod -Method Delete -Uri http://localhost:3002/api/student/contacts/603abc... `
  -Headers @{"Authorization"="Bearer <YOUR_TOKEN>"}
```

### 3. Test in Flutter App

1. **Open Trusted Contacts Screen**
   - Navigate to Settings → Trusted Contacts
   
2. **Add a Contact**
   - Tap "Add new"
   - Select a contact from your phone
   - Check console logs for: `TrustedContactController: Contact added via API`

3. **Delete a Contact**
   - Tap the menu (⋮) on any contact
   - Select "Delete"
   - Confirm deletion
   - Check console logs for: `TrustedContactController: Contact deleted via API`

### 4. Verify API Integration

Watch the console logs. You should see:

**On Add:**
```
ContactService: Adding trusted contact - Friend 1
ContactService: Response status: 201
ContactService: Response data: {...}
TrustedContactController: Contact added via API
```

**On Delete:**
```
ContactService: Deleting contact - 603abc...
ContactService: Response status: 200
ContactService: Response data: {success: true, message: Contact deleted}
TrustedContactController: Contact deleted via API
```

### 5. Test Offline Mode

1. Stop the backend server
2. Try adding/deleting contacts
3. Should see: `TrustedContactController: API delete failed, using local: ...`
4. Contacts should still work using local storage

## Common Issues

### Issue: "Failed to delete contact"
**Solution:** Check if:
- Backend server is running
- Auth token is valid
- Contact ID exists

### Issue: "Network error"
**Solution:** 
- Verify backend URL is correct
- Check if server is accessible
- Ensure no CORS issues

### Issue: Contact deleted in app but not in backend
**Solution:**
- Check console logs
- Verify API was called successfully
- Check backend database

## Success Indicators

✅ Contact disappears from UI immediately
✅ Console shows "Contact deleted via API"
✅ Backend returns `{ "success": true, "message": "Contact deleted" }`
✅ Contact is removed from both local storage and backend
✅ Reload shows contact is still gone

## Full Integration Test

```bash
# 1. Add a contact
curl -X POST http://localhost:3002/api/student/contacts \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"name":"Test Contact","phone":"+15551234567"}'

# 2. List contacts (get the ID)
curl -X GET http://localhost:3002/api/student/contacts \
  -H "Authorization: Bearer <TOKEN>"

# 3. Update the contact
curl -X PATCH http://localhost:3002/api/student/contacts/<ID> \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"name":"Updated Name"}'

# 4. Delete the contact
curl -X DELETE http://localhost:3002/api/student/contacts/<ID> \
  -H "Authorization: Bearer <TOKEN>"

# 5. Verify it's gone
curl -X GET http://localhost:3002/api/student/contacts \
  -H "Authorization: Bearer <TOKEN>"
```

## Notes

- The app uses **API-first** approach with **local storage fallback**
- All operations sync between API and local storage
- Works offline with local storage only
- Automatic retry logic for failed API calls
- Console logs show which data source is being used
