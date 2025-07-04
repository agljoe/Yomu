# Image Loaders

Present images by asnychronously loading data from a remote server.

## Overview

MangaDex imposes some loose rate limits and restrictions on image hosting. In order to stay within the specified guidelines and reduce unnecesary networking two custom image loaders are implemented. For more information on retrieving images from MangaDex see [Retrieving a chapter's images](https://api.mangadex.org/docs/04-chapter/retrieving-chapter/).

Since covers are not frequently updated its easy to cache them away for later. Chapter images posed a differenty image of at-home reports that could notify MangaDex of server status, but apparently it is basically depricated now and not necessary. I would be nice if they updated their documentation because failing reports were considered network errors. 

In the end I just commented out the at-home reporting code.

## Topics

### Loaders

- ``CachedAsyncImage``
- ``ChapterPageImage``
- ``ImageLoader``

### Environment Values

- ``SwiftUICore/EnvironmentValues/imageLoader``
