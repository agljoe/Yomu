//
//  SafariView.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-05-09.
//

import SafariServices
import SwiftUI
import UIKit

extension UIWindow {
    /// The view controller that was presented modally on top of the window.
    var farthestPresentedViewController: UIViewController? {
        guard let rootViewController = rootViewController else { return nil }
        return Array(sequence(first: rootViewController, next: \.presentedViewController)).last
    }
}

extension Bool: @retroactive Identifiable {
    /// Allows booleanss to be used where indentifiable conformance is required, but
    /// does not garuntee uniqueness of boolean type variables.
    public var id: Bool { self }
}

extension URL: @retroactive Identifiable {
    public var id: String { self.absoluteString }
}

/// A wrapper around `SFSafariViewController` which displays a webpage using the in-app Safari brower.
///
/// - Note: This view is not constructed using `@ViewBuilder` since Apple has explicitly stated that `SFSafariViewControllers` should always
///         be presented modally.
@MainActor
public struct SafariView {
    /// Renames SFSafari's view controller configuration' so `SafariView` has the distinct member configuration/.
    typealias Configuration = SFSafariViewController.Configuration
    
    /// Renames SFSafari's view controller dismiss button style so `SafariView` has the distinct member `dismissButtonStyle`.
    typealias DismissButtonStyle = SFSafariViewController.DismissButtonStyle
    
    /// The URL of the page displayed by this view.
    let url: URL
    
    /// The configuration used by the wrapped  SFSafariViewController.
    let configuration: Configuration
    
    /// Initializes and configures a Safari view controller that loads the specified URL.
    ///
    /// - Parameters:
    ///   - url: the URL to navigate to. The URL must use the http or https scheme.
    ///   - configuration: the configuration for the new view controller.
    ///
    /// - Returns: a newly created SafariView.
    init(url: URL, configuration: Configuration = .init()) {
        self.url = url
        self.configuration = configuration
    }
    
    /// The color to tint the navigation bar and toolbar.
    var barTintColor: UIColor?
    
    /// The color to tint the buttons on the navigation bar and toolbar.
    var controlTintColor: UIColor?
    
    /// The style of the button used to dismiss this view.
    var dismissButtonStyle: DismissButtonStyle? = .done
    
    /// Sets the tint of the navigation bar and toolbar to the specified color.
    ///
    /// - Parameter color: the color the navigation bar and tool bar will be tinited with.
    ///
    /// - Returns: a copy of `self` that has had its barTIntColor set to the specified `color`.
    ///
    /// - Note: If the specified color cannot be instantiated as a `UIColor` the navigation bar and toolbar will have no tint.
    func preferredBarAccentColor(_ color: Color?) -> Self {
        var modified = self
        if let color = color { modified.barTintColor = UIColor(color) } else {  modified.barTintColor = nil }
        return modified
    }
    
    /// Sets the color of any buttons on the navigation bar and toolbar to the specifed color.
    ///
    /// - Parameter color: the color the buttons on the navigation bar and toolbar will be tinted with.
    ///
    /// - Returns: a copy of `self` that has had its navigation bar and toolbar button colors set to the specified `color`.
    ///
    /// - Note: : If the specified color cannot be instantiated as a `UIColor` the navigation bar and toolbar buttons will have their default color.
    func preferredControlAccentColor(_ color: Color?) -> Self {
        var modified = self
        if let color = color {  modified.controlTintColor = UIColor(color) } else {  modified.controlTintColor = nil }
        return modified
    }
    
    /// Sets which text will be presented as the dismiss buttion.
    ///
    /// The availaible styles are `Done`, `Close`, and `Cancel`.
    ///
    /// - Parameter style: the style the dismiss buttion will be set to.
    ///
    /// - Returns: a copy of `self` with the dismiss button set to the specified `style`.
    ///
    /// - Note: SafarVIew uses the `.done` style by default.
    func dismissButtonStyle(_ style: DismissButtonStyle) -> Self {
        var modified = self
        modified.dismissButtonStyle = style
        return modified
    }
    
    /// Applies the `barTintColor`, `controlTintColor`, and `dismissButtonStyle` to the wrapped SFSafariViewController.
    ///
    /// - Parameter safariViewController: the safari view controller whose styles are being set.
    func applyModification(to safariViewController: SFSafariViewController) {
        safariViewController.preferredBarTintColor = barTintColor
        safariViewController.preferredControlTintColor = controlTintColor
        safariViewController.dismissButtonStyle = dismissButtonStyle ?? .done
    }
}

extension SafariView.Configuration {
    /// Allows for the initialization of `SFSafariViewController.configuration` with only the entersReaderIfavailable, and
    /// barCollapsingEnabled members.
    ///
    /// - Parameters:
    ///   - entersReaderIfAvailable: indicates if the webpage presented by a SafariView should automatically enter reader mode, false by default.
    ///   - barCollapsingEnabled: indicates if the naviagtion bar and toolbar can be collapsed, true by default.
    ///
    /// - Returns: a newly created SafariView configuration.
    convenience init(entersReaderIfAvailable: Bool = false, barCollapsingEnabled: Bool = true) {
        self.init()
        self.entersReaderIfAvailable = entersReaderIfAvailable
        self.barCollapsingEnabled = barCollapsingEnabled
    }
}

