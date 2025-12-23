# Cloudinary Setup Guide

## Step 1: Create Cloudinary Account

1. Go to [https://cloudinary.com/](https://cloudinary.com/)
2. Sign up for a free account
3. After signing in, go to your Dashboard

## Step 2: Get Your Credentials

From your Cloudinary Dashboard, you'll see:
- **Cloud Name** (e.g., "my-cloud")
- **API Key** (e.g., "123456789012345")
- **API Secret** (keep this secure!)

## Step 3: Create Upload Preset

1. Go to Settings → Upload
2. Scroll to "Upload presets"
3. Click "Add upload preset"
4. Configure the preset:
   - **Preset name**: Choose a name (e.g., "safe_voice_reports")
   - **Signing Mode**: Select "Unsigned" (for client-side uploads)
   - **Folder**: Optionally specify a folder (e.g., "safe_voice/reports")
   - **Access mode**: "Public" (so counselors can view images)
5. Save the preset

## Step 4: Update Your Flutter App

Open `lib/core/services/cloudinary_service.dart` and update:

```dart
static const String cloudName = 'YOUR_CLOUD_NAME'; // Replace with your cloud name
static const String uploadPreset = 'YOUR_UPLOAD_PRESET'; // Replace with your preset name
```

## Example Configuration

```dart
// cloudinary_service.dart
static const String cloudName = 'my-cloud';
static const String uploadPreset = 'safe_voice_reports';
```

## Step 5: Test Upload

Run your app and try submitting a report with an image. Check your Cloudinary Media Library to verify the upload.

## Security Best Practices

1. **Use Unsigned Presets for Client Uploads**: This allows uploads without exposing your API secret
2. **Configure Upload Restrictions**: In your preset, you can limit:
   - File size (e.g., max 10MB)
   - Image dimensions
   - File formats (e.g., only jpg, png)
3. **Set Up Folders**: Organize uploads by feature (e.g., /safe_voice/reports)
4. **Enable Moderation**: Use Cloudinary's moderation features if needed

## Free Tier Limits

- 25 GB storage
- 25 GB bandwidth per month
- 25,000 transformations per month

This should be sufficient for development and small-scale production.

## Optional: Environment Variables

For better security, you can store credentials in environment variables:

1. Create a `.env` file (add to .gitignore):
```
CLOUDINARY_CLOUD_NAME=your-cloud-name
CLOUDINARY_UPLOAD_PRESET=your-upload-preset
```

2. Use flutter_dotenv package to load them
3. Never commit credentials to version control

## Troubleshooting

### Upload fails with "Invalid upload preset"
- Verify the preset name is correct
- Make sure the preset is set to "Unsigned"

### CORS errors
- Cloudinary should handle CORS automatically for image uploads
- If issues persist, check your Cloudinary CORS settings

### Large file uploads timeout
- Reduce image quality before upload
- Implement image compression using flutter_image_compress
- Increase Dio timeout in cloudinary_service.dart

## Additional Resources

- [Cloudinary Documentation](https://cloudinary.com/documentation)
- [Upload Presets Guide](https://cloudinary.com/documentation/upload_presets)
- [Flutter Integration](https://cloudinary.com/documentation/flutter_integration)
