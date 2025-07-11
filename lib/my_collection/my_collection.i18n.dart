import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations.byText("en-US") +
      {
        "en-US": "My Collection",
        "fr-FR": "Ma Collection",
      };

  String get i18n => localize(this, _t);
}
