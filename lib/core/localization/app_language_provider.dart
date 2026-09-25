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
    // Navigation Shell
    'nav_home': 'Home',
    'nav_bookings': 'Bookings',
    'nav_profile': 'Profile',

    // Profile Screen
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
    'confirm_turn_off_msg':
        'If you turn off push notifications, you may miss critical booking updates, provider arrival alerts, and status reminders.',

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

    // Provider Detail Screen
    'book_now': 'Book Now',
    'services': 'Services',
    'reviews': 'Reviews',
    'about': 'About',
    'address': 'Address',
    'working_hours': 'Working Hours',
    'staff': 'Select Staff',
    'duration': 'Duration',
    'price': 'Price',
  };

  static const Map<String, String> _myanmarTranslations = {
    // Navigation Shell
    'nav_home': 'ပင်မ',
    'nav_bookings': 'ဘိုကင်များ',
    'nav_profile': 'ပရိုဖိုင်',

    // Profile Screen
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
    'push_notif_desc': 'ကြိုတင်ဘိုကင် အသိပေးချက်များနှင့် သတိပေးချက်များ ရယူရန်',
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
    'confirm_turn_off_msg':
        'အကြောင်းကြားချက်များ ပိတ်ထားပါက ကြိုတင်ဘိုကင် အခြေအနေများနှင့် သတိပေးချက်များ လွတ်သွားနိုင်ပါသည်။',

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

    // Provider Detail Screen
    'book_now': 'ဘိုကင် တင်မည်',
    'services': 'ဝန်ဆောင်မှုများ',
    'reviews': 'သုံးသပ်ချက်များ',
    'about': 'အချက်အလက်များ',
    'address': 'လိပ်စာ',
    'working_hours': 'ဆိုင်ဖွင့်ချိန်များ',
    'staff': 'ဝန်ထမ်း ရွေးချယ်ရန်',
    'duration': 'ကြာမြင့်ချိန်',
    'price': 'ကျသင့်ငွေ',
  };
}
