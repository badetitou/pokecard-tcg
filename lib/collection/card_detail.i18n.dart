import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations.byText("en_us") +
      {
        "en_us": "Price:",
        "fr_fr": "Prix :",
      } +
      {
        "en_us": "Low",
        "fr_fr": "Bas",
      } +
      {
        "en_us": "Market",
        "fr_fr": "Marché",
      } +
      {
        "en_us": "Mid",
        "fr_fr": "Moyen",
      } +
      {
        "en_us": "High",
        "fr_fr": "Haut",
      } +
      {
        "en_us": "Illustrator: ",
        "fr_fr": "Illustrateur.rice : ",
      } +
      {
        "en_us": "View Card",
        "fr_fr": "Voir la carte",
      } +
      {
        "en_us": "Add a Card",
        "fr_fr": "Ajouter une carte",
      } +
      {
        "en_us": "Add a Card",
        "fr_fr": "Ajouter une carte à ma collection",
      } +
      {
        "en_us": "Add a card",
        "fr_fr": "Ajouter une carte",
      } +
      {
        "en_us": "Abort",
        "fr_fr": "Annuler",
      } +
      {
        "en_us": "Add",
        "fr_fr": "Ajouter",
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
      } +
      {
        "en_us": "Italian",
        "fr_fr": "Italien",
      } +
      {
        "en_us": "Spanish",
        "fr_fr": "Espagnol",
      } +
      {
        "en_us": "Chinese",
        "fr_fr": "Chinois",
      } +
      {
        "en_us": "German",
        "fr_fr": "Allemand",
      } +
      {
        "en_us": "Japanese",
        "fr_fr": "Japonais",
      } +
      {
        "en_us": "Korean",
        "fr_fr": "Coréen",
      } +
      {
        "en_us": "Quality",
        "fr_fr": "Qualité",
      } +
      {
        "en_us": "Language",
        "fr_fr": "Langue",
      } + {
        "en_us": "Add card to my collection",
        "fr_fr": "Ajouter la carte à ma collection",
      };

  String get i18n => localize(this, _t);
}
