import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations.byText("en-US") +
      {
        "en-US": "Price:",
        "fr-FR": "Prix :",
      } +
      {
        "en-US": "Low",
        "fr-FR": "Bas",
      } +
      {
        "en-US": "Market",
        "fr-FR": "Marché",
      } +
      {
        "en-US": "Mid",
        "fr-FR": "Moyen",
      } +
      {
        "en-US": "High",
        "fr-FR": "Haut",
      } +
      {
        "en-US": "Illustrator: ",
        "fr-FR": "Illustrateur.rice : ",
      } +
      {
        "en-US": "View Card",
        "fr-FR": "Voir la carte",
      } +
      {
        "en-US": "Add a Card",
        "fr-FR": "Ajouter une carte",
      } +
      {
        "en-US": "Add a Card",
        "fr-FR": "Ajouter une carte à ma collection",
      } +
      {
        "en-US": "Add a card",
        "fr-FR": "Ajouter une carte",
      } +
      {
        "en-US": "Abort",
        "fr-FR": "Annuler",
      } +
      {
        "en-US": "Add",
        "fr-FR": "Ajouter",
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
      } +
      {
        "en-US": "Italian",
        "fr-FR": "Italien",
      } +
      {
        "en-US": "Spanish",
        "fr-FR": "Espagnol",
      } +
      {
        "en-US": "Chinese",
        "fr-FR": "Chinois",
      } +
      {
        "en-US": "German",
        "fr-FR": "Allemand",
      } +
      {
        "en-US": "Japanese",
        "fr-FR": "Japonais",
      } +
      {
        "en-US": "Korean",
        "fr-FR": "Coréen",
      } +
      {
        "en-US": "Quality",
        "fr-FR": "Qualité",
      } +
      {
        "en-US": "Language",
        "fr-FR": "Langue",
      } +
      {
        "en-US": "Add card to my collection",
        "fr-FR": "Ajouter la carte à ma collection",
      };

  String get i18n => localize(this, _t);
}
