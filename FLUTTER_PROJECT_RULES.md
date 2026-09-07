# Flutter Project Rules & Regulations

Professional feature-based clean architecture: **ApiClient + ApiService + Repository (interface + impl) + Provider**.

Copy this file (and `.cursorrules`) into other Flutter apps.

---

## 1. Required stack

| Concern | Standard |
| --- | --- |
| UI | Flutter + Material 3 |
| State | Provider (`ChangeNotifier`) |
| HTTP | `core/network/api_client.dart` wrapping `http` |
| Feature HTTP | `data/services/*_api_service.dart` |
| Feature data | `domain` repository contract + `data` repository impl |
| Config | `flutter_dotenv` + `.env` |
| Lints | `flutter_lints` |

Do not add Riverpod, Bloc, or GetX unless the project already uses them.

---

## 2. Folder layout

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   ├── theme/
│   ├── widgets/
│   ├── error/app_exception.dart
│   └── network/api_client.dart
└── features/<feature>/
    ├── domain/
    │   ├── entities/
    │   └── repositories/          # abstract class only
    ├── data/
    │   ├── models/                # JSON DTO (extends entity)
    │   ├── services/              # HTTP / remote data source
    │   └── repositories/          # *RepositoryImpl
    ├── providers/
    ├── screens/
    └── widgets/
```

---

## 3. Data flow

```
Screen / Widget
    → Provider          (UI state only)
    → Repository        (abstract; no HTTP)
    → RepositoryImpl    (map Model ↔ Entity; later: cache)
    → ApiService        (HTTP + JSON → Model)
    → ApiClient         (get/post/put/delete)
    → Backend
```

- Screens never call HTTP, `ApiClient`, or `*ApiService`.
- Providers never parse JSON or import `data/`.
- Providers take the **abstract** repository in the constructor.
- `main.dart` wires: `ApiClient` → `*ApiService` → `*RepositoryImpl` → `*Provider`.

---

## 4. Who does what

| Layer | Does | Does not |
| --- | --- | --- |
| **Entity** | App shape of data | JSON, HTTP |
| **Model** | `fromJson` / `toJson` | UI |
| **ApiService** | HTTP, unwrap `{ data }`, return models | Cache, `notifyListeners` |
| **Repository impl** | Call service, return entities; combine API + local later | Widgets |
| **Provider** | loading / error / list; call repository | `http.get` |
| **ApiClient** | Shared headers, status codes, network errors | Feature JSON mapping |

---

## 5. Naming

| Kind | Example |
| --- | --- |
| Entity | `booking.dart` → `Booking` |
| Model | `booking_model.dart` → `BookingModel` |
| Service | `booking_api_service.dart` → `BookingApiService` |
| Contract | `booking_repository.dart` → `abstract class BookingRepository` |
| Impl | `booking_repository_impl.dart` → `BookingRepositoryImpl` |
| Provider | `booking_provider.dart` |

Files `snake_case`, classes `PascalCase`, private `_prefix`.

---

## 6. Provider rules

1. `BookingProvider({required BookingRepository bookingRepository})`
2. Private fields + getters; `notifyListeners()` after UI-visible changes
3. `try/catch/finally`; `isLoading` + `error`
4. `Consumer` / `watch` in `build`; `read` in callbacks and `initState`
5. Never `context.watch` in `onPressed`

---

## 7. Screens

Handle **loading**, **error**, **empty**, **data**.  
Forms: `showModalBottomSheet` unless a short confirm is enough.  
Theme tokens from `AppTheme`. Widgets import **entities**, not models.

---

## 8. Imports

- Same feature: relative
- Provider → `domain/` only
- Widgets → `domain/entities/`
- Service → `ApiClient` + models
- Impl → service + domain contract

Do not import one feature from another.

---

## 9. Secrets

`.env` for `API_BASE_URL`. Asset in `pubspec.yaml`. Gitignore `.env`. No tokens in logs.

---

## 10. New feature checklist

```
□ domain/entities + domain/repositories (abstract)
□ data/models + data/services + data/repositories/*_impl
□ providers + screens + widgets
□ Wire in main.dart
□ 4 UI states
□ flutter analyze clean
```

---

## 11. Do not

- Merge ApiService and Repository into one class
- Construct `ApiClient` / `*ApiService` inside a Provider
- Call APIs from widgets
- Hardcode URLs, colors, strings
- Import `data/` from screens
- Commit `.env`
