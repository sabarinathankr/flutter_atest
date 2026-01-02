import 'dart:async';
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(
        context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
  _AppLocalizationsDelegate();

  // 🔑 Language map
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'ATEST',
      'search_posts': 'Search posts...',
      'helpful_tips': 'Helpful Tips',
      'get_ready': 'GET READY TO RECORD',
      'no_internet': 'No Internet Connection',
      'language':'Language',
      'total_contribution':'Total Contribution',
      'user_dashboard': 'User Dashboard',
      'dashboard_description':'Welcome back! Here\'s what\'s happening today.',
      'logout':'Logout',
      'edit_profile_soon':'Edit Profile feature coming soon!',
      'edit_profile':'Edit Profile',
      'admin_dashboard':'Admin Dashboard',
      'total_users':'Total Users',
      'revenue':'Revenue',
      'quick_actions':'Quick Actions',
      'create_post':'Create Post',
      'tittle':'Title',
      'description':'Description',
      'youtube_link':'YouTube Link',
      'visibility':'Visibility',
      'private':'Private',
      'public':'Public',
      'publish':'Publish',
      'no_transaction_found':'No Transaction found in the selected month.',
      'amount':'Amount',
      'pay_now':'Pay Now',
      'select_month_year':'Select Month & Year',
      'cancel':'Cancel',
      'apply':'Apply',
      'please_login_to_proceed':'⚠️ Please login to proceed',
      'export_transactions':'Export Transactions',
      'choose_export_format':'Choose export format:',
    },
    'ta': {
      'title': 'ATEST',
      'search_posts': 'பதிவுகளைத் தேடுங்கள்...',
      'helpful_tips': 'பயனுள்ள குறிப்புகள்',
      'get_ready': 'பதிவு செய்ய தயாராகுங்கள்',
      'no_internet': 'இணைய இணைப்பு இல்லை',
      'language':'மொழி',
      'total_contribution':'மொத்த பங்களிப்பு',
      'user_dashboard': 'பயனர் டாஷ்போர்டு',
      'dashboard_description':'மீண்டும் வருக! இன்று என்ன நடக்கிறது என்பது இங்கே.',
      'logout':'வெளியேறு',
      'edit_profile_soon':'சுயவிவரத்தைத் திருத்து அம்சம் விரைவில் வருகிறது!',
      'edit_profile':'சுயவிவரத்தைத் திருத்து',
      'admin_dashboard':'நிர்வாக டாஷ்போர்டு',
      'total_users':'மொத்த பயனர்கள்',
      'revenue':'வருவாய்',
      'quick_actions':'விரைவான செயல்கள்',
      'create_post':'இடுகையை உருவாக்கவும்',
      'tittle':'தலைப்பு',
      'description':'விளக்கம்',
      'youtube_link':'YouTube இணைப்பு',
      'visibility':'தெரிவுநிலை',
      'private':'தனியார்',
      'public':'பொது',
      'publish':'வெளியிட',
      'no_transaction_found':'தேர்ந்தெடுக்கப்பட்ட மாதத்தில் எந்தப் பரிவர்த்தனையும் காணப்படவில்லை.',
      'amount':'தொகை',
      'pay_now':'செலுத்தவும்',
      'select_month_year':'மாதம் & ஆண்டைத் தேர்ந்தெடுக்கவும்',
      'cancel':'ரத்து செய்',
      'apply':'விண்ணப்பிக்கவும்',
      'please_login_to_proceed':'⚠️ தொடர உள்நுழையவும்',
      'export_transactions':'ஏற்றுமதி பரிவர்த்தனைகள்',
      'choose_export_format':'வடிவமைப்பைத் தேர்ந்தெடுக்கவும்:',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'ta'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}
