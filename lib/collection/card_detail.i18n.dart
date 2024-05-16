import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations.byText("en_us") +
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
      } +
      {
        "en_us": "Italian",
        "fr": "Italien",
      } +
      {
        "en_us": "Spanish",
        "fr": "Espagnol",
      } +
      {
        "en_us": "Chinese",
        "fr": "Chinois",
      } +
      {
        "en_us": "German",
        "fr": "Allemand",
      } +
      {
        "en_us": "Japanese",
        "fr": "Japonais",
      } +
      {
        "en_us": "Korean",
        "fr": "Coréen",
      } +
      {
        "en_us": "Quality",
        "fr": "Qualité",
      } +
      {
        "en_us": "Language",
        "fr": "Langue",
      } + {
        "en_us": "Add card to my collection",
        "fr": "Ajouter la carte à ma collection",
      };

  String get i18n => localize(this, _t);
}
