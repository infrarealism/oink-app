import AppKit
import Combine

final class Menu: NSMenu {
    weak var main: Main? {
        didSet {
            sub = main?.zoom.dropFirst().sink { [weak self] in
                guard let self = self else { return }
                if $0 {
                    self.items = [self.app, self.photo, self.edit, self.window, self.help]
                } else {
                    self.items = self.def
                }
            }
        }
    }
    
    private var sub: AnyCancellable?
    
    required init(coder: NSCoder) { super.init(coder: coder) }
    init() {
        super.init(title: "")
        items = def
    }
    
    private var def: [NSMenuItem] {
        [app, edit, window, help]
    }

    private var app: NSMenuItem {
        menu("Oink", items: [
        .init(title: "About", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: ""),
        .separator(),
        .init(title: "Hide", action: #selector(NSApplication.hide), keyEquivalent: "h"),
        {
            $0.keyEquivalentModifierMask = [.option, .command]
            return $0
        } (NSMenuItem(title: "Hide others", action: #selector(NSApplication.hideOtherApplications), keyEquivalent: "h")),
        .init(title: "Show all", action: #selector(NSApplication.unhideAllApplications), keyEquivalent: ""),
        .separator(),
        .init(title: "Quit", action: #selector(NSApplication.terminate), keyEquivalent: "q")])
    }
    
    private var photo: NSMenuItem {
        menu("Photo", items: [
        {
            $0.keyEquivalentModifierMask = []
            $0.target = main
            return $0
        } (NSMenuItem(title: "Dismiss", action: #selector(main?.back), keyEquivalent: "\r")),
        {
            $0.keyEquivalentModifierMask = []
            $0.target = main
            return $0
        } (NSMenuItem(title: "Select", action: #selector(main?.toggle), keyEquivalent: " ")),
        .separator(),
        {
            $0.keyEquivalentModifierMask = []
            $0.target = main
            return $0
        } (NSMenuItem(title: "Previous", action: #selector(main?.previous), keyEquivalent: .init(Character(UnicodeScalar(NSLeftArrowFunctionKey)!)))),
        {
            $0.keyEquivalentModifierMask = []
            $0.target = main
            return $0
        } (NSMenuItem(title: "Next", action: #selector(main?.next), keyEquivalent: .init(Character(UnicodeScalar(NSRightArrowFunctionKey)!))))])
    }
    
    private var edit: NSMenuItem {
        menu("Edit", items: [
        { $0.keyEquivalentModifierMask = [.option, .command]
            $0.keyEquivalentModifierMask = [.command]
            return $0
        } (NSMenuItem(title: "Undo", action: Selector(("undo:")), keyEquivalent: "z")),
        { $0.keyEquivalentModifierMask = [.command, .shift]
            return $0
        } (NSMenuItem(title: "Redo", action: Selector(("redo:")), keyEquivalent: "z")),
        .separator(),
        { $0.keyEquivalentModifierMask = [.command]
            return $0
        } (NSMenuItem(title: "Cut", action: #selector(NSText.cut), keyEquivalent: "x")),
        { $0.keyEquivalentModifierMask = [.command]
            return $0
        } (NSMenuItem(title: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")),
        { $0.keyEquivalentModifierMask = [.command]
            return $0
        } (NSMenuItem(title: "Paste", action: #selector(NSText.paste), keyEquivalent: "v")),
        .init(title: "Delete", action: #selector(NSText.delete), keyEquivalent: ""),
        { $0.keyEquivalentModifierMask = [.command]
            return $0
        } (NSMenuItem(title: "Select.all", action: #selector(NSText.selectAll), keyEquivalent: "a"))])
    }
    
    private var window: NSMenuItem {
        menu("Window", items: [
        .init(title: "Minimize", action: #selector(NSWindow.miniaturize), keyEquivalent: "m"),
        .init(title: "Zoom", action: #selector(NSWindow.zoom), keyEquivalent: "p"),
        .separator(),
        .init(title: "Bring All to Front", action: #selector(NSApplication.arrangeInFront), keyEquivalent: ""),
        .separator(),
        .init(title: "Close", action: #selector(NSWindow.close), keyEquivalent: "w")])
    }
    
    private var help: NSMenuItem {
        menu("Help", items: [])
    }
    
    private func menu(_ name: String, items: [NSMenuItem]) -> NSMenuItem {
        let menu = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        menu.submenu = .init(title: name)
        menu.submenu?.items = items
        return menu
    }
}
