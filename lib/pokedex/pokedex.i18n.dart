import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations.byText("en-US") +
      {
        "en-US": "Pokemon Number ",
        "fr-FR": "Pokémon n° ",
      } +
      {
        "en-US": "All",
        "fr-FR": "Tous",
      } +
      {
        "en-US": "Catched",
        "fr-FR": "Attrapés",
      } +
      {
        "en-US": "Not catched",
        "fr-FR": "Non attrapés",
      };

  String get i18n => localize(this, _t);
}
