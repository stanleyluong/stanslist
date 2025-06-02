# AWS Amplify Deployment Guide for Stan's List

## Overview
This guide will help you deploy your Flutter web application "Stan's List" to AWS Amplify with proper Firebase integration and environment variable configuration.

## Prerequisites
✅ Flutter web build completed successfully
✅ Firebase project configured
✅ All environment variables identified
✅ `amplify.yml` configuration file created

## Deployment Steps

### 1. AWS Account Setup
1. Sign in to [AWS Console](https://aws.amazon.com/console/)
2. Navigate to AWS Amplify service
3. Ensure you have appropriate IAM permissions for Amplify

### 2. Create New Amplify App
1. In AWS Amplify console, click **"New app"** → **"Host web app"**
2. Choose your Git provider (GitHub, GitLab, Bitbucket, etc.)
3. Select the repository containing your Flutter app
4. Choose the branch to deploy (typically `main` or `master`)

### 3. Build Settings Configuration
AWS Amplify should automatically detect your `amplify.yml` file. If not, configure:

```yaml
version: 1
frontend:
  phases:
    preBuild:
      commands:
        - sudo yum update -y
        - sudo yum install -y --allowerasing curl git unzip xz zip mesa-libGLU python3
        - rm -rf flutter
        - git clone https://github.com/flutter/flutter.git -b 3.22.0 --depth 1
        - 'export PATH="$PATH:`pwd`/flutter/bin"'
        - flutter doctor -v
        - flutter clean
        - flutter pub get
    build:
      commands:
        - flutter build web -v --release --dart-define=FLUTTER_WEB_USE_SKIA=true --dart-define=FIREBASE_API_KEY=$FIREBASE_API_KEY --dart-define=FIREBASE_APP_ID=$FIREBASE_APP_ID --dart-define=FIREBASE_MESSAGING_SENDER_ID=$FIREBASE_MESSAGING_SENDER_ID --dart-define=FIREBASE_PROJECT_ID=$FIREBASE_PROJECT_ID --dart-define=FIREBASE_AUTH_DOMAIN=$FIREBASE_AUTH_DOMAIN --dart-define=FIREBASE_STORAGE_BUCKET=$FIREBASE_STORAGE_BUCKET --dart-define=FIREBASE_MEASUREMENT_ID=$FIREBASE_MEASUREMENT_ID --dart-define=GOOGLE_MAPS_API_KEY=$GOOGLE_MAPS_API_KEY --dart-define=GOOGLE_SIGN_IN_CLIENT_ID=$GOOGLE_SIGN_IN_CLIENT_ID --dart-define=GOOGLE_SIGN_IN_SERVER_CLIENT_ID=$GOOGLE_SIGN_IN_SERVER_CLIENT_ID
  artifacts:
    baseDirectory: build/web
    files:
      - '**/*'
  cache:
    paths:
      - $HOME/.pub-cache/**/*
      - flutter/**/*
```

### 4. Environment Variables Configuration
In the Amplify console, navigate to **App settings** → **Environment variables** and add:

#### Firebase Configuration
- `FIREBASE_API_KEY`: Your Firebase API key
- `FIREBASE_AUTH_DOMAIN`: Your Firebase auth domain
- `FIREBASE_PROJECT_ID`: Your Firebase project ID
- `FIREBASE_STORAGE_BUCKET`: Your Firebase storage bucket
- `FIREBASE_MESSAGING_SENDER_ID`: Your Firebase messaging sender ID
- `FIREBASE_APP_ID`: Your Firebase app ID
- `FIREBASE_MEASUREMENT_ID`: Your Firebase measurement ID

#### Google Services
- `GOOGLE_MAPS_API_KEY`: Your Google Maps API key
- `GOOGLE_SIGN_IN_CLIENT_ID`: Your Google Sign-In client ID
- `GOOGLE_SIGN_IN_SERVER_CLIENT_ID`: Your Google Sign-In server client ID

### 5. Advanced Settings (Optional but Recommended)

#### Custom Headers (for security)
Navigate to **App settings** → **Rewrites and redirects** and add:
```
Source: /<*>
Target: /index.html
Type: 200 (Rewrite)
```

#### Performance Optimizations
- Enable **Amplify Performance Mode** if available
- Configure caching headers for static assets

### 6. Domain Configuration (Optional)
1. In **App settings** → **Domain management**
2. Add custom domain if you have one
3. Configure SSL certificate (handled automatically by Amplify)

## Deployment Process

### Initial Deployment
1. Click **"Save and deploy"** in the Amplify console
2. Monitor the build process in the console
3. Build typically takes 5-10 minutes for Flutter web apps

### Monitoring Build
- Watch the build logs for any errors
- Common issues and solutions are listed below

## Common Build Issues and Solutions

### 1. Flutter SDK Download Issues
If Flutter SDK download fails:
- Check the Flutter version in `amplify.yml` (currently set to 3.22.0)
- Ensure internet connectivity during build

### 2. Environment Variable Issues
If environment variables are not recognized:
- Verify all variables are set in Amplify console
- Check variable names match exactly (case-sensitive)
- Ensure no extra spaces in variable values

### 3. Memory Issues
If build runs out of memory:
- Contact AWS support to increase build instance size
- Or optimize your Flutter dependencies

### 4. Firebase Configuration Issues
If Firebase doesn't initialize:
- Verify all Firebase environment variables are set
- Check Firebase project permissions
- Ensure Firebase SDK versions are compatible

## Post-Deployment Verification

### 1. Functional Testing
- [ ] App loads without errors
- [ ] Firebase authentication works
- [ ] Firestore database operations work
- [ ] Google Maps integration works
- [ ] File upload to Firebase Storage works
- [ ] All navigation and features work as expected

### 2. Performance Testing
- [ ] Page load times are acceptable
- [ ] Mobile responsiveness works
- [ ] Images and assets load properly

### 3. Security Testing
- [ ] Environment variables are not exposed in browser
- [ ] Firebase security rules are properly configured
- [ ] HTTPS is enforced

## Continuous Deployment

Once deployed, Amplify will automatically:
- Redeploy when you push to the connected branch
- Run the build process with your latest code
- Update the live application

## Useful Commands for Local Testing

Before deploying, test locally:
```bash
# Build for web with all environment variables
flutter build web --release \
  --dart-define=FIREBASE_API_KEY=your_key \
  --dart-define=FIREBASE_AUTH_DOMAIN=your_domain \
  --dart-define=FIREBASE_PROJECT_ID=your_project_id \
  --dart-define=FIREBASE_STORAGE_BUCKET=your_bucket \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=your_sender_id \
  --dart-define=FIREBASE_APP_ID=your_app_id \
  --dart-define=FIREBASE_MEASUREMENT_ID=your_measurement_id \
  --dart-define=GOOGLE_MAPS_API_KEY=your_maps_key \
  --dart-define=GOOGLE_SIGN_IN_CLIENT_ID=your_client_id \
  --dart-define=GOOGLE_SIGN_IN_SERVER_CLIENT_ID=your_server_client_id

# Serve locally to test
cd build/web && python3 -m http.server 8000
```

## Support and Troubleshooting

### AWS Amplify Console
- Monitor build logs in real-time
- Check deployment history
- Access error details and stack traces

### Flutter Web Debugging
- Use browser developer tools
- Check console for JavaScript errors
- Verify network requests to Firebase

### Contact Information
- AWS Amplify Support: [AWS Support Center](https://console.aws.amazon.com/support/)
- Flutter Documentation: [flutter.dev](https://flutter.dev)
- Firebase Documentation: [firebase.google.com](https://firebase.google.com/docs)

---

## Next Steps After Deployment

1. **Test thoroughly** - Verify all functionality works in the deployed environment
2. **Monitor performance** - Use AWS CloudWatch and Amplify analytics
3. **Set up monitoring** - Configure alerts for build failures or performance issues
4. **Plan updates** - Establish a deployment workflow for future updates
5. **Backup strategy** - Ensure your code is backed up and version controlled

Good luck with your deployment! 🚀
