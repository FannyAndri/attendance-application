# AttendanceApp — Geofencing & Smart Attendance System

AttendanceApp is a modern employee attendance system that combines **GPS Geofencing**, **Work From Home (WFH) management**, and **anomaly detection** to improve attendance accuracy and maintain data integrity.

---

## Overview

AttendanceApp is designed to support both **on-site** and **remote attendance workflows** through location-based validation and automated attendance monitoring. The system consists of:

* **Employee mobile application** built with Flutter
* **Admin dashboard and API backend** built with Laravel

It helps organizations monitor attendance more reliably by validating check-in/check-out locations, detecting lateness, supporting approved WFH attendance, and identifying suspicious attendance patterns.

---

## Key Features

## Employee Portal (Mobile)

### Geofencing Check-in / Check-out

Employees can only check in or check out within a predefined geofencing radius (e.g. **300 meters**) from the office location.

### Smart WFH Mode

When a WFH request is approved, the geofencing target is automatically switched from the office location to the employee’s registered home coordinates.

### Late Attendance Detection

The system automatically calculates lateness based on each employee’s assigned shift schedule (for example **08:00 – 17:00**).

### Real-time Attendance Warnings

Employees receive instant warnings when:

* checking in late
* checking out earlier than scheduled
* attempting attendance outside the allowed area

### Live Location Tracking

Location updates can be tracked during working hours to support attendance validation and monitoring.

### Attendance History

Employees can view daily attendance records, including:

* check-in and check-out times
* work duration
* lateness information
* attendance status

---

## Admin Dashboard

### Attendance Overview

A quick summary of daily attendance metrics, such as:

* total employees present
* late arrivals
* approved leave / permissions
* ongoing attendance activities

### Employee Management

Manage employee data including:

* personal profile
* department
* attendance role
* shift schedule
* WFH location approval data

### Office Geofencing Configuration

Admins can configure office coordinates and attendance radius through Google Maps coordinates or manually entered latitude/longitude.

### Monthly Attendance Reports

Generate clean attendance recaps that include:

* total attendance days
* total late minutes
* work duration
* estimated overtime
* attendance anomalies

### Data Maintenance Tools

Includes tools such as **Recalculate Data** to automatically reprocess historical attendance data when rules or schedules are updated.

### Anomaly Detection

Monitor suspicious attendance behavior patterns, such as:

* repeated location inconsistencies
* unusual attendance timing
* abnormal check-in/check-out behavior

---

## Security & Data Protection

AttendanceApp applies several security measures to protect employee data and authentication flows.

### Password Hashing

All passwords are stored using **Bcrypt** via Laravel’s hashing mechanism.

### Email Privacy Protection

Employee email data is protected using:

* **SHA-256 hashing** for login-related matching or privacy-sensitive operations
* **AES-256 encryption** for secure storage of personal data

### Secure API Communication

API access is protected with **token-based authentication** to ensure secure communication between the mobile app and backend services.

### Timezone Standardization

The system uses **Asia/Jakarta (WIB)** as the default timezone to maintain consistent attendance calculations.

---

## Tech Stack

## Frontend (Flutter)

* **Framework:** Flutter
* **State Management:** Provider
* **Location & Maps:** geolocator, flutter_map, latlong2
* **Networking:** http
* **UI Utilities:** google_fonts, intl, flutter_launcher_icons

## Backend (Laravel)

* **Framework:** Laravel 11
* **Database:** MySQL / MariaDB / SQLite
* **Authentication:** Token-based Authentication
* **Security:** Bcrypt, AES-256, SHA-256

---

## Project Structure

```bash
AttendanceApps/
├── lib/                          # Flutter source code
│   ├── models/                   # Data models (Attendance, User, Anomaly, etc.)
│   ├── providers/                # State management
│   ├── screens/                  # Employee & admin UI screens
│   ├── services/                 # API services and business communication logic
│   └── utils/                    # Helpers (GPS parser, formatter, utilities)
│
├── assets/                       # App icons and image assets
├── android/                      # Android-specific project files
├── ios/                          # iOS-specific project files
│
└── laravel_backend/              # Laravel API backend
    ├── app/Http/Controllers/     # Business logic controllers
    ├── database/migrations/      # Database schema and migrations
    └── routes/api.php            # API route definitions
```

---

## Getting Started

## 1. Backend Setup (Laravel)

Move into the backend directory:

```bash
cd laravel_backend
```

Install dependencies:

```bash
composer install
```

Copy the environment file:

```bash
cp .env.example .env
```

Update your `.env` file with the appropriate database configuration.

Generate the application key:

```bash
php artisan key:generate
```

Run database migrations:

```bash
php artisan migrate
```

Start the Laravel development server:

```bash
php artisan serve
```

---

## 2. Frontend Setup (Flutter)

Install Flutter dependencies:

```bash
flutter pub get
```

Update the backend base URL inside:

```bash
lib/services/api_constants.dart
```

Make sure it points to your Laravel backend URL or your local network IP address.

Run the application:

```bash
flutter run
```

---

## Configuration Notes

### Geofencing Radius

The attendance validation radius can be configured according to your organization’s policy (for example, **300 meters**).

### WFH Coordinates

Employees using WFH mode should have their home coordinates registered and approved by the admin before attendance is allowed from home.

### Timezone

Ensure both the backend server and attendance calculations use the same timezone configuration, preferably **Asia/Jakarta**.

---

## App Icon Replacement

This project uses `flutter_launcher_icons`.

To replace the application icon:

1. Replace the file below with your new icon:

   ```bash
   assets/icon.png
   ```

2. Run:

   ```bash
   dart run flutter_launcher_icons
   ```

---

## Future Improvements

Possible future enhancements for this project include:

* **Push notifications** using Firebase
* **Export reports** to Excel or PDF
* **More advanced anomaly detection / machine learning models**
* **Biometric attendance support**
* **Face verification or liveness detection**
* **Role-based admin permissions**
* **Attendance approval workflow for exceptions and corrections**

---

## Use Cases

AttendanceApp is suitable for organizations that need:

* office-based attendance with location restrictions
* hybrid work support (office + WFH)
* centralized attendance reporting
* employee lateness monitoring
* attendance anomaly monitoring and audit support

---

## License

This project is intended for educational, internal, or organizational attendance management purposes.
You may add your preferred license here, such as **MIT**, **Apache-2.0**, or a private internal-use license depending on how the repository will be distributed.
