import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations("en_us") +
      {
        "en_us": "Remove",
        "fr": "Supprimer",
      } +
      {
        "en_us": "Mint",
        "fr": "Parfaite",
      } +
      {
        "en_us": "Near Mint",
        "fr": "Presque parfaite",
      } +
      {
        "en_us": "Played",
        "fr": "Jouée",
      } +
      {
        "en_us": "Damaged",
        "fr": "Endomagée",
      } +
      {
        "en_us": "English",
        "fr": "Anglais",
      } +
      {
        "en_us": "French",
        "fr": "Français",
      };

  String get i18n => localize(this, _t);
}
