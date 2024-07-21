import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations.byText("en_us") +
      {
        "en_us": "Remove",
        "fr_fr": "Supprimer",
      } +
      {
        "en_us": "Mint",
        "fr_fr": "Parfaite",
      } +
      {
        "en_us": "Near Mint",
        "fr_fr": "Presque parfaite",
      } +
      {
        "en_us": "Played",
        "fr_fr": "Jouée",
      } +
      {
        "en_us": "Damaged",
        "fr_fr": "Endomagée",
      } +
      {
        "en_us": "English",
        "fr_fr": "Anglais",
      } +
      {
        "en_us": "French",
        "fr_fr": "Français",
      };

  String get i18n => localize(this, _t);
}
