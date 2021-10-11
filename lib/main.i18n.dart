import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations("en_us") +
      {
        "en_us": "My Collection",
        "fr": "Ma Collection",
      } +
      {
        "en_us": "Search",
        "fr": "Rechercher",
      };

  String get i18n => localize(this, _t);
}
