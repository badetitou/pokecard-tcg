import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations.byText("en_us") +
      {
        "en_us": "My Collection",
        "fr_fr": "Ma Collection",
      };

  String get i18n => localize(this, _t);
}
