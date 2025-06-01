# ``CompactManga``

## Overview

This type is required for decoding the reference expansion of an author or artist. Since ``Manga`` are designed to alwyas fetch their expanded references simply using a manga type to decode an author's reference expansion will cause a crash. 

A compact manga can be used to create a stored manga instance given that its references are supplied to the initialized.

## Topics

### Creating a Compact Manga

- ``CompactManga/init(from:)``

### Comparing Compact Manga

- ``CompactManga/==(_:_:)``

### Storing a Compact Manga

- ``StoredManga/init(from:with:author:artist:readingStatus:isFollowed:)``

### Appears in

- ``Author``
- ``StoredAuthor``
