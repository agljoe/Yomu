# ``Chapter``

## Topics

### Creating a Chapter

- ``Chapter/init(from:)``

### Getting Chapers

- ``MangaDexAPIRequestManager/getChapter(_:)``
- ``MangaDexAPIRequestManager/getChapters(_:limit:offset:)``

### Getting Chapter Images

- ``MangaDexAPIRequestManager/getChapterComponents(_:)``

### Comparing Chapters

- ``Chapter/==(_:_:)``

### Filtering by Language

- ``Chapter/translatedLanguage``

### Getting Chapter Uploaders

- ``Chapter/scanlationGroup``
- ``Chapter/user``

### Getting a Parent Manga

- ``Chapter/parentManga``

### Getting Read Markers

- ``MangaDexAPIRequestManager/getReadMarker(_:)``
- ``MangaDexAPIRequestManager/getReadMarkers(_:)``

### Setting Read Markers

- ``MangaDexAPIRequestManager/updateReadMarkers(mangaID:readChapters:unreadChapters:)``

### Getting Statistics

- ``MangaDexAPIRequestManager/getStatistics(for:)->ChapterStatistics``
- ``MangaDexAPIRequestManager/getStatistics(for:)-66kp5``

### Loading Chapter Feeds

- ``MangaDexAPIRequestManager/getCustomFeed(_:limit:offset:)``
- ``MangaDexAPIRequestManager/getFollowedFeed(limit:offset:)``

### Storing a Chapter

- ``StoredChapter/init(from:with:hasBeenRead:)``

### Appears in

- ``AtHomeChapterComponents``
- ``ChapterEntity``
- ``ChapterListEntity``
- ``CustomFeedEntity``
- ``FollowedFeedEntity``
- ``MangaFeedEntity``
- ``ChapterStatistics``
- ``StoredChapter``

