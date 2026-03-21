
# Changelog

## 1.3.0

- Migrated card search and card detail retrieval from `api.pokemontcg.io` to TCGdex REST API (`api.tcgdex.net`).
- Added a query translator to keep existing in-app search syntax compatible (`name:`, `type:`, `hp>`, `nationalPokedexNumbers:`).
- Updated card model parsing to support TCGdex payloads and image asset URLs.
- Added pricing mapping for TCGdex `pricing.tcgplayer` and `pricing.cardmarket`.
- Improved resilience of the collection and detail pages when remote card data is temporarily unavailable.
- Fixed a crash when adding cards without `nationalPokedexNumbers`.
- Fixed Pokédex card filtering by using exact `dexId` matching (`eq:`) with TCGdex.
- Fixed duplicated cards in infinite scrolling by preventing duplicate page listeners/requests.
- Added unit tests for TCGdex mapping and query translation.
- Added a widget regression test for duplicated pagination requests on search pages.

## 1.2.12

- Added image caching with cached_network_image for a smoother and offline-friendly experience.

## 1.2.9

- Update pokedex

## 1.2.8

- Making switch from to catched and not catched pokemon super fast
- Optimize view my_collection

## 1.2.7

- Can specify minimum number of card on each row
- Fix size card on card detail

## 1.2.6

- Fix issue when searching for inclomplete data in the API

## 1.2.5

- Add scrollbar

## 1.2.4

- Can add card without any type specification (holofoid, normal, and so on)
