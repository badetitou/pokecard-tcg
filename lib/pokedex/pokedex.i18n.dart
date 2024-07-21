import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations.byText("en_us") +
      {
        "en_us": "Pokemon Number ",
        "fr_fr": "Pokémon n° ",
      } +
      {
        "en_us": "All",
        "fr_fr": "Tous",
      } +
      {
        "en_us": "Catched",
        "fr_fr": "Attrapés",
      } +
      {
        "en_us": "Not catched",
        "fr_fr": "Non attrapés",
      };

  String get i18n => localize(this, _t);
}
