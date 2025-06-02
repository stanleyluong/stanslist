# Stan's List - AWS Amplify Deployment Checklist

## Pre-Deployment Checklist ✅
- [x] Flutter web build completed successfully
- [x] All dependencies resolved (48,720,675 input bytes compiled)
- [x] Firebase configuration working with environment variables
- [x] Google Maps integration verified with API key
- [x] Production build generated in build/web directory
- [x] All required environment variables identified:
  - [x] FIREBASE_API_KEY
  - [x] FIREBASE_AUTH_DOMAIN
  - [x] FIREBASE_PROJECT_ID
  - [x] FIREBASE_STORAGE_BUCKET
  - [x] FIREBASE_MESSAGING_SENDER_ID
  - [x] FIREBASE_APP_ID
  - [x] FIREBASE_MEASUREMENT_ID
  - [x] GOOGLE_MAPS_API_KEY
  - [x] GOOGLE_CLIENT_ID
- [x] amplify.yml configuration file created

## AWS Amplify Setup
- [ ] AWS account access verified
- [ ] Amplify service accessible in AWS Console
- [ ] IAM permissions confirmed for Amplify deployment

## Amplify App Configuration
- [ ] New Amplify app created
- [ ] Git repository connected (GitHub/GitLab/Bitbucket)
- [ ] Correct branch selected for deployment
- [ ] Build settings configured (amplify.yml detected)

## Environment Variables Setup
- [ ] Firebase environment variables added to Amplify console:
  - [ ] FIREBASE_API_KEY
  - [ ] FIREBASE_AUTH_DOMAIN
  - [ ] FIREBASE_PROJECT_ID
  - [ ] FIREBASE_STORAGE_BUCKET
  - [ ] FIREBASE_MESSAGING_SENDER_ID
  - [ ] FIREBASE_APP_ID
  - [ ] FIREBASE_MEASUREMENT_ID
- [ ] Google services environment variables added:
  - [ ] GOOGLE_MAPS_API_KEY
  - [ ] GOOGLE_SIGN_IN_CLIENT_ID
  - [ ] GOOGLE_SIGN_IN_SERVER_CLIENT_ID

## Optional Configuration
- [ ] Custom domain configured (if needed)
- [ ] SSL certificate configured (automatic with Amplify)
- [ ] Custom headers configured for security
- [ ] Rewrites and redirects configured for SPA routing
- [ ] Performance optimizations enabled

## Deployment Process
- [ ] Initial deployment triggered
- [ ] Build process monitored for errors
- [ ] Build completed successfully
- [ ] Application accessible via Amplify URL

## Post-Deployment Verification

### Functionality Testing
- [ ] Application loads without errors
- [ ] Firebase authentication works
  - [ ] Google Sign-In functional
  - [ ] User registration/login works
  - [ ] Session persistence works
- [ ] Firestore database operations work
  - [ ] Data reading works
  - [ ] Data writing works
  - [ ] Real-time updates work
- [ ] Firebase Storage works
  - [ ] File uploads functional
  - [ ] Image display works
- [ ] Google Maps integration works
  - [ ] Maps load correctly
  - [ ] Location services work
  - [ ] Map interactions work
- [ ] Navigation and routing work
  - [ ] All pages accessible
  - [ ] Deep linking works
  - [ ] Back/forward browser buttons work

### Performance Testing
- [ ] Page load times acceptable (< 3 seconds)
- [ ] Mobile responsiveness works
- [ ] Images and assets load properly
- [ ] No console errors in browser developer tools

### Security Verification
- [ ] Environment variables not exposed in browser
- [ ] HTTPS enforced on all pages
- [ ] Firebase security rules properly configured
- [ ] No sensitive data exposed in client-side code

## CI/CD Setup
- [ ] Automatic deployments configured
- [ ] Build triggers set up for main branch
- [ ] Deployment notifications configured (optional)

## Monitoring and Maintenance
- [ ] AWS CloudWatch monitoring set up
- [ ] Amplify analytics configured
- [ ] Error tracking enabled
- [ ] Performance monitoring in place

## Documentation and Backup
- [ ] Deployment process documented
- [ ] Environment variables backed up securely
- [ ] Recovery procedures documented
- [ ] Team access configured (if applicable)

---

## Environment Variables Reference

### Firebase Configuration
```
FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_STORAGE_BUCKET=your_project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_APP_ID=your_app_id
FIREBASE_MEASUREMENT_ID=G-your_measurement_id
```

### Google Services
```
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
GOOGLE_SIGN_IN_CLIENT_ID=your_client_id.googleusercontent.com
GOOGLE_SIGN_IN_SERVER_CLIENT_ID=your_server_client_id.googleusercontent.com
```

---

## Quick Deployment Commands

### Local Build Test
```bash
flutter build web --release \
  --dart-define=FIREBASE_API_KEY=$FIREBASE_API_KEY \
  --dart-define=FIREBASE_AUTH_DOMAIN=$FIREBASE_AUTH_DOMAIN \
  --dart-define=FIREBASE_PROJECT_ID=$FIREBASE_PROJECT_ID \
  --dart-define=FIREBASE_STORAGE_BUCKET=$FIREBASE_STORAGE_BUCKET \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=$FIREBASE_MESSAGING_SENDER_ID \
  --dart-define=FIREBASE_APP_ID=$FIREBASE_APP_ID \
  --dart-define=FIREBASE_MEASUREMENT_ID=$FIREBASE_MEASUREMENT_ID \
  --dart-define=GOOGLE_MAPS_API_KEY=$GOOGLE_MAPS_API_KEY \
  --dart-define=GOOGLE_SIGN_IN_CLIENT_ID=$GOOGLE_SIGN_IN_CLIENT_ID \
  --dart-define=GOOGLE_SIGN_IN_SERVER_CLIENT_ID=$GOOGLE_SIGN_IN_SERVER_CLIENT_ID
```

### Local Testing
```bash
cd build/web && python3 -m http.server 8000
```

---

## Troubleshooting Quick Reference

### Build Fails
1. Check Flutter SDK version in amplify.yml
2. Verify all environment variables are set
3. Check build logs for specific errors
4. Ensure pubspec.yaml dependencies are compatible

### App Doesn't Load
1. Check browser console for JavaScript errors
2. Verify Firebase configuration
3. Check network requests in browser dev tools
4. Ensure all assets are loading properly

### Authentication Issues
1. Verify Firebase Auth is enabled
2. Check Google OAuth configuration
3. Ensure authorized domains include Amplify URL
4. Verify client IDs match Firebase project

### Database Issues
1. Check Firestore security rules
2. Verify Firebase project ID
3. Check network connectivity to Firebase
4. Ensure proper Firebase initialization

---

**Status**: Ready for AWS Amplify deployment
**Last Updated**: Ready for deployment
**Next Action**: Begin AWS Amplify setup in AWS Console