extension SafariView: View {
    /// The representable used to control the wrapped `SFSafariViewController`.
    struct Representable: UIViewControllerRepresentable {
        typealias UIViewControllerType = SFSafariViewController
        
        /// The view using this representable.
        private var parent: SafariView
        
        /// Creates a new Representable for the given SafariView.
        ///
        /// - Parameter parent: the SafariView this representable will be used by.
        ///
        /// - Returns: a newly created Representable.
        init(parent: SafariView) {
            self.parent = parent
        }
        
        /// Creates a SFSafariViewController from `parent`.
        ///
        /// - Parameter context: this parameter is not used.
        ///
        /// - Returns: a configured SFSafariViewController.
        func makeUIViewController(context: Context) -> SFSafariViewController {
            let safariViewController = SFSafariViewController(url: parent.url, configuration: parent.configuration)
            safariViewController.modalPresentationStyle = .none
            parent.applyModification(to: safariViewController)
            return safariViewController
        }
        
        /// Applies styles to an SFSafariViewController.
        ///
        /// - Parameters:
        ///     - uiViewController: the SFSafariViewController being updated.
        ///     - context: this parameter is not used.
        func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
            parent.applyModification(to: uiViewController)
        }
    }
    
    /// Displays the wrapped SFSafariView representable.
    public var body: some View {
        Representable(parent: self)
            .ignoresSafeArea(edges: .all)
    }
}

/// Presents the SFSafariView wrapped by SafariView.
struct SafariViewPresenter<Item: Identifiable>: UIViewRepresentable {
    /// The item presented in a SafariView.
    @Binding var item: Item?
    
    /// The closure preformed when this representable's UIView is dimissed.
    var onDismiss: (() -> Void)? = nil
    
    /// A closure that creates a SafariView with the given item.
    var representationBuilder: (Item) -> SafariView
    
    /// Gets a UIView from the coordinator.
    ///
    /// - Parameter context: this parameter is not used.
    ///
    /// - Returns: a UIView from the coordinator.
    func makeUIView(context: Context) -> UIView {
        context.coordinator.uiView
    }
    
    /// Updates the UIView being presented using the Coordinator.
    ///
    /// - Parameters:
    ///   - uiView: this parameter is not used.
    ///   - context: this parameter is not used.
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.item = item
        context.coordinator.parent = self
    }
    
    /// Creates a new Coordinator for this representable.
    ///
    /// - Returns: a newly created Coordinator.
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}

extension SafariViewPresenter {
    /// The coordinator used to mange communication between the SafariViewPresenter representable,
    /// and other SwiftUI Views.
    ///
    /// - Note: This class uses  `@preconcurrency` for its SFSafariViewControllerDelegate conformance based on recommendations
    ///         from Apple engineers. See [Implementing a Main Actor Protocol That’s Not @MainActor](https://developer.apple.com/forums/thread/760769)
    @MainActor
    class Coordinator: NSObject, @preconcurrency SFSafariViewControllerDelegate {
        /// The representable being coordinated with a SwfitUI View.
        var parent: SafariViewPresenter
        
        /// Creates a new Coordinater for the given SafariViewPresenter.
        ///
        /// - Parameter parent: a SafariViewPresenter that comunicates with a SwiftUI View.
        ///
        /// - Returns: a newly created Coordinator.
        init(parent: SafariViewPresenter) {
            self.parent = parent
        }
        
        /// The UIView used to present an SFSafariViewController.
        let uiView = UIView()
        
        /// The SFSafariViewController being presented.
        private weak var safariViewController: SFSafariViewController?
        
        /// The item being presented.
        ///
        /// Updates on change.
        var item: Item? {
            didSet(oldItem) {
                handleItemChange(from: oldItem, to: item)
            }
        }
        
        /// Presents a new SafariView if newItem is not oldItem.
        ///
        /// - Parameters:
        ///   - oldItem: the item currently being presented.
        ///   - newItem: the item to be presented.
        private func handleItemChange(from oldItem: Item?, to newItem: Item?) {
            switch(oldItem, newItem) {
            case let(.some(oldItem), .some(newItem)) where oldItem.id != newItem.id:
                dismissSafariViewController() { self.presentSafariViewController(with: newItem) }
            case let(.some, .some(newItem)):
                updateSafariViewController(with: newItem)
            case let(.none, .some(newItem)):
                presentSafariViewController(with: newItem)
            case (.some, .none):
                dismissSafariViewController()
            case (.none, .none):
                ()
            }
        }
        
