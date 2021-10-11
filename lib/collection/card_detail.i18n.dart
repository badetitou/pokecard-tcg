import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations("en_us") +
      {
        "en_us": "Price:",
        "fr": "Prix :",
      } +
      {
        "en_us": "Low",
        "fr": "Bas",
      } +
      {
        "en_us": "Market",
        "fr": "Marché",
      } +
      {
        "en_us": "Mid",
        "fr": "Moyen",
      } +
      {
        "en_us": "High",
        "fr": "Haut",
      } +
      {
        "en_us": "Illustrator: ",
        "fr": "Illustrateur.rice : ",
      } +
      {
        "en_us": "View Card",
        "fr": "Voir la carte",
      } +
      {
        "en_us": "Add a Card",
        "fr": "Ajouter une carte",
      } +
      {
        "en_us": "Add a Card",
        "fr": "Ajouter une carte à ma collection",
      } +
      {
        "en_us": "Add a card",
        "fr": "Ajouter une carte",
      } +
      {
        "en_us": "Abort",
        "fr": "Annuler",
      } +
      {
        "en_us": "Add",
        "fr": "Ajouter",
      };

  String get i18n => localize(this, _t);
}
