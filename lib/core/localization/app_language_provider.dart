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
    'settings': 'Settings',
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
    'home': 'Home',
    'bookings': 'Bookings',
    'profile': 'Profile',
    'search_hint': 'Search services, providers...',
    'categories': 'Categories',
  };

  static const Map<String, String> _myanmarTranslations = {
    'settings': 'ပြင်ဆင်ချက်များ',
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
    'home': 'ပင်မ',
    'bookings': 'ဘိုကင်များ',
    'profile': 'ပရိုဖိုင်',
    'search_hint': 'ဝန်ဆောင်မှုများ သို့မဟုတ် ဝန်ဆောင်မှုပေးသူများ ရှာရန်...',
    'categories': 'ကဏ္ဍများ',
  };
}