        /// Presents an SFSafariViewController for the given items.
        ///
        /// The SFSafariViewController will not be presented if the rootViewController cannot be located.
        ///
        /// - Parameter item: the item used by the parent's representation builder.
        private func presentSafariViewController(with item: Item) {
            let representation = parent.representationBuilder(item)
            let safariViewController = SFSafariViewController(url: representation.url, configuration: representation.configuration)
            safariViewController.delegate = self
            representation.applyModification(to: safariViewController)
            
            guard let presentingViewController = uiView.window?.farthestPresentedViewController else {
                assertionFailure( "Cannot find the view controller to present from. This happens when a 'SafariViewPresenter' is detached from the window,or the window doesn't have 'rootViewController.'")
                self.resetItemBinding()
                return
            }
            
            presentingViewController.present(safariViewController, animated: true)
            self.safariViewController = safariViewController
        }
        
        /// Creates a new SFSafariViewController for the given item.
        ///
        /// - Parameter item: the item used by the parent's representation builder.
        private func updateSafariViewController(with item: Item) {
            guard let safariViewController = safariViewController else { return }
            let representation = parent.representationBuilder(item)
            representation.applyModification(to: safariViewController)
        }
        
        /// Dismisses this coordinator's SFSafariViewController.
        ///
        /// - Parameter dimissSafariViewController: the closure run when this coordinators view controller is dismissed.
        private func dismissSafariViewController(completion: (() -> Void)? = nil) {
            guard let safariViewController = safariViewController else { return }
            safariViewController.dismiss(animated: true) {
                self.handleDismissal()
                completion?()
            }
        }
        
        /// Removes the item from this coordinator's representable.
        private func resetItemBinding() {
            parent.item = nil
        }
        
        /// Propagates dimissal to this coordinator's representable.
        private func handleDismissal() {
            parent.onDismiss?()
        }
        
        /// Performs an item reset and view dismissal.
        private func resetItemBindingAndHandleDismissal() {
            resetItemBinding()
            handleDismissal()
        }
        
        /// Ensures that the SFSafariViewController managed by this coordinator is properly dismissed when it is
        /// no longer being used.
        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            resetItemBindingAndHandleDismissal()
        }
    }
}

/// A view modifier that allows a SafariView to be presented in a similar manner to a sheet.
struct SafariViewPresentationModifier: ViewModifier {
    /// A boolean indicating when this view modifier is presented.
    @Binding var isPresented: Bool
    
    /// The closure preformed when this view modifier is dismissed.
    var onDismiss: (() -> Void)? = nil
    
    /// Creates a representation for a SafariView.
    var represntationBuilder: () -> SafariView
    
    /// Returns true if this view should be presented.
    private var item: Binding<Bool?> {
        .init(get: { self.isPresented ? true: nil }, set: { self.isPresented = ($0 != nil) })
    }
    
    /// Allows a boolean to be used in place of an item when building a representation for an SafariView
    private func itemRepresntationBuilder(_ bool: Bool) -> SafariView {
        represntationBuilder()
    }
    
    /// Presents a SafariView in the same new views are pushed onto the NavigationStack.
    func body(content: Content) -> some View {
        content.background{ SafariViewPresenter(item: item, onDismiss: onDismiss, representationBuilder: itemRepresntationBuilder) }
    }
}

/// A view modifier that allows a SafariView to be presented in a similar manner to a sheet.
struct SafariItemViewPresentationModifier<Item: Identifiable>: ViewModifier {
    /// The item being presented.
    @Binding var item: Item?
    
    /// The closure preformed when this view modifier is dismissed.
    var onDismiss: (() -> Void)? = nil
    
    /// Creates a representation for a SafariView with the given item.
    var represntationBuilder: (Item) -> SafariView
    
    /// Presents a SafariView in the same new views are pushed onto the NavigationStack.
    func body(content: Content) -> some View {
        content.background{ SafariViewPresenter(item: $item, onDismiss: onDismiss, representationBuilder: represntationBuilder) }
    }
}

extension View {
    /// A view that displays content from a webpage using an in-app Safari browser.
    ///
    /// - Parameters:
    ///   - isPresented: a boolean that indicated when to show this view.
    ///   - onDismiss: a closure preformed when this view is closed.
    ///   - representationBuilder: an escaping closure that creates a presentable SafariView.
    ///
    ///  - Returns: a SafariView.
    func safariView(isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil, content representationBuilder: @escaping () -> SafariView) -> some View {
        modifier(SafariViewPresentationModifier(isPresented: isPresented, onDismiss: onDismiss, represntationBuilder: representationBuilder))
    }
    
    /// A view that displays content from a webpage using an in-app Safari browser.
    ///
    /// - Parameters:
    ///   - item: the item being presented.
    ///   - onDismiss: a closure preformed when this view is closed.
    ///   - representationBuilder: an escaping closure that creates a presentable SafariView with the given item.
    ///
    ///  - Returns: a SafariView.
    func safariView<Item: Identifiable>(item: Binding<Item?>, onDismiss: (() -> Void)? = nil, content representationBuilder: @escaping (Item) -> SafariView) -> some View {
        modifier(SafariItemViewPresentationModifier(item: item, onDismiss: onDismiss, represntationBuilder: representationBuilder))
    }
}


