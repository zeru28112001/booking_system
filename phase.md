Rules ကို base ပြုပြီး **UI/UX design phase** အားလုံးကို feature-based structure အတိုင်း စီစဉ်ပေးမယ် — code မပါဘဲ, screens/widgets layer ကိုပဲ focus လုပ်ပါမယ် (rules အရ Screens/Widgets က UI ကိုပဲ ဆောင်ရွက်ရမယ်, HTTP/logic မပါရဘူး)။

---

# 🎨 UI/UX Build Phases — Full App (Feature-based)

## Phase 0: Design Foundation
- `core/theme/` — color palette, typography, spacing scale သတ်မှတ်
- `core/widgets/` — reusable components စဉ်း (button, input field, loading indicator, empty state, error state)
- Design token consistency (AppTheme ကို screen တိုင်းသုံးမယ့် rule အတိုင်း)

---

## Phase 1: `features/auth/` — Authentication UI
| Screen | UI Elements |
|---|---|
| Splash | Logo, loading indicator |
| Login | Phone input, password input, "Login" button, "Register" link |
| Register | Name, phone, password, role selector (customer only for MVP), "Register" button |
| OTP Verify (optional) | 6-digit input boxes, resend timer |

**UX flow**: Splash → (token check) → Login/Register → Home

---

## Phase 2: `features/home/` — Home & Category Discovery
| Screen | UI Elements |
|---|---|
| Home | App bar (location display), category grid (5 icons), search bar (placeholder), banner/promo (optional) |
| Category empty state | "No providers in this category yet" illustration |

**UX flow**: Home → tap category → Provider List

---

## Phase 3: `features/provider/` — Provider Discovery
| Screen | UI Elements |
|---|---|
| Provider List | Filter bar (sort/distance), provider card list (photo, name, rating, distance, price range) |
| Provider Detail | Header image, name + rating, sub-service tabs, service list (price/duration), reviews section, "Book Now" sticky button |
| Staff Selection (Phase 2 feature, shop-model) | Staff avatar list, specialties tag |

**4 states per rules**: Loading (skeleton cards), Error (retry button), Empty (no providers found), Data (list populated)

---

## Phase 4: `features/booking/` — Booking Flow
| Screen | UI Elements |
|---|---|
| Booking Form | Selected service summary, date picker, time slot grid (available/unavailable visual states), address input (home service), notes field |
| Payment Method Select | Radio options — Cash / MyanMyanPay / Stripe, price summary |
| Booking Confirmation | Success animation/icon, booking summary card, "View Booking" button |
| My Bookings | Tab bar (Pending/Upcoming/History), booking card list (status badge, provider name, date/time) |
| Booking Detail | Full info, status timeline (visual stepper: Pending→Accepted→In Progress→Completed), cancel button (conditional) |

**UX rule (from project rules)**: Forms use `showModalBottomSheet` — booking form UI ကို bottom sheet အဖြစ် design လုပ်ပါ (short confirm ဆိုရင်တော့ dialog ပဲ ဖြစ်နိုင်)

---

## Phase 5: `features/review/` — Review & Rating
| Screen | UI Elements |
|---|---|
| Review Form | Star rating selector (1-5), comment text area, "Submit" button |
| Review List (on provider detail) | Reviewer name, star display, comment, date |

---

## Phase 6: `features/profile/` — Profile & Settings
| Screen | UI Elements |
|---|---|
| Profile | Avatar, name/phone display, menu list (Edit Profile, My Bookings, Settings, Logout) |
| Edit Profile | Name, phone (read-only or verify-required), address, save button |
| Settings (optional) | Language toggle placeholder, notification toggle placeholder |

---

## Phase 7: `features/provider_dashboard/` — Provider-side UI (if same app, role-based)
| Screen | UI Elements |
|---|---|
| Provider Home | Incoming booking requests list, Accept/Reject buttons |
| Service Management | Service list (add/edit/delete), sub-service picker |
| Working Hours Setup | Weekly schedule grid (day toggle + time range picker) |
| Availability Toggle | Prominent Busy/Available switch on dashboard |
| Earnings | Simple list/summary (booking count, total earned) |

---

## Phase 8: Cross-cutting UI States (apply to every screen per rules)
- ✅ Loading state (skeleton or spinner)
- ✅ Error state (message + retry action)
- ✅ Empty state (illustration + helper text)
- ✅ Data state (actual content)

---

## Phase 9: Navigation & Information Architecture
- Bottom nav bar (Home / Bookings / Profile) — customer app
- Role-based routing (customer vs provider dashboard, if single app)
- Deep-link structure (category → provider → booking) planning

---

## Phase 10: Design QA Pass
- Consistency check — theme tokens used everywhere (no hardcoded colors, per rule #9/#11)
- Accessibility check — tap target size, contrast
- `flutter analyze` clean (per checklist rule #10)

---

## 📌 Feature Folder Mapping (rules နဲ့ တိုက်ဆိုင်)

```
features/
├── auth/screens/          → Phase 1
├── home/screens/          → Phase 2
├── provider/screens/      → Phase 3
├── booking/screens/       → Phase 4
├── review/screens/        → Phase 5
├── profile/screens/       → Phase 6
└── provider_dashboard/screens/ → Phase 7
```

