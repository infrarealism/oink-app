import AppKit

final class Label: NSTextField {
    override var acceptsFirstResponder: Bool { false }
    override var canBecomeKeyView: Bool { false }
    override func acceptsFirstMouse(for: NSEvent?) -> Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init(_ string: String, _ font: NSFont) {
        super.init(frame: .zero)
        stringValue = string
        setAccessibilityLabel(string)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        isBezeled = false
        isEditable = false
        isSelectable = false
        setAccessibilityRole(.staticText)
        self.font = font
    }
}
