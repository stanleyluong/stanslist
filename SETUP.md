# Development Setup Guide

## Prerequisites

Before running Stan's List, you need to install Flutter SDK.

### Install Flutter

1. **Download Flutter SDK**:
   ```bash
   # Download Flutter for macOS
   cd ~/development
   git clone https://github.com/flutter/flutter.git -b stable
   ```

2. **Add Flutter to PATH**:
   Add this to your `~/.zshrc` file:
   ```bash
   export PATH="$PATH:$HOME/development/flutter/bin"
   ```

3. **Reload your shell**:
   ```bash
   source ~/.zshrc
   ```

4. **Verify Installation**:
   ```bash
   flutter doctor
   ```

### Install Dependencies and Run

Once Flutter is installed:

```bash
# Navigate to project directory
cd /Users/stanleyluong/code/stanslist

# Install dependencies
flutter pub get

# Run the app in Chrome
flutter run -d chrome

# Or build for web deployment
flutter build web --release
```

### Deployment to AWS Amplify

1. **Connect Repository**: Connect your GitHub repository to AWS Amplify
2. **Build Settings**: The `amplify.yml` file is already configured
3. **Custom Domain**: Configure `stanslist.stanleyluong.com` in Amplify console
4. **Deploy**: Amplify will automatically build and deploy on code pushes

### Development Commands

```bash
# Hot reload during development
flutter run -d chrome

# Build for production
flutter build web --release --dart-define=FLUTTER_WEB_USE_SKIA=true

# Analyze code
flutter analyze

# Run tests
flutter test
```

## Project Features Complete

✅ **Responsive Design** - Works on desktop and mobile  
✅ **Category Browsing** - 8 main categories with icons  
✅ **Search & Filters** - Search by keywords, filter by category/location  
✅ **Create Listings** - Full form with validation  
✅ **View Listings** - Detailed listing pages with contact info  
✅ **Local Storage** - Persistent data using SharedPreferences  
✅ **Modern UI** - Material Design with custom theme  
✅ **Navigation** - GoRouter for web-friendly URLs  
✅ **State Management** - Provider for reactive updates  

## Next Steps

1. Install Flutter SDK following the guide above
2. Run `flutter pub get` to install dependencies
3. Run `flutter run -d chrome` to start development server
4. Deploy to AWS Amplify for production
