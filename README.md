# Zeru' Booking System — Local Service Platform

A modern, full-stack Local Service Booking Application built with **Flutter (Clean Architecture)** for multi-platform client applications (iOS, Android, Web) and **Node.js / Express / TypeScript / MongoDB** with **Socket.IO** real-time WebSocket communication for the backend ecosystem.

---

## 🌟 Key Features

### 👤 Customer Experience
* **Service & Category Discovery**: Browse top-rated local service categories (Spa, Hair & Beauty, Cleaning, Home Repair, Tutoring, etc.) with real-time search.
* **Dynamic Promo Banner Carousel**: Silk-smooth auto-scrolling 60fps infinite carousel with custom depth scaling and active slide indicators.
* **Provider Profiles**: View detailed provider info, multi-service pricing, staff picker, real-time store availability (`Open` / `Busy`), distance, and verified customer reviews.
* **Instant Multi-Service Booking**: Select itemized services, preferred staff member, date & time slot, and payment method in a modal sheet.
* **Animated Status Stepper**: Track live booking progression (`Pending` → `Accepted` → `Completed`) with real-time WebSocket updates and interactive progress lines.
* **Ratings & Reviews**: Submit rating stars with interactive pop animations and detailed feedback after completed appointments.

### 🏪 Service Provider Portal
* **Store Management**: Toggle real-time shop status (`Available` / `Busy / Offline`) to accept or pause incoming bookings.
* **Service Groups & Services**: Full CRUD control over service categories, pricing, and duration.
* **Staff Management**: Assign staff members, roles, and service specializations.
* **Schedule & Working Hours**: Configure weekly operating days and opening/closing hours.
* **Booking Management**: Live notifications for incoming customer booking requests with one-tap Accept, Complete, or Decline actions.
* **Earnings & Payouts**: Overview of revenue statistics and payment method configurations.

### 🛡️ Admin Portal
* **Dashboard Analytics**: System-wide performance overview.
* **Promo Banner CRUD**: Create, edit, reorder, and activate/deactivate home screen promo banners linked to service categories.
* **Platform Security**: Role-based access control (Admin, Provider, Customer).

---

## 🛠️ Architecture & Tech Stack

```
lib/
├── main.dart                      # Composition root & GoRouter wiring
├── core/                          # Cross-cutting concerns & shared UI
│   ├── constants/                 # Spacing, radii, and duration constants
│   ├── network/                   # ApiClient (HTTP) & SocketService (WebSocket)
│   ├── theme/                     # AppTheme Material 3 tokens & palette
│   ├── utils/                     # Formatters (currency, dates, prices)
│   └── widgets/                   # Reusable UI, skeletons & animation wrappers
│       ├── animations/            # Scale button, staggered list, rating pop, checkmark
│       └── skeletons/             # Shimmer skeleton loaders
└── features/                      # Feature modules (Clean Architecture)
    ├── admin_portal/
    ├── auth/
    ├── booking/
    ├── home/
    ├── profile/
    ├── provider/
    ├── provider_portal/
    └── review/
```

### Clean Architecture Data Flow
```
Screen / Widget (UI Only)
   └─► Provider (ChangeNotifier - State Management)
        └─► Repository (Abstract Interface)
             └─► RepositoryImpl (Maps Models ↔ Entities)
                  └─► ApiService (HTTP Client & JSON Parsing)
                       └─► ApiClient / Backend API
```

* **UI Framework**: Flutter + Material 3
* **State Management**: Provider (`ChangeNotifier`)
* **Routing**: GoRouter (with custom slide/fade route transitions)
* **Design & Typography**: Google Fonts (`Inter`), HSL brand palettes, custom glassmorphism & shimmer
* **Backend API**: Node.js, Express, TypeScript, MongoDB (Mongoose), Socket.IO

---

## 🚀 Getting Started

### Prerequisites
* [Flutter SDK](https://flutter.dev/docs/get-started/install) (`^3.13.2` or later)
* [Node.js](https://nodejs.org/) (`v18+`)
* [MongoDB](https://www.mongodb.com/) (Local instance or MongoDB Atlas)

---

### 1. Backend Setup

```bash
cd booking_system_backend

# Install dependencies
npm install

# Configure environment variables in .env
cp .env.example .env

# Run development server
npm run dev
```

The backend server runs on `http://localhost:5001/api/v1` by default.

---

### 2. Frontend (Flutter) Setup

```bash
cd booking_system

# Install Flutter dependencies
flutter pub get

# Configure environment variables in .env
# Example .env contents:
# API_BASE_URL=http://localhost:5001/api/v1
# API_KEY=bs_live_4469300911156df9e659b03ecaa8594d1f5f9411f5be6fadb1e861730276a705

# Run code analysis check
flutter analyze

# Launch application on Chrome / Mobile device
flutter run -d chrome
```

---

## 🧪 Testing & Verification

Run static code analysis and test suites:

```bash
# Run static analysis
flutter analyze

# Run unit & integration tests
flutter test
```

---

## 📄 License

This project is licensed under the MIT License.
