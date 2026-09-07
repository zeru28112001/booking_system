Rules ကို base ပြုပြီး **UI/UX design phase** အားလုံးကို feature-based Clean Architecture structure အတိုင်း စီစဉ်ပေးထားသည် — customer side နှင့် provider side အပြည့်အစုံ ပါဝင်ပါသည်။

---

# 🎨 UI/UX Build Phases — Full App (Customer & Provider)

## Phase 0: Design Foundation
- `core/theme/` — color palette, typography, spacing scale သတ်မှတ်
- `core/widgets/` — reusable components (button, input field, loading indicator, empty state, error state, badges)
- Design token consistency (`AppTheme` ကို screen တိုင်းတွင် သုံးသည်)

---

## Phase 1: `features/auth/` — Authentication & Role Selection UI
| Screen | UI Elements |
|---|---|
| Splash | Logo, loading indicator, token check |
| Login | Phone input, password input, role check (Customer / Provider) |
| Register | Name, phone, password, role toggle (Customer / Service Provider), "Register" button |
| OTP Verify | 6-digit OTP input, resend timer |

**UX flow**: Splash → Login/Register → Customer Shell (`/home`) or Provider Dashboard (`/provider-dashboard`)

---

## Phase 2: `features/home/` — Home & Category Discovery (Customer)
| Screen | UI Elements |
|---|---|
| Home | Location banner, category grid (Salon, Spa, Cleaning, Electrician, Plumbing), search bar, promo cards |
| Category empty state | "No providers in this category yet" illustration |

---

## Phase 3: `features/provider/` — Provider Discovery (Customer)
| Screen | UI Elements |
|---|---|
| Provider List | Filter bar (sort/distance), provider card list (photo, name, rating, distance, price range) |
| Provider Detail | Header image, name + rating, multi-service cart selector, reviews section, sticky "Book Selected Services" bar |
| Staff Selection | Shop-model staff list with avatars and specialties tags |

---

## Phase 4: `features/booking/` — Booking Flow (Customer)
| Screen | UI Elements |
|---|---|
| Booking Form Sheet | Service bundle summary, date picker, time slot grid, service address toggle (Home vs Shop), notes field |
| Payment Method Select | Cash on Service / KBZPay / WavePay / Credit Card options |
| Booking Confirmation | Success animation, booking summary card, "View Booking" button |
| My Bookings | Tab bar (Pending / Upcoming / History), booking card list |
| Booking Detail | Full info, status timeline (Pending → Accepted → In Progress → Completed), cancel action |

---

## Phase 5: `features/review/` — Review & Rating (Customer)
| Screen | UI Elements |
|---|---|
| Review Form Sheet | 1-5 star selector, comment text area, "Submit Review" button |
| Review List | Provider detail reviews section with author name, rating stars, date |

---

## Phase 6: `features/profile/` — Profile & Settings (Customer)
| Screen | UI Elements |
|---|---|
| Profile | User avatar card, menu list (Edit Profile, My Bookings, Settings, Switch to Provider, Logout) |
| Edit Profile | Name, phone (read-only), email, primary service address |
| Settings | Push notification switch toggle, language selector dialog, App Version |

---

## Phase 7: `features/provider_portal/` — Provider Dashboard & Management (Provider Side)
| Requirement | Screen / Widget | Key Features & UI Elements |
|---|---|---|
| **FR-15** | Provider Onboarding / Profile Setup | Category picker, shop name, description, address, photos, initial setup |
| **FR-16** | Admin Verification Banner | Verification status banner (Pending / Verified / Rejected), verification badge & document submission UI |
| **FR-17** | Sub-service (Variant) Management | Service list, Add/Edit service modal (Title, Price, Duration, Category, Active toggle) |
| **FR-18** | Staff Management | Staff list screen, Add/Edit staff modal (Name, Phone, Photo, Specialties tags selection) |
| **FR-19** | Weekly Working Hours Setup | Weekly schedule grid (Mon–Sun), open/off-day toggles, start & end time pickers |
| **FR-20** | Real-time Availability Switch | Header switch on dashboard: "Available" (Green) vs "Busy / Offline" (Amber) |
| **FR-21 & FR-22** | Booking Pipeline & Accept/Reject | Incoming requests tab, Accept/Reject buttons, Status update stepper (Accepted → In Progress → Completed) |
| **FR-23 & FR-24** | Earnings & Payment History | Revenue summary cards (Total Earned, Completed Count), Booking history table, Payment status (Paid/Cash) |

---

## Phase 8: Cross-cutting UI States
- ✅ Loading state (Skeletons & spinners)
- ✅ Error state (Message + retry action)
- ✅ Empty state (Illustration + helper text)
- ✅ Data state (Populated list & dashboard)

---

## Phase 9: Routing & Information Architecture
- Customer Shell (`MainShellScreen`): Bottom Nav (Home / Bookings / Profile)
- Provider Shell (`ProviderShellScreen`): Bottom Nav (Dashboard / Bookings / Services & Staff / Profile)
- Role-based routing in `GoRouter`

---

## 📌 Feature Folder Mapping

```
lib/features/
├── auth/               → Phase 1 (Auth & Role Toggle)
├── home/               → Phase 2 (Customer Home)
├── provider/           → Phase 3 (Customer Discovery)
├── booking/            → Phase 4 (Customer Bookings)
├── review/             → Phase 5 (Customer Reviews)
├── profile/            → Phase 6 (Customer Profile)
└── provider_portal/    → Phase 7 (FR-15 to FR-24 Provider Dashboard & Management)
```
