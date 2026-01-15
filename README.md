# 🫀 Shared Lives – Organ Donor Management App

**Shared Lives** is a Flutter-based mobile application designed to promote **organ donation awareness**, simplify donor onboarding, and help users discover **nearby organ transplant hospitals**. The app leverages **Firebase** for secure authentication and real-time data management, and integrates maps for location-based hospital discovery.

---

## 🚀 Features

- 🔐 **Firebase Authentication**
  - Secure user login and registration
  - Supports email/password authentication

- 🧾 **Organ Donation Awareness & Donor Support**
  - Educational content about organ, eye, skin, and body donation
  - “Become a Donor” option with guided registration

- 🏥 **Nearby Organ Transplant Hospitals**
  - Real-time hospital discovery using maps
  - Shows hospitals near the user’s current location
  - Navigation support via external map apps

- 📍 **Live Location & Maps**
  - Uses GPS to detect user location
  - Displays hospitals on an interactive map with custom markers

- ☁️ **Cloud Firestore**
  - Stores and manages app-related data securely
  - Scalable backend for future expansion

- 📱 **Modern Flutter UI**
  - Clean, responsive design
  - Works on Android (iOS-ready architecture)

---

## 🛠️ Tech Stack

- **Frontend:** Flutter (Dart)
- **Backend:** Firebase
  - Firebase Authentication
  - Cloud Firestore
- **Maps & Location:**
  - OpenStreetMap (via `flutter_map`)
  - Geolocator (GPS access)
- **APIs & Utilities:**
  - HTTP (Overpass API for hospital data)
  - URL Launcher (external navigation)
  - WebView (donor registration pages)

---

## 📂 Project Structure

