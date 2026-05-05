import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 11.0, macOS 10.13, tvOS 11.0, *)
extension ColorResource {

}

// MARK: - Image Symbols -

@available(iOS 11.0, macOS 10.7, tvOS 11.0, *)
extension ImageResource {

    /// The "Bullet00" asset catalog image resource.
    static let bullet00 = ImageResource(name: "Bullet00", bundle: resourceBundle)

    /// The "Bullet01" asset catalog image resource.
    static let bullet01 = ImageResource(name: "Bullet01", bundle: resourceBundle)

    /// The "Bullet02" asset catalog image resource.
    static let bullet02 = ImageResource(name: "Bullet02", bundle: resourceBundle)

    /// The "DialogArrow" asset catalog image resource.
    static let dialogArrow = ImageResource(name: "DialogArrow", bundle: resourceBundle)

    /// The "DialogSpeaker" asset catalog image resource.
    static let dialogSpeaker = ImageResource(name: "DialogSpeaker", bundle: resourceBundle)

    /// The "DialogTextBox00" asset catalog image resource.
    static let dialogTextBox00 = ImageResource(name: "DialogTextBox00", bundle: resourceBundle)

    /// The "add_to_path" asset catalog image resource.
    static let addToPath = ImageResource(name: "add_to_path", bundle: resourceBundle)

    /// The "background" asset catalog image resource.
    static let background = ImageResource(name: "background", bundle: resourceBundle)

    /// The "bokeh" asset catalog image resource.
    static let bokeh = ImageResource(name: "bokeh", bundle: resourceBundle)

    /// The "circle_blue" asset catalog image resource.
    static let circleBlue = ImageResource(name: "circle_blue", bundle: resourceBundle)

    /// The "dialog3fill" asset catalog image resource.
    static let dialog3Fill = ImageResource(name: "dialog3fill", bundle: resourceBundle)

    /// The "dialog3left" asset catalog image resource.
    static let dialog3Left = ImageResource(name: "dialog3left", bundle: resourceBundle)

    /// The "dialog3right" asset catalog image resource.
    static let dialog3Right = ImageResource(name: "dialog3right", bundle: resourceBundle)

    /// The "edit" asset catalog image resource.
    static let edit = ImageResource(name: "edit", bundle: resourceBundle)

    /// The "enemy" asset catalog image resource.
    static let enemy = ImageResource(name: "enemy", bundle: resourceBundle)

    /// The "exit" asset catalog image resource.
    static let exit = ImageResource(name: "exit", bundle: resourceBundle)

    /// The "file_tool" asset catalog image resource.
    static let fileTool = ImageResource(name: "file_tool", bundle: resourceBundle)

    /// The "left_arrow" asset catalog image resource.
    static let leftArrow = ImageResource(name: "left_arrow", bundle: resourceBundle)

    /// The "length" asset catalog image resource.
    static let length = ImageResource(name: "length", bundle: resourceBundle)

    /// The "logo1" asset catalog image resource.
    static let logo1 = ImageResource(name: "logo1", bundle: resourceBundle)

    /// The "menu" asset catalog image resource.
    static let menu = ImageResource(name: "menu", bundle: resourceBundle)

    /// The "move" asset catalog image resource.
    static let move = ImageResource(name: "move", bundle: resourceBundle)

    /// The "new" asset catalog image resource.
    static let new = ImageResource(name: "new", bundle: resourceBundle)

    /// The "no" asset catalog image resource.
    static let no = ImageResource(name: "no", bundle: resourceBundle)

    /// The "node_add" asset catalog image resource.
    static let nodeAdd = ImageResource(name: "node_add", bundle: resourceBundle)

    /// The "open" asset catalog image resource.
    static let open = ImageResource(name: "open", bundle: resourceBundle)

    /// The "path_add" asset catalog image resource.
    static let pathAdd = ImageResource(name: "path_add", bundle: resourceBundle)

    /// The "path_select" asset catalog image resource.
    static let pathSelect = ImageResource(name: "path_select", bundle: resourceBundle)

    /// The "path_tool" asset catalog image resource.
    static let pathTool = ImageResource(name: "path_tool", bundle: resourceBundle)

