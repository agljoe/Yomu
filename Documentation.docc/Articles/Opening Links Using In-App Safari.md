# Opening Links Using In-App Safari

Display webpages without leaving your app.

## Overview

SwiftUI does not have a navite Safari view implementation, so it is necessary to wrap UIKit's SFSafariViewController. This applictaion uses an adaptation of [BetterSafariView](https://github.com/stleamist/BetterSafariView/tree/main) updated for Swift 6 complete concurrency support.

In truth the most of the modification was main actor isolation the wrappers, which is inline with SwiftUI views that are all updated on the main actor.

Also its really funny that I searched for this implementation then like 2 months later Apple announces WebViews in the WWDC 25 [What's new in SwiftUI](https://developer.apple.com/videos/play/wwdc2025/256).

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
