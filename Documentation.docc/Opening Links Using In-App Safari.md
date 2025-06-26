# Opening Links Using In-App Safari

Display webpages without leaving your app.

## Overview

SwiftUI does not have a navite Safari view implementation, so it is necessary to wrap UIKit's SFSafariViewController. This applictaion uses an adaptation of [BetterSafariView](https://github.com/stleamist/BetterSafariView/tree/main) updated for Swift 6 complete concurrency support.

## Topics

### Views

- ``SafariView``

### UIKit Wrappers

- ``SafariViewPresenter``
- ``SafariViewPresentationModifier``
- ``SafariItemViewPresentationModifier``

### Extensions

- ``UIKit/UIWindow/farthestPresentedViewController``
- ``Swift/Bool/id``
- ``Foundation/URL/id``
- ``SwiftUICore/View/safariView(item:onDismiss:content:)``
- ``SwiftUICore/View/safariView(isPresented:onDismiss:content:)``
