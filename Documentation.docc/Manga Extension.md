# ``Manga``

## Topics

### Creating a Manga

- ``Manga/init(from:)``

### Getting Manga

- ``MangaDexAPIRequestManager/getManga(_:)``
- ``MangaDexAPIRequestManager/getManga(_:limit:offset:)``
- ``MangaDexAPIRequestManager/getRandomManga()``

### Getting the Chapters for a Manga

- ``MangaDexAPIRequestManager/getChapters(for:limit:offset:)``

### Getting all Covers for a Manga

- ``MangaDexAPIRequestManager/getCovers(mangaIDs:limit:offset:)``

### Following

- ``MangaDexAPIRequestManager/follow(manga:)``

### Unfollowing

- ``MangaDexAPIRequestManager/unfollow(manga:)``

### Finding Followed Manga

- ``MangaDexAPIRequestManager/checkIfMangaIsFollowed(_:)``

### Getting Reading Statustes

- ``MangaDexAPIRequestManager/getReadingStatus(for:)``
- ``MangaDexAPIRequestManager/getAllReadingStatus()``

### Updating Reading Statuses

- ``MangaDexAPIRequestManager/updateReadingStatus(for:to:)``

### Getting Statisics

- ``MangaDexAPIRequestManager/getStatistics(for:)-9mjxm``
- ``MangaDexAPIRequestManager/getStatisics(for:)``

### Getting Available Tags

- ``MangaDexAPIRequestManager/getTags()``

### Filtering by Language

- ``Manga/originalLanguage``

### Finding Titles

- ``Manga/title``
- ``Manga/localizedTitle``
- ``Manga/alternateTitle``

### Finding Titles in Multiple Languages

- ``Manga/altTitles``

### Finding Translations

- ``Manga/availableTranslatedLanguages``

### Storing a Manga

- ``StoredManga/init(from:)``

### Appears in

- ``RelatedManga``
- ``MangaEntity``
- ``MangaListEntity``
- ``RandomMangaEntity``
- ``MangaStatistics``
- ``StoredManga``
