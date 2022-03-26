import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations("en_us") +
      {
        "en_us": "My Collection",
        "fr": "Ma Collection",
      } +
      {
        "en_us": "Search",
        "fr": "Rechercher",
      } +
      {
        "en_us": "Backed up!",
        "fr": "Pokédex sauvegardé !",
      } +
      {
        "en_us": "Restored!",
        "fr": "Pokédex restauré !",
      } +
      {
        "en_us": "Backup Pokédex",
        "fr": "Sauvegarder le Pokédex",
      } +
      {
        "en_us": "Restore Pokédex",
        "fr": "Restaurer le Pokédex",
      };

  String get i18n => localize(this, _t);
}
