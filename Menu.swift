import AppKit

final class Menu: NSMenu {
    required init(coder: NSCoder) { super.init(coder: coder) }
    init() {
        super.init(title: "")
        items = [app, edit, window, help]
    }

    private var app: NSMenuItem {
        menu(.key("App"), items: [
        .init(title: .key("About"), action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: ""),
        .separator(),
        .init(title: .key("Hide"), action: #selector(NSApplication.hide), keyEquivalent: "h"),
        {
            $0.keyEquivalentModifierMask = [.option, .command]
            return $0
        } (NSMenuItem(title: .key("Hide.others"), action: #selector(NSApplication.hideOtherApplications), keyEquivalent: "h")),
        .init(title: .key("Show.all"), action: #selector(NSApplication.unhideAllApplications), keyEquivalent: ""),
        .separator(),
        .init(title: .key("Quit"), action: #selector(NSApplication.terminate), keyEquivalent: "q")])
    }
    
    private var edit: NSMenuItem {
        menu(.key("Edit"), items: [
        { $0.keyEquivalentModifierMask = [.option, .command]
            $0.keyEquivalentModifierMask = [.command]
            return $0
        } (NSMenuItem(title: .key("Undo"), action: Selector(("undo:")), keyEquivalent: "z")),
        { $0.keyEquivalentModifierMask = [.command, .shift]
            return $0
        } (NSMenuItem(title: .key("Redo"), action: Selector(("redo:")), keyEquivalent: "z")),
        .separator(),
        { $0.keyEquivalentModifierMask = [.command]
            return $0
        } (NSMenuItem(title: .key("Cut"), action: #selector(NSText.cut), keyEquivalent: "x")),
        { $0.keyEquivalentModifierMask = [.command]
            return $0
        } (NSMenuItem(title: .key("Copy"), action: #selector(NSText.copy(_:)), keyEquivalent: "c")),
        { $0.keyEquivalentModifierMask = [.command]
            return $0
        } (NSMenuItem(title: .key("Paste"), action: #selector(NSText.paste), keyEquivalent: "v")),
        .init(title: .key("Delete"), action: #selector(NSText.delete), keyEquivalent: ""),
        { $0.keyEquivalentModifierMask = [.command]
            return $0
        } (NSMenuItem(title: .key("Select.all"), action: #selector(NSText.selectAll), keyEquivalent: "a"))])
    }
    
    private var window: NSMenuItem {
        menu(.key("Window"), items: [
        .init(title: .key("Minimize"), action: #selector(NSWindow.miniaturize), keyEquivalent: "m"),
        .init(title: .key("Zoom"), action: #selector(NSWindow.zoom), keyEquivalent: "p"),
        .separator(),
        .init(title: .key("Bring.all"), action: #selector(NSApplication.arrangeInFront), keyEquivalent: ""),
        .separator(),
        .init(title: .key("Close"), action: #selector(NSWindow.close), keyEquivalent: "w")])
    }
    
    private var help: NSMenuItem {
        menu(.key("Help"), items: [])
    }
    
    private func menu(_ name: String, items: [NSMenuItem]) -> NSMenuItem {
        let menu = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        menu.submenu = .init(title: name)
        menu.submenu?.items = items
        return menu
    }
}
