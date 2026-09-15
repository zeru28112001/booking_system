# Booking System — Flutter Cross-Platform Client Application

A modern, full-stack Local Service Booking Application built with **Flutter (Clean Architecture)** for multi-platform client applications (iOS, Android, Web) and **Node.js / Express / TypeScript / MongoDB** backend with real-time Socket.IO communication.

---

## 🌟 Key Features

### 👤 Customer Experience
- **Service & Category Discovery**: Browse top-rated local service categories (Beauty & Salon, Home Cleaning, Plumbing, Electrical & AC, Tutoring) with intelligent word-boundary search.
- **Dynamic Promo Banner Carousel**: Auto-scrolling 60fps carousel with active slide indicators.
- **Provider Profiles**: Detailed provider info, multi-service pricing, staff picker, real-time store availability (`Open` / `Busy`), GPS distance, and verified customer reviews.
- **Instant Multi-Service Booking**: Select itemized services, preferred staff member, date & time slot, and payment method in a modal sheet.
- **15-Minute Advance Lead Time**: Time slots starting within 15 minutes of the current time are automatically disabled for same-day bookings.
- **Animated Status Stepper**: Track live booking progression (`Pending` → `Accepted` → `In Progress` → `Completed`) with real-time WebSocket updates.

### 🏪 Service Provider Portal
- **Store Management**: Toggle real-time shop status (`Available` / `Busy`) to accept or pause incoming bookings.
- **Service Mode Validation**: Enforces that at least one service mode (`isShop` or `isHomeService`) remains active.
- **Booking Management**: Live notifications for incoming customer booking requests with one-tap Accept, Complete, Reject, or **Customer No-Show** action buttons.
- **Service Groups & Services**: Full management over service categories, pricing, and duration.
- **Staff Management**: Assign staff members, roles, shift times, and service specializations.
- **Schedule & Working Hours**: Configure weekly operating days and opening/closing hours.

---

## 🛠️ Tech Stack & Architecture

```
lib/
├── main.dart                      # Composition root & GoRouter wiring
├── core/                          # Cross-cutting concerns & shared UI
│   ├── constants/                 # Spacing, radii, and duration constants
│   ├── network/                   # ApiClient (HTTP) & SocketService (WebSocket)
│   ├── theme/                     # AppTheme Material 3 tokens & palette
│   ├── utils/                     # Formatters (currency, dates, prices)
│   └── widgets/                   # Reusable UI, skeletons & animation wrappers
└── features/                      # Feature modules (Clean Architecture)
    ├── admin_portal/
    ├── auth/
    ├── booking/
    ├── home/
    ├── profile/
    ├── provider/
    └── provider_portal/
```

- **UI Framework**: Flutter + Material 3
- **State Management**: Provider (`ChangeNotifier`) & Riverpod
- **Routing**: GoRouter (with custom slide/fade route transitions)
- **Backend Integration**: REST API & Socket.IO WebSockets

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (`^3.13.2` or later)
- Chrome browser or mobile emulator/device

### Installation & Execution

```bash
# 1. Navigate to project directory
cd booking_system

# 2. Install Flutter packages
flutter pub get

# 3. Create .env file for environment configuration:
# Example .env contents:
# API_BASE_URL=http://localhost:5001/api/v1
# API_KEY=your_api_key_here

# 4. Run static code analysis
flutter analyze

# 5. Launch application on Chrome / Mobile device
flutter run -d chrome
```

---

## 📄 License

This project is licensed under the MIT License.
