import 'dart:ui';

class AdRegionService {
  /// Страны СНГ/России, где показываем Яндекс.Рекламу.
  /// Для всех остальных регионов используем AdMob.
  static const _yandexRegionCodes = {'RU', 'BY', 'KZ', 'UZ', 'KG', 'AM', 'AZ', 'TJ', 'TM'};

  static bool get shouldUseYandex {
    final locale = PlatformDispatcher.instance.locale;
    return _yandexRegionCodes.contains(locale.countryCode);
  }
}
