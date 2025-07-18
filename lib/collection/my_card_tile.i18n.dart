import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static final _t = Translations.byText("en-US") +
      {
        "en-US": "Remove",
        "fr-FR": "Supprimer",
      } +
      {
        "en-US": "Mint",
        "fr-FR": "Parfaite",
      } +
      {
        "en-US": "Near Mint",
        "fr-FR": "Presque parfaite",
      } +
      {
        "en-US": "Played",
        "fr-FR": "Jouée",
      } +
      {
        "en-US": "Damaged",
        "fr-FR": "Endomagée",
      } +
      {
        "en-US": "English",
        "fr-FR": "Anglais",
      } +
      {
        "en-US": "French",
        "fr-FR": "Français",
      };

  String get i18n => localize(this, _t);
}
