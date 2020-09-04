import AppKit

extension Control {
    final class Blob: Control {
        override var enabled: Bool {
            didSet {
                update()
            }
        }
        
        private weak var drop: NSImageView!
        private weak var circle: NSImageView!
        private weak var icon: NSImageView!
        
        required init?(coder: NSCoder) { nil }
        init(icon: String) {
            super.init()
            
            let drop = NSImageView(image: NSImage(named: "shadow")!)
            drop.translatesAutoresizingMaskIntoConstraints = false
            drop.imageScaling = .scaleNone
            addSubview(drop)
            self.drop = drop
            
            let circle = NSImageView(image: NSImage(named: "circle")!)
            circle.translatesAutoresizingMaskIntoConstraints = false
            circle.imageScaling = .scaleNone
            addSubview(circle)
            self.circle = circle

            
            let icon = NSImageView(image: NSImage(named: icon)!)
            icon.translatesAutoresizingMaskIntoConstraints = false
            icon.imageScaling = .scaleNone
            addSubview(icon)
            self.icon = icon
            
            widthAnchor.constraint(equalToConstant: 70).isActive = true
            heightAnchor.constraint(equalToConstant: 70).isActive = true
            
            drop.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            drop.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            circle.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            circle.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            icon.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            icon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            update()
        }
        
        func update() {
            drop.isHidden = !enabled
            circle.contentTintColor = enabled ? .windowBackgroundColor : .underPageBackgroundColor
            icon.contentTintColor = enabled ? .systemIndigo : .tertiaryLabelColor
        }
        
        override func hoverOn() {
            alphaValue = 0.3
        }
        
        override func hoverOff() {
            alphaValue = 1
        }
    }
}
