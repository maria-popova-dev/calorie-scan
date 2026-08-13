// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CalorieScan';

  @override
  String get homeTitle => 'Today';

  @override
  String get diaryTitle => 'Diary';

  @override
  String get addProductTitle => 'Add product';

  @override
  String get nameLabel => 'Name';

  @override
  String get caloriesLabel => 'Calories (kcal)';

  @override
  String get proteinLabel => 'Protein (g)';

  @override
  String get fatLabel => 'Fat (g)';

  @override
  String get carbsLabel => 'Carbs (g)';

  @override
  String get saveButton => 'Save';

  @override
  String get requiredField => 'Required field';

  @override
  String get enterNumber => 'Enter a number';

  @override
  String get noEntriesToday => 'No entries for today yet';

  @override
  String entriesToday(int count) {
    return 'Entries today: $count';
  }

  @override
  String get proteinShort => 'P';

  @override
  String get fatShort => 'F';

  @override
  String get carbsShort => 'C';

  @override
  String get approximateNote =>
      'Estimate based on general recognition — please verify';
}
