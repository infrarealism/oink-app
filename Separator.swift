import AppKit

final class Separator: NSView {
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
    }
    
    override func updateLayer() {
        layer!.backgroundColor = NSColor.separatorColor.cgColor
    }
}