    /// The "play" asset catalog image resource.
    static let play = ImageResource(name: "play", bundle: resourceBundle)

    /// The "point" asset catalog image resource.
    static let point = ImageResource(name: "point", bundle: resourceBundle)

    /// The "run" asset catalog image resource.
    static let run = ImageResource(name: "run", bundle: resourceBundle)

    /// The "save" asset catalog image resource.
    static let save = ImageResource(name: "save", bundle: resourceBundle)

    /// The "spark" asset catalog image resource.
    static let spark = ImageResource(name: "spark", bundle: resourceBundle)

    /// The "stop" asset catalog image resource.
    static let stop = ImageResource(name: "stop", bundle: resourceBundle)

    /// The "transition" asset catalog image resource.
    static let transition = ImageResource(name: "transition", bundle: resourceBundle)

    /// The "transition_arrow" asset catalog image resource.
    static let transitionArrow = ImageResource(name: "transition_arrow", bundle: resourceBundle)

    /// The "ufo" asset catalog image resource.
    static let ufo = ImageResource(name: "ufo", bundle: resourceBundle)

    /// The "ui_fire_button_down" asset catalog image resource.
    static let uiFireButtonDown = ImageResource(name: "ui_fire_button_down", bundle: resourceBundle)

    /// The "ui_fire_button_up" asset catalog image resource.
    static let uiFireButtonUp = ImageResource(name: "ui_fire_button_up", bundle: resourceBundle)

    /// The "weapon_use_button" asset catalog image resource.
    static let weaponUseButton = ImageResource(name: "weapon_use_button", bundle: resourceBundle)

    /// The "weapon_use_button_pressed" asset catalog image resource.
    static let weaponUseButtonPressed = ImageResource(name: "weapon_use_button_pressed", bundle: resourceBundle)

}

// MARK: - Backwards Deployment Support -

/// A color resource.
struct ColorResource: Swift.Hashable, Swift.Sendable {

    /// An asset catalog color resource name.
    fileprivate let name: Swift.String

    /// An asset catalog color resource bundle.
    fileprivate let bundle: Foundation.Bundle

    /// Initialize a `ColorResource` with `name` and `bundle`.
    init(name: Swift.String, bundle: Foundation.Bundle) {
        self.name = name
        self.bundle = bundle
    }

}

/// An image resource.
struct ImageResource: Swift.Hashable, Swift.Sendable {

    /// An asset catalog image resource name.
    fileprivate let name: Swift.String

    /// An asset catalog image resource bundle.
    fileprivate let bundle: Foundation.Bundle

    /// Initialize an `ImageResource` with `name` and `bundle`.
    init(name: Swift.String, bundle: Foundation.Bundle) {
        self.name = name
        self.bundle = bundle
    }

}

#if canImport(AppKit)
@available(macOS 10.13, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    /// Initialize a `NSColor` with a color resource.
    convenience init(resource: ColorResource) {
        self.init(named: NSColor.Name(resource.name), bundle: resource.bundle)!
    }

}

protocol _ACResourceInitProtocol {}
extension AppKit.NSImage: _ACResourceInitProtocol {}

@available(macOS 10.7, *)
@available(macCatalyst, unavailable)
extension _ACResourceInitProtocol {

    /// Initialize a `NSImage` with an image resource.
    init(resource: ImageResource) {
        self = resource.bundle.image(forResource: NSImage.Name(resource.name))! as! Self
    }

}
#endif

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    /// Initialize a `UIColor` with a color resource.
    convenience init(resource: ColorResource) {
#if !os(watchOS)
        self.init(named: resource.name, in: resource.bundle, compatibleWith: nil)!
#else
        self.init()
#endif
    }

}

@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// Initialize a `UIImage` with an image resource.
    convenience init(resource: ImageResource) {
#if !os(watchOS)
        self.init(named: resource.name, in: resource.bundle, compatibleWith: nil)!
#else
        self.init()
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Color {

    /// Initialize a `Color` with a color resource.
    init(_ resource: ColorResource) {
        self.init(resource.name, bundle: resource.bundle)
    }

}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Image {

    /// Initialize an `Image` with an image resource.
    init(_ resource: ImageResource) {
        self.init(resource.name, bundle: resource.bundle)
    }

}
#endif