<p align="center">
  <img src="Logo/Screenshot 2025-05-06 111831.png" alt="TripBin Logo" width="300"/>
</p>

# ✈️ TripBin - Your Smart Travel Companion


TripBin is a **feature-rich travel planning mobile application** built using Flutter. It unifies the entire trip management process—from discovering destinations to booking flights and managing itineraries. With Firebase at its core and real-time API integrations, TripBin offers a seamless experience for all travel enthusiasts.

🎥 **[Watch the Demo Video](https://youtu.be/hbe_kRDqoVk)**

---

## 🧭 Features

### 🧳 Trip Management
- Create and manage trips with destinations, dates, budgets, and activities.
- View, edit, and save travel itineraries.
- Real-time updates using Firebase Firestore and `StreamBuilder`.

### 🌍 Explore Destinations
- Browse **trending**, **top-rated**, and **hidden gem** destinations.
- View photos, descriptions, and must-visit attractions.

### 🛫 Flight Booking
- Search real-time flights using **AviationStack API**.
- Get detailed info including airline, flight number, status, and schedules.

### 👥 Social Feed
- Share travel stories and photos with the community.
- Like and comment on user posts to engage with fellow travelers.

### 🔐 Authentication & Profile
- Secure login/signup via **Firebase Authentication**.
- Update profile with name, bio, birthdate, and profile image.
- View your travel history and saved trips.

---

## 🛠️ Tech Stack

| Layer         | Tools & Frameworks                               |
|--------------|--------------------------------------------------|
| Frontend      | Flutter, Dart, Material Design                  |
| Backend       | Firebase Firestore, Firebase Auth, Firebase Storage |
| API Integration | AviationStack (Flight Data)                    |
| State Management | Provider Package                             |
| Networking    | HTTP Package                                    |

---

## 🔗 API Integration

**AviationStack API** is used to retrieve real-time flight data:
- Search flights by departure and arrival codes.
- View flight schedules, airlines, and current statuses.

---

## 🧱 Architecture

### 🧩 Frontend
- Built using Flutter
- Modular and scalable widget-based structure
- Responsive layouts with SafeArea, Flexible, and MediaQuery

### 💾 Backend
- Firebase Firestore for dynamic data storage
- Firebase Authentication for secure sign-in
- Firebase Storage for profile images

---

## 🧪 Challenges & Solutions

| Challenge                          | Solution                                                                 |
|-----------------------------------|--------------------------------------------------------------------------|
| Responsive UI                     | Used `MediaQuery`, `Expanded`, `SafeArea` to adapt across all devices.   |
| Real-Time Updates                 | Implemented `StreamBuilder` for seamless Firebase sync.                  |
| API Rate Limit (AviationStack)    | Used mock data during testing to avoid request limits.                   |

---

## 🔮 Future Enhancements

- 🏨 Hotel Booking via Amadeus/Booking.com API  
- 💳 Payment Gateway (Stripe/PayPal integration)  
- 📊 Advanced filters for flight search  
- 📸 Enhanced social feed with hashtags, location tagging, and albums  

---

## 📲 Getting Started

> ⚠️ This is a Flutter-based mobile app. Make sure you have [Flutter SDK](https://flutter.dev/docs/get-started/install) installed.

### 🔧 Setup Instructions

```bash
# 1. Clone the repository
git clone https://github.com/your-username/tripbin.git
cd tripbin

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
