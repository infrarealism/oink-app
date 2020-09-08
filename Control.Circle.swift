import AppKit

extension Control {
    final class Circle: Control {
        override var enabled: Bool {
            didSet {
                if enabled {
                    hoverOff()
                } else {
                    hoverOn()
                }
            }
        }
        
        required init?(coder: NSCoder) { nil }
        init(icon: String, background: NSColor, foreground: NSColor) {
            super.init()
            wantsLayer = true
            layer!.backgroundColor = background.cgColor
            layer!.cornerRadius = 18
            
            let icon = NSImageView(image: NSImage(named: icon)!)
            icon.translatesAutoresizingMaskIntoConstraints = false
            icon.imageScaling = .scaleNone
            icon.contentTintColor = foreground
            addSubview(icon)
            
            widthAnchor.constraint(equalToConstant: 36).isActive = true
            heightAnchor.constraint(equalTo: widthAnchor).isActive = true
            
            icon.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            icon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        }
        
        override func hoverOn() {
            alphaValue = 0.3
        }
        
        override func hoverOff() {
            alphaValue = 1
        }
    }
}
