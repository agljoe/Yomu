# Image Loaders

Present images by asnychronously loading data from a remote server.

## Overview

MangaDex imposes some loose rate limits and restrictions on image hosting. In order to stay within the specified guidelines and reduce unnecesary networking two custom image loaders are implemented. For more information on retrieving images from MangaDex see [Retrieving a chapter's images](https://api.mangadex.org/docs/04-chapter/retrieving-chapter/).

## Topics

### Loaders

- ``CachedAsyncImage``
- ``ChapterPageImage``
- ``ImageLoader``

### Environment Values

- ``SwiftUICore/EnvironmentValues/imageLoader``
