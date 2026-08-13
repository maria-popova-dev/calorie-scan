// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'CalorieScan';

  @override
  String get homeTitle => 'Сегодня';

  @override
  String get diaryTitle => 'Дневник';

  @override
  String get addProductTitle => 'Добавить продукт';

  @override
  String get nameLabel => 'Название';

  @override
  String get caloriesLabel => 'Калории (ккал)';

  @override
  String get proteinLabel => 'Белки (г)';

  @override
  String get fatLabel => 'Жиры (г)';

  @override
  String get carbsLabel => 'Углеводы (г)';

  @override
  String get saveButton => 'Сохранить';

  @override
  String get requiredField => 'Обязательное поле';

  @override
  String get enterNumber => 'Введите число';

  @override
  String get noEntriesToday => 'Пока нет записей за сегодня';

  @override
  String entriesToday(int count) {
    return 'Записей за сегодня: $count';
  }

  @override
  String get proteinShort => 'Б';

  @override
  String get fatShort => 'Ж';

  @override
  String get carbsShort => 'У';

  @override
  String get approximateNote =>
      'Приблизительная оценка — проверьте и при необходимости скорректируйте';
}
