# Stan's List Portfolio Website

## Overview
Stan's List is a portfolio website built with Flutter, showcasing projects and skills. The application is designed to be responsive and user-friendly, providing an engaging experience for visitors.

## Project Structure
The project is organized into the following directories and files:

- **lib/**: Contains the main application code.
  - **main.dart**: Entry point of the Flutter application.
  - **src/**: Contains the source files for the application.
    - **app.dart**: Main application widget with theme and routing.
    - **screens/**: Contains different screens of the application.
      - **home_screen.dart**: Home screen layout and components.
    - **widgets/**: Contains reusable widgets.
      - **custom_widget.dart**: Definition of a reusable widget.
    - **utils/**: Contains utility files.
      - **constants.dart**: Constants used throughout the application.
- **test/**: Contains tests for the application.
  - **widget_test.dart**: Widget tests to ensure UI behaves as expected.
- **web/**: Contains web-specific files.
  - **index.html**: Main HTML file for the web version of the app.
- **pubspec.yaml**: Configuration file for the Flutter project.
- **# Stan's List - Local Classifieds Marketplace

A modern classifieds platform built with Flutter for web, inspired by Craigslist but with a fresh, modern design.

## Features

- **Browse Categories**: Housing, Jobs, For Sale, Services, Community, Vehicles, Electronics, and Furniture
- **Search & Filter**: Search by keywords, filter by category and location
- **Post Listings**: Create detailed listings with contact information
- **Responsive Design**: Works seamlessly on desktop and mobile
- **Local Storage**: Listings persist locally using SharedPreferences

## Categories

- 🏷️ **For Sale** - Items for sale by owner
- 🏠 **Housing** - Apartments, houses, rooms for rent
- 💼 **Jobs** - Employment opportunities
- 🔧 **Services** - Professional and personal services
- 👥 **Community** - Local events and activities
- 🚗 **Vehicles** - Cars, trucks, motorcycles
- 📱 **Electronics** - Computers, phones, gadgets
- 🪑 **Furniture** - Home and office furniture

## Technology Stack

- **Flutter** - Cross-platform UI framework
- **Provider** - State management
- **GoRouter** - Navigation and routing
- **SharedPreferences** - Local data persistence
- **Material Design** - Modern UI components

## Deployment

This app is configured for deployment with AWS Amplify to `stanslist.stanleyluong.com`.

### Build Commands

```bash
# Install dependencies
flutter pub get

# Build for web
flutter build web --release

# Run locally
flutter run -d chrome
```

### AWS Amplify Configuration

The app includes an `amplify.yml` build specification file configured for Flutter web deployment.

## Getting Started

1. Install Flutter SDK
2. Clone the repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter run -d chrome` to start the development server

## Project Structure

```
lib/
├── main.dart              # App entry point
├── app.dart               # App configuration and routing
├── models/                # Data models
├── providers/             # State management
├── screens/               # UI screens
├── widgets/               # Reusable UI components
└── utils/                 # Utilities and theme
```

## Contact

Built by Stanley Luong for portfolio demonstration.**: Documentation for the project.

## Setup Instructions
1. **Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/stans-list.git
   cd stans-list
   ```

2. **Install Dependencies**
   Make sure you have Flutter installed. Run the following command to get the dependencies:
   ```bash
   flutter pub get
   ```

3. **Run the Application**
   To run the application locally, use:
   ```bash
   flutter run
   ```

4. **Build for Web**
   To build the application for web deployment, use:
   ```bash
   flutter build web
   ```

5. **Deploy to AWS Amplify**
   Follow the AWS Amplify documentation to deploy the built web application to your domain: [stanslist.stanleyluong.com](http://stanslist.stanleyluong.com).

## Features
- Responsive design for various screen sizes.
- Reusable components for consistent UI.
- Easy navigation between different sections of the portfolio.

## Usage
Visit [stanslist.stanleyluong.com](http://stanslist.stanleyluong.com) to view the live portfolio website. Explore the projects and skills showcased, and feel free to reach out for collaborations or inquiries.

## License
This project is licensed under the MIT License. See the LICENSE file for more details.