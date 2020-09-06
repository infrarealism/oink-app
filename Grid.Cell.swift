import AppKit

extension Grid {
    final class Cell: NSView {
        var index = 0 { didSet { label.stringValue = "\(index)" } }
        private weak var label: Label!
        
        required init?(coder: NSCoder) { nil }
        init(_ size: CGSize) {
            super.init(frame: .init(origin: .zero, size: size))
            wantsLayer = true
            layer!.backgroundColor = NSColor.systemIndigo.withAlphaComponent(0.5).cgColor
            
            let label = Label("", .systemFont(ofSize: 20, weight: .bold))
            addSubview(label)
            self.label = label
            
            label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        }
    }
}
