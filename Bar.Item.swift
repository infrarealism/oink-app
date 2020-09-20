import AppKit

extension Bar {
    final class Item: Control {
        override var enabled: Bool {
            didSet {
                if enabled {
                    hoverOff()
                } else {
                    hoverOn()
                }
            }
        }
        
        private weak var icon: NSImageView!
        private weak var label: Label!
        
        required init?(coder: NSCoder) { nil }
        init(icon: String, title: String) {
            super.init()
            wantsLayer = true
            layer!.cornerRadius = 6
            
            let icon = NSImageView(image: NSImage(named: icon)!)
            icon.translatesAutoresizingMaskIntoConstraints = false
            icon.imageScaling = .scaleNone
            addSubview(icon)
            self.icon = icon
            
            let label = Label(.systemFont(ofSize: 14, weight: .medium))
            label.stringValue = title
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            addSubview(label)
            self.label = label
            
            bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 8).isActive = true
            
            icon.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
            icon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            label.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 8).isActive = true
            label.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
            label.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -15).isActive = true
            hoverOff()
        }
        
        override func hoverOff() {
            label.textColor = .labelColor
            icon.contentTintColor = .labelColor
            layer!.backgroundColor = .clear
        }
        
        override func hoverOn() {
            label.textColor = .controlBackgroundColor
            icon.contentTintColor = .controlBackgroundColor
            layer!.backgroundColor = NSColor.labelColor.cgColor
        }
    }
}
