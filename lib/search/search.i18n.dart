import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations("en_us") +
      {
        "en_us": "Search... [name:bulba*]",
        "fr": "Rechercher... [name:bulba*]",
      } +
      {
        "en_us": "Request:",
        "fr": "Requêtes:",
      } +
      {
        "en_us": "Keyword matching:",
        "fr": "Correspondance des mots-clés :",
      } +
      {
        "en_us":
            'Search for all cards that have "charizard" in the name field:',
        "fr": 'Recherchez toutes les cartes qui ont "charizard" comme nom :',
      } +
      {
        "en_us":
            'Search for “charizard” in the name field AND the type “mega” in the subtypes field:',
        "fr":
            'Recherchez "charizard" comme nom ET le type "mega" comme un des  sous-types :',
      } +
      {
        "en_us":
            'Search for “charizard” in the name field AND either the subtypes of “mega” or “vmax":',
        "fr":
            'Recherchez "charizard" comme nom ET les sous-types "mega" ou "vmax".',
      } +
      {
        "en_us":
            'Search for any card that starts with “char” in the name field.',
        "fr":
            'Recherchez toute carte dont le nom commence par "char" dans le champ du nom.',
      } +
      {
        "en_us": 'Range Searches:',
        "fr": 'Recherche par numéro :',
      } +
      {
        "en_us": 'Search for only cards that feature the original 151 pokemon:',
        "fr":
            'Recherchez uniquement les cartes qui présentent les 151 pokémons originaux :',
      };

  String get i18n => localize(this, _t);
}
