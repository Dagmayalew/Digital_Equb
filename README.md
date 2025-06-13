# Digital Equb

## Overview

The Digital Equb App is a modern take on the traditional Ethiopian Equb system, a rotating savings and credit association (ROSCA). This Flutter application aims to digitize and simplify the process of managing Equb groups, allowing users to join available Equbs, manage their contributions, track payment statuses, and view payout history in a transparent and user-friendly manner.

The app demonstrates core Flutter concepts including state management with Provider, UI/UX design principles, asynchronous data handling (simulated with local JSON), and navigation.

## Features

* User Authentication (Simulated): Log in with predefined user credentials.
* Theme Toggling: Switch between light and dark themes for personalized viewing.
* Dashboard:
    * Greeting message displaying the logged-in user's name.
    * Prominent display of user's current balance.
    * Quick deposit functionality (simulated) to add funds to the balance.
    * Overview of all joined Equb groups.
    * Engaging empty state UI to encourage discovering new Equbs.
* Discover Equbs:
    * Browse a list of available Equb groups loaded from local JSON data.
    * View detailed information about each Equb, including:
        * Contribution amount and frequency.
        * Number of members and total duration.
        * Total potential payout if a member wins a cycle.
    * Ability to join new Equbs.
* Joined Equb Details:
    * Comprehensive view of a specific Equb the user has joined.
    * Details on the next payment date, current payout recipient, and overall Equb status (Paid or Pending).
    * "Pay Contribution" flow:
        * Agreement policy dialog.
        * Confirmation dialog.
        * Automatic deduction of contribution amount from user's balance.
        * Simulated payments from other members.
        * Real-time updates of payment status.
    * Payout History: A list of past payout cycles, showing the recipient, date, and amount.
* Profile Management:
    * Display user's personal details (name, email, phone).
    * Current balance display.
    * Option to deposit funds (simulated) directly from the profile screen.

## Technologies Used

* Flutter 3.x: UI Toolkit for building natively compiled applications for mobile.
* Dart: Programming language.
* provider package: For robust and scalable state management.
* intl package: For internationalization, specifically used for currency and date formatting.
* fake_payment_service.dart: A simple service to simulate deposit operations.
* Local JSON: Used for simulating user and Equb data storage.

## Setup and Installation

Follow these steps to get the Digital Equb app running on your local machine.

### Prerequisites

* Flutter SDK: Make sure you have Flutter installed. If not, follow the official installation guide: [Flutter Install](https://flutter.dev/docs/get-started/codelab)
* IDE: Visual Studio Code or Android Studio with Flutter and Dart plugins.
* Git: For cloning the repository.

### Installation Steps

1. Clone the repository:
    ```bash
    git clone <repository_url> # Replace with your repo URL
    cd your_project_folder_name # Make sure this matches your actual folder name
    ```

2. Install dependencies:
   Navigate to the project root and run:
    ```bash
    flutter pub get
    ```

3. Run the application:
   Connect a device or start an emulator/simulator, then run:
    ```bash
    flutter run
    ```
   Alternatively, you can run `flutter run --no-sound-null-safety` if you encounter null safety issues with older dependencies.

## Project Structure
digital_equb_app/ # Or whatever your project folder is named
├── lib/
│   ├── main.dart                 # Main entry point of the application
│   ├── models/                   # Data models (Equb, EqubMember, PayoutHistoryEntry)
│   │   ├── equb.dart
│   │   
│   ├── notifier/                 # Provider Notifiers for state management (UserNotifier, ThemeNotifier)
│   │   ├── user_notifier.dart
│   │   └── theme_notifier.dart
│   ├── screens/                  # All UI screens of the app
│   │   ├── login_screen.dart
│   │   ├── main_screen.dart      # Contains BottomNavigationBar and PageView
│   │   ├── home_screen.dart
│   │   ├── equb_list_screen.dart
│   │   ├── equb_detail_screen.dart
│   │   ├── joined_equb_detail_screen.dart
│   │   └── profile.dart
│   ├── theme/                    # Theme definitions (light/dark mode)
│   │   └── theme_notifier.dart
│   └── utils/                    # Utility functions (e.g., json_loader, fake_payment_service)
│       ├── json_loader.dart
│       └── fake_payment_service.dart
├── assets/                       # Assets like JSON data
│   └── data.json
├── pubspec.yaml                  # Project dependencies and metadata
└── README.md                     # This file

## Usage

### Login

The app uses simulated user data. You can find example credentials in `assets/data.json`.
* Example Users (from `assets/data.json`):
    * Phone: +251988280976, Password: password123
    * Email: john.doe@example.com, Password: pass123

### Navigating the App

* After logging in, you'll land on the **Dashboard (Home Screen)**.
* Use the **Bottom Navigation Bar** to switch between:
    * **Dashboard:** Your personal overview.
    * **Equbs:** Discover and join new Equbs.
    * **Profile:** Manage your account details and deposit funds.

### Joining an Equb

1. Go to the **Equbs** tab.
2. Tap on an Equb to view its details.
3. If you haven't joined, tap "Join This Equb".

### Paying Contribution

1. Go to the **Dashboard** tab.
2. Select a joined Equb.
3. Tap "Pay Contribution Now" and follow the prompts. Ensure you have sufficient balance.

### Managing Balance

* You can deposit funds via the **Deposit** button on the Dashboard or the **Profile** screen.
* Note: The payment service is simulated; deposits below 10 Birr will fail.

## Future Enhancements

* Firestore Integration: Replace local JSON with a real-time NoSQL database like Firebase Firestore for persistent and multi-user data.
* User Registration: Implement a full user registration flow.
* Equb Creation: Allow users to create their own Equb groups.
* Notifications: Add push notifications for payment reminders, cycle completions, etc.
* Transaction History: A more detailed transaction log for individual users.
* Search and Filter: Implement search and filtering options for Equb lists.
* Advanced Payout Logic: More complex rules for determining payout recipients (e.g., bidding, manual selection).
* Offline Support: Caching data for offline usage.
* Unit and Widget Testing: Implement comprehensive tests for stability.

## Developed by Dagm Ayalew

This project is licensed under the MIT License - see the LICENSE.md file for details (You would typically create a `LICENSE.md` file in your root directory if you want to include it).

## Contact

Phone: +251988280976