import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations("en_us") +
      {
        "en_us": "Pokemon Number ",
        "fr": "Pokémon n° ",
      } +
      {
        "en_us": "All",
        "fr": "Tous",
      } +
      {
        "en_us": "Catched",
        "fr": "Attrapés",
      } +
      {
        "en_us": "Not catched",
        "fr": "Non attrapés",
      };

  String get i18n => localize(this, _t);
}
