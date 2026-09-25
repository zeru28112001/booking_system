import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguageProvider extends ChangeNotifier {
  static const String _prefKey = 'app_language_code';

  String _languageCode = 'en';

  String get languageCode => _languageCode;
  bool get isMyanmar => _languageCode == 'my' || _languageCode == 'mm';

  AppLanguageProvider() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      if (saved != null && saved.isNotEmpty) {
        _languageCode = saved;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> setLanguage(String code) async {
    if (code != 'en' && code != 'my' && code != 'mm') {
      code = code.toLowerCase().contains('myanmar') ? 'my' : 'en';
    }
    _languageCode = code;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, code);
    } catch (_) {}
  }

  String translate(String key) {
    if (isMyanmar) {
      return _myanmarTranslations[key] ?? _englishTranslations[key] ?? key;
    }
    return _englishTranslations[key] ?? key;
  }

  static const Map<String, String> _englishTranslations = {
    // Customer Navigation Shell
    'nav_home': 'Home',
    'nav_bookings': 'Bookings',
    'nav_profile': 'Profile',

    // Provider Navigation Shell
    'provider_nav_dashboard': 'Dashboard',
    'provider_nav_bookings': 'Bookings',
    'provider_nav_services': 'Services',
    'provider_nav_staff': 'Staff',
    'provider_nav_profile': 'Shop Profile',

    // Customer Profile Screen
    'my_profile': 'My Profile',
    'edit_profile': 'Edit Profile',
    'edit_profile_desc': 'Update your name & email',
    'my_bookings': 'My Bookings',
    'my_bookings_desc': 'View upcoming and past appointments',
    'settings': 'Settings',
    'settings_desc': 'Language, notifications & app preferences',
    'logout': 'Logout',
    'logout_desc': 'Sign out of your account',
    'confirm_logout_title': 'Logout Confirmation',
    'confirm_logout_msg': 'Are you sure you want to sign out?',
    'save_changes': 'Save Changes',

    // Settings Screen
    'preferences': 'Preferences',
    'push_notifications': 'Push Notifications',
    'push_notif_desc': 'Receive booking updates & reminders',
    'language': 'Language',
    'about_legal': 'About & Legal',
    'privacy_policy': 'Privacy Policy',
    'terms_of_service': 'Terms of Service',
    'app_version': 'App Version',
    'choose_language': 'Choose Language',
    'english': 'English',
    'myanmar': 'Myanmar (မြန်မာ)',
    'cancel': 'Cancel',
    'turn_off': 'Turn Off',
    'confirm_turn_off_title': 'Turn Off Push Notifications?',
    'confirm_turn_off_msg': 'If you turn off push notifications, you may miss critical booking updates, provider arrival alerts, and status reminders.',

    // Home Screen
    'home_title': 'Find Services Near You',
    'search_hint': 'Search services, providers...',
    'explore_categories': 'Explore Categories',
    'top_providers': 'Top Rated Providers',
    'all_providers': 'All Service Providers',
    'view_all': 'View All',
    'no_providers_found': 'No service providers found.',
    'rating': 'Rating',

    // Bookings Screen
    'bookings_title': 'My Appointments',
    'tab_all': 'All',
    'tab_pending': 'Pending',
    'tab_confirmed': 'Confirmed',
    'tab_completed': 'Completed',
    'tab_cancelled': 'Cancelled',
    'no_bookings_found': 'No bookings found.',
    'booking_status': 'Status',
    'date_time': 'Date & Time',
    'service_name': 'Service',
    'total_price': 'Total Price',
    'view_details': 'View Details',
    'book_again': 'Book Again',

    // Provider Detail & Portal Screen
    'book_now': 'Book Now',
    'services': 'Services',
    'reviews': 'Reviews',
    'about': 'About',
    'address': 'Address',
    'working_hours': 'Working Hours',
    'staff': 'Staff',
    'duration': 'Duration',
    'price': 'Price',

    // Provider Portal Specific
    'provider_profile_title': 'Provider Profile',
    'edit_shop_profile': 'Edit Shop Profile',
    'store_status': 'Store Status',
    'status_available': 'Available for new customer bookings',
    'status_busy': 'Currently set to Busy / Offline',
    'business_setup': 'Business Setup',
    'weekly_schedule': 'Weekly Working Hours',
    'schedule_desc': 'Set open days, start & end times',
    'payment_methods': 'Manage Payment Methods',
    'payment_desc':
        'Configure accepted payment options (Cash, Mobile Wallet, Bank QR)',
    'earnings_insights': 'Earnings & Booking Insights',
    'earnings_desc': 'View payout history and daily revenue',
    'edit_description': 'Edit Business Description',
    'account': 'Account',
    'logout_provider': 'Logout Provider Account',
    'dashboard_overview': 'Dashboard Overview',
    'todays_bookings': "Today's Appointments",
    'total_revenue': 'Total Earnings',
    'pending_approvals': 'Pending Requests',
    'manage_services': 'Manage Services',
    'manage_staff': 'Manage Staff',

    // Additional Provider Keys
    'provider_dashboard_title': 'Provider Dashboard',
    'provider_bookings_title': 'Provider Bookings',
    'provider_services_title': 'Manage Services',
    'provider_staff_title': 'Manage Staff',
    'weekly_schedule_title': 'Weekly Working Hours',
    'payment_methods_title': 'Payment Methods',
    'earnings_title': 'Earnings & Payments',
    'payment_history': 'Payment History',
    'accept': 'Accept',
    'reject': 'Reject',
    'tab_accepted': 'Accepted',
    'tab_in_progress': 'In Progress',
    'tab_no_show': 'No-Show',
    'add_service': 'Add Service',
    'add_staff': 'Add Staff',
    'service_groups': 'Manage Service Groups',
    'service_mode_options': 'Service Mode Options (Requires Admin Review)',
    'storefront_shop_mode': 'Storefront / Salon Shop',
    'storefront_shop_desc': 'In-shop bookings with staff options',
    'home_service_mode': 'Home / On-Site Service',
    'home_service_desc': 'Travel to customer location/home',
    'change_pending_admin': 'Change Request Pending Admin Approval',
    'change_pending_desc': 'Your requested service mode / profile updates are currently under review by an Administrator.',
    'pick_location_map': 'Pick Location on Map',
    'submit_to_admin': 'Submit to Admin',
    'confirm_status_change': 'Confirm Status Change',
    'save_schedule': 'Save Weekly Schedule',
    'schedule_hint': 'Set your business open days and working hours for each day of the week.',
    'off_day': 'OFF DAY',
    'active_status': 'Active',
    'day_off_break': 'Day Off or Break',
    'no_pending_requests': 'No pending requests',
    'all_pending_processed':
        'All customer booking requests have been processed.',
    'tap_to_manage': 'Tap to manage',
  };

  static const Map<String, String> _myanmarTranslations = {
    // Customer Navigation Shell
    'nav_home': 'ပင်မ',
    'nav_bookings': 'ဘိုကင်များ',
    'nav_profile': 'ပရိုဖိုင်',

    // Provider Navigation Shell
    'provider_nav_dashboard': 'ဒက်ရှ်ဘုတ်',
    'provider_nav_bookings': 'ရက်ချိန်းများ',
    'provider_nav_services': 'ဝန်ဆောင်မှုများ',
    'provider_nav_staff': 'ဝန်ထမ်းများ',
    'provider_nav_profile': 'ဆိုင် ပရိုဖိုင်',

    // Customer Profile Screen
    'my_profile': 'ကျွန်ုပ်၏ ပရိုဖိုင်',
    'edit_profile': 'ပရိုဖိုင် ပြင်ဆင်ရန်',
    'edit_profile_desc': 'အမည်နှင့် အီးမေးလ် ပြင်ဆင်ရန်',
    'my_bookings': 'ကျွန်ုပ်၏ ဘိုကင်များ',
    'my_bookings_desc': 'ကြိုတင် ရက်ချိန်းများ ကြည့်ရှုရန်',
    'settings': 'ပြင်ဆင်ချက်များ',
    'settings_desc': 'ဘာသာစကား၊ အကြောင်းကြားချက် ပြင်ဆင်ချက်များ',
    'logout': 'ထွက်မည်',
    'logout_desc': 'အကောင့်မှ ထွက်ရန်',
    'confirm_logout_title': 'အကောင့်မှ ထွက်မည်လား?',
    'confirm_logout_msg': 'သင်၏ အကောင့်မှ ထွက်ရန် သေချာပါသလား?',
    'save_changes': 'ပြင်ဆင်ချက် သိမ်းဆည်းမည်',

    // Settings Screen
    'preferences': 'စိတ်ကြိုက်ပြင်ဆင်ချက်များ',
    'push_notifications': 'အကြောင်းကြားချက်များ',
    'push_notif_desc':
        'ကြိုတင်ဘိုကင် အသိပေးချက်များနှင့် သတိပေးချက်များ ရယူရန်',
    'language': 'ဘာသာစကား',
    'about_legal': 'အချက်အလက်များနှင့် စည်းကမ်းချက်များ',
    'privacy_policy': 'ကိုယ်ရေးအချက်အလက် မူဝါဒ',
    'terms_of_service': 'ဝန်ဆောင်မှု စည်းကမ်းချက်များ',
    'app_version': 'ဆော့ဖ်ဝဲလ် ဗားရှင်း',
    'choose_language': 'ဘာသာစကား ရွေးချယ်ပါ',
    'english': 'English',
    'myanmar': 'Myanmar (မြန်မာ)',
    'cancel': 'မလုပ်တော့ပါ',
    'turn_off': 'ပိတ်မည်',
    'confirm_turn_off_title': 'အကြောင်းကြားချက်များ ပိတ်မည်လား?',
    'confirm_turn_off_msg': 'အကြောင်းကြားချက်များ ပိတ်ထားပါက ကြိုတင်ဘိုကင် အခြေအနေများနှင့် သတိပေးချက်များ လွတ်သွားနိုင်ပါသည်။',

    // Home Screen
    'home_title': 'အနီးရှိ ဝန်ဆောင်မှုများ ရှာဖွေပါ',
    'search_hint': 'ဝန်ဆောင်မှုများ သို့မဟုတ် ဝန်ဆောင်မှုပေးသူများ ရှာရန်...',
    'explore_categories': 'ဝန်ဆောင်မှု ကဏ္ဍများ',
    'top_providers': 'ထိပ်တန်း ဝန်ဆောင်မှုပေးသူများ',
    'all_providers': 'ဝန်ဆောင်မှုပေးသူများ အားလုံး',
    'view_all': 'အားလုံးကြည့်ရန်',
    'no_providers_found': 'ဝန်ဆောင်မှုပေးသူ မတွေ့ရှိပါ။',
    'rating': 'အဆင့်သတ်မှတ်ချက်',

    // Bookings Screen
    'bookings_title': 'ကျွန်ုပ်၏ ရက်ချိန်းများ',
    'tab_all': 'အားလုံး',
    'tab_pending': 'စောင့်ဆိုင်းဆဲ',
    'tab_confirmed': 'အတည်ပြုပြီး',
    'tab_completed': 'ပြီးစီးခဲ့ပြီး',
    'tab_cancelled': 'ပယ်ဖျက်ပြီး',
    'no_bookings_found': 'ဘိုကင် မှတ်တမ်း မရှိသေးပါ။',
    'booking_status': 'အခြေအနေ',
    'date_time': 'ရက်စွဲနှင့် အချိန်',
    'service_name': 'ဝန်ဆောင်မှု',
    'total_price': 'စုစုပေါင်း ကျသင့်ငွေ',
    'view_details': 'အသေးစိတ်ကြည့်ရန်',
    'book_again': 'ထပ်မံ ဘိုကင်တင်မည်',

    // Provider Detail & Portal Screen
    'book_now': 'ဘိုကင် တင်မည်',
    'services': 'ဝန်ဆောင်မှုများ',
    'reviews': 'သုံးသပ်ချက်များ',
    'about': 'အချက်အလက်များ',
    'address': 'လိပ်စာ',
    'working_hours': 'ဆိုင်ဖွင့်ချိန်များ',
    'staff': 'ဝန်ထမ်းများ',
    'duration': 'ကြာမြင့်ချိန်',
    'price': 'ကျသင့်ငွေ',

    // Provider Portal Specific
    'provider_profile_title': 'ဆိုင် ပရိုဖိုင်',
    'edit_shop_profile': 'ဆိုင် ပရိုဖိုင် ပြင်ဆင်ရန်',
    'store_status': 'ဆိုင် ဖွင့်/ပိတ် အခြေအနေ',
    'status_available': 'ဘိုကင် အသစ်များ လက်ခံရန် အဆင်သင့်ရှိသည်',
    'status_busy': 'လက်ရှိ အလုပ်ရှုပ် / ပိတ်ထားသည်',
    'business_setup': 'ဆိုင် ပြင်ဆင်ချက်များ',
    'weekly_schedule': 'ဆိုင်ဖွင့်ချိန်များ ပြင်ဆင်ရန်',
    'schedule_desc': 'ဖွင့်ရက်များ၊ စတင်ချိန်နှင့် ပိတ်ချိန်များ သတ်မှတ်ရန်',
    'payment_methods': 'ငွေလက်ခံသည့် နည်းလမ်းများ',
    'payment_desc':
        'လက်ခံသည့် ငွေပေးချေမှု နည်းလမ်းများ (KPay, Wave, Cash, QR)',
    'earnings_insights': 'ဝင်ငွေနှင့် ဘိုကင် အချက်အလက်များ',
    'earnings_desc': 'နေ့စဉ် ဝင်ငွေနှင့် ဘိုကင် စာရင်းများ ကြည့်ရန်',
    'edit_description': 'ဆိုင်အကြောင်း ပြင်ဆင်ရန်',
    'account': 'အကောင့်',
    'logout_provider': 'ဆိုင် အကောင့်မှ ထွက်မည်',
    'dashboard_overview': 'ဒက်ရှ်ဘုတ် အနှစ်ချုပ်',
    'todays_bookings': 'ယနေ့ ရက်ချိန်းများ',
    'total_revenue': 'စုစုပေါင်း ဝင်ငွေ',
    'pending_approvals': 'စောင့်ဆိုင်းဆဲ တောင်းဆိုမှုများ',
    'manage_services': 'ဝန်ဆောင်မှုများ စီမံရန်',
    'manage_staff': 'ဝန်ထမ်းများ စီမံရန်',

    // Additional Provider Keys (Myanmar)
    'provider_dashboard_title': 'ဝန်ဆောင်မှုပေးသူ ဒက်ရှ်ဘုတ်',
    'provider_bookings_title': 'ရက်ချိန်းများ စီမံရန်',
    'provider_services_title': 'ဝန်ဆောင်မှုများ စီမံရန်',
    'provider_staff_title': 'ဝန်ထမ်းများ စီမံရန်',
    'weekly_schedule_title': 'ဆိုင်ဖွင့်ချိန်များ',
    'payment_methods_title': 'ငွေလက်ခံသည့် နည်းလမ်းများ',
    'earnings_title': 'ဝင်ငွေနှင့် ငွေလက်ခံမှုများ',
    'payment_history': 'ငွေလက်ခံမှု မှတ်တမ်း',
    'accept': 'လက်ခံမည်',
    'reject': 'ငြင်းပယ်မည်',
    'tab_accepted': 'လက်ခံပြီး',
    'tab_in_progress': 'ဆောင်ရွက်ဆဲ',
    'tab_no_show': 'မလာရောက်ခဲ့ပါ',
    'add_service': 'ဝန်ဆောင်မှု သစ်ထည့်ရန်',
    'add_staff': 'ဝန်ထမ်း သစ်ထည့်ရန်',
    'service_groups': 'ဝန်ဆောင်မှု အုပ်စုများ စီမံရန်',
    'service_mode_options':
        'ဝန်ဆောင်မှု အမျိုးအစားများ (အက်ဒမင် စစ်ဆေးရန် လိုအပ်)',
    'storefront_shop_mode': 'ဆိုင်သို့ လာရောက်သည့် ဝန်ဆောင်မှု',
    'storefront_shop_desc': 'ဆိုင်တွင်း ဘိုကင်နှင့် ဝန်ထမ်း ရွေးချယ်နိုင်မှု',
    'home_service_mode': 'အိမ်တိုင်ရာရောက် ဝန်ဆောင်မှု',
    'home_service_desc': 'ဝယ်ယူသူထံ သွားရောက် ဝန်ဆောင်မှုပေးခြင်း',
    'change_pending_admin': 'အက်ဒမင် ခွင့်ပြုချက် စောင့်ဆိုင်းနေဆဲ',
    'change_pending_desc': 'သင်၏ ပြင်ဆင်ချက်များကို အက်ဒမင်မှ စစ်ဆေးနေပါသည်။',
    'pick_location_map': 'မြေပုံပေါ်တွင် လိပ်စာ ရွေးမည်',
    'submit_to_admin': 'အက်ဒမင်ထံ တင်ပြမည်',
    'confirm_status_change': 'အခြေအနေ ပြောင်းလဲရန် အတည်ပြုပါ',
    'save_schedule': 'ဆိုင်ဖွင့်ချိန် ပြင်ဆင်ချက် သိမ်းမည်',
    'schedule_hint':
        'တစ်ပတ်တာ ဆိုင်ဖွင့်ရက်များနှင့် ဖွင့်ချိန်၊ ပိတ်ချိန်များ သတ်မှတ်ပါ။',
    'off_day': 'ပိတ်ရက်',
    'active_status': 'အလုပ်လုပ်နေသည်',
    'day_off_break': 'နားရက် / အနားယူချိန်',
    'no_pending_requests': 'စောင့်ဆိုင်းဆဲ တောင်းဆိုမှု မရှိပါ',
    'all_pending_processed':
        'ဘိုကင် တောင်းဆိုမှု အားလုံးကို ဆောင်ရွက်ပြီးပါပြီ။',
    'tap_to_manage': 'စီမံရန် နှိပ်ပါ',
  };
}
