# Image Upload Troubleshooting Guide

## Enhanced Features Added

### ✅ What's New:
1. **Detailed Progress Tracking** - Shows upload percentage and stage
2. **Visual Feedback** - Animated progress bar with status emojis
3. **Comprehensive Logging** - Detailed console output for debugging
4. **Success Notifications** - Green popup when image uploads successfully
5. **Better Error Messages** - Clear error descriptions

## How to Debug Upload Issues

### Step 1: Check Console Logs

When you submit a report with an image, watch for these logs:

```
✅ GOOD LOGS (Upload Working):
CloudinaryService: Starting upload to Cloudinary
CloudinaryService: File path: /data/user/0/.../image.jpg
CloudinaryService: File exists: true
CloudinaryService: File size: 245678 bytes
CloudinaryService: Upload progress: 25.0% (...)
CloudinaryService: Upload progress: 50.0% (...)
CloudinaryService: Upload progress: 100.0% (...)
CloudinaryService: ✅ SUCCESS!
CloudinaryService: Image URL: https://res.cloudinary.com/...
ReportController: ✅ Images uploaded successfully!
```

```
❌ BAD LOGS (Upload Failing):
CloudinaryService: ❌ DioException occurred
CloudinaryService: Error type: [error type]
CloudinaryService: Error message: [error description]
```

### Step 2: Common Issues & Solutions

#### Issue 1: "Invalid upload preset"
**Symptom:** Error message mentions upload preset
**Solution:**
1. Go to Cloudinary Dashboard → Settings → Upload
2. Check your upload preset name matches: `safe-voice`
3. Ensure preset is set to **"Unsigned"** mode

#### Issue 2: "Network error"
**Symptom:** No response from Cloudinary
**Solution:**
1. Check internet connection
2. Try uploading smaller image
3. Check if Cloudinary is accessible: https://cloudinary.com

#### Issue 3: Image not uploading at all
**Symptom:** Progress stays at 0% or 5%
**Check:**
1. File exists (look for `File exists: true` in logs)
2. File size (should be > 0 bytes)
3. File path is valid

#### Issue 4: "Failed to upload image: type 'Null' is not a subtype"
**Solution:** 
1. Check Cloudinary credentials are correct in `cloudinary_service.dart`:
   - cloudName: `ddwmcikmw`
   - uploadPreset: `safe-voice`

### Step 3: Test Upload Directly

Create a simple test to isolate the issue:

```dart
// Add this temporary test function
void testCloudinaryUpload() async {
  try {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      print('📸 Image selected: ${image.path}');
      
      final cloudinary = CloudinaryService();
      final url = await cloudinary.uploadImage(
        File(image.path),
        onProgress: (progress) {
          print('Progress: ${(progress * 100).toInt()}%');
        },
      );
      
      print('✅ Upload successful!');
      print('URL: $url');
    }
  } catch (e) {
    print('❌ Test failed: $e');
  }
}
```

### Step 4: Verify Cloudinary Setup

1. **Login to Cloudinary:** https://cloudinary.com/console
2. **Check Dashboard:**
   - Cloud Name should be: `ddwmcikmw`
   - Go to Media Library after upload to see if image appears

3. **Verify Upload Preset:**
   - Settings → Upload → Upload presets
   - Find preset named: `safe-voice`
   - Mode: **Unsigned** ✓
   - Folder: `safe_voice/reports` (optional)

### Step 5: Check Image File

Before upload, verify:
```dart
final file = File(imagePath);
print('File exists: ${await file.exists()}');
print('File size: ${await file.length()} bytes');
print('File path: ${file.path}');
```

Expected output:
- File exists: `true`
- File size: Greater than 0 (e.g., `245678 bytes`)
- File path: Valid absolute path

## What You Should See

### During Upload:
1. Progress dialog appears with animated circle
2. Status changes:
   - 📋 "Preparing upload..." (0-5%)
   - ☁️ "Uploading image to cloud..." (5-50%)
   - 📤 "Submitting report..." (50-80%)
   - ✨ "Finalizing..." (80-100%)
3. Percentage updates in real-time
4. Progress bar color changes from blue to green at 50%

### On Success:
- Green notification: "✓ Image Uploaded - Evidence uploaded successfully"
- Progress dialog closes
- Success dialog shows with tracking code
- Console shows: `CloudinaryService: ✅ SUCCESS!`

### On Failure:
- Orange warning: "⚠️ Upload Warning - [Error details]"
- Report still submits (without image)
- Console shows: `CloudinaryService: ❌ DioException occurred`

## Quick Fix Checklist

Before asking for help, verify:

- [ ] Internet connection is working
- [ ] Cloudinary credentials are correct in code
- [ ] Upload preset exists and is "Unsigned"
- [ ] Image file exists and is not corrupted
- [ ] Image size is reasonable (< 10MB)
- [ ] Console logs show detailed error messages
- [ ] Tried with different images
- [ ] Restarted the app

## Getting Help

If upload still fails, provide:

1. **Console logs** (copy full log output)
2. **Image details:**
   - File size
   - Format (jpg, png, etc.)
   - Source (gallery/camera)
3. **Error message** from orange notification
4. **Cloudinary settings** screenshot

## Expected Timeline

- Small image (< 1MB): 2-5 seconds
- Medium image (1-3MB): 5-10 seconds
- Large image (3-10MB): 10-30 seconds

Progress updates every 100ms during upload.

## Success Indicators

✅ Image uploaded when you see:
- Progress reaches 100%
- Green success notification
- Image URL in console (starts with `https://res.cloudinary.com/`)
- Image appears in Cloudinary Media Library

Now test your upload and watch the console! 🚀
