import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations.byText("en-US") +
      {
        "en-US": "My Collection",
        "fr-FR": "Ma Collection",
      } +
      {
        "en-US": "Search",
        "fr-FR": "Rechercher",
      } +
      {
        "en-US": "Backed up!",
        "fr-FR": "Pokédex sauvegardé !",
      } +
      {
        "en-US": "Restored!",
        "fr-FR": "Pokédex restauré !",
      } +
      {
        "en-US": "Backup Pokédex",
        "fr-FR": "Sauvegarder le Pokédex",
      } +
      {
        "en-US": "Restore Pokédex",
        "fr-FR": "Restaurer le Pokédex",
      } +
      {
        "en-US": "Search... [name:bulba*]",
        "fr-FR": "Rechercher... [name:bulba*]",
      } +
      {
        "en-US": "Request:",
        "fr-FR": "Requêtes:",
      } +
      {
        "en-US": "Keyword matching:",
        "fr-FR": "Correspondance des mots-clés :",
      } +
      {
        "en-US":
            'Search for all cards that have "charizard" in the name field:',
        "fr-FR": 'Rechercher toutes les cartes qui ont "charizard" comme nom :',
      } +
      {
        "en-US":
            'Search for "charizard" in the name field AND the type "mega" in the subtypes field:',
        "fr-FR":
            'Rechercher "charizard" comme nom ET le type "mega" comme un des  sous-types :',
      } +
      {
        "en-US":
            'Search for "charizard" in the name field AND either the subtypes of "mega" or "vmax":',
        "fr-FR":
            'Rechercher "charizard" comme nom ET les sous-types "mega" ou "vmax" :',
      } +
      {
        "en-US":
            'Search for any card that starts with "char" in the name field:',
        "fr-FR":
            'Rechercher toute carte dont le nom commence par "char" dans le champ du nom :',
      } +
      {
        "en-US": 'Range Searches:',
        "fr-FR": 'Recherche par numéro :',
      } +
      {
        "en-US": 'Search for only cards that feature the original 151 pokemon:',
        "fr-FR":
            'Rechercher uniquement les cartes qui présentent les 151 pokémons originaux :',
      } +
      {
        "en-US": 'Wildcard Matching:',
        "fr-FR": 'Rechercher caractères génériques :',
      };

  String get i18n => localize(this, _t);
}
