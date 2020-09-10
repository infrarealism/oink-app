import AppKit

extension Grid {
    final class Cell: NSView {
        weak var item: Photo? {
            didSet {
                self.layer!.sublayers?.forEach { $0.removeFromSuperlayer() }
                
                guard let image = item?.thumb else { return }
                let layer = CALayer()
                layer.frame = .init(x: -12, y: -12, width: self.layer!.frame.width + 24, height: self.layer!.frame.height + 24)
                layer.contentsGravity = .resizeAspectFill
                layer.contents = image
                
                let transition = CABasicAnimation(keyPath: "opacity")
                transition.duration = 1
                transition.timingFunction = .init(name: .easeOut)
                transition.fromValue = 0
                layer.add(transition, forKey: "opacity")
                self.layer!.addSublayer(layer)
            }
        }
        
        var highlighted = false {
            didSet {
                layer!.borderWidth = highlighted ? 3 : 0
                layer!.borderColor = NSColor.systemIndigo.cgColor
                
                let transition = CABasicAnimation(keyPath: "borderWidth")
                transition.duration = 0.3
                transition.timingFunction = .init(name: .easeOut)
                layer!.add(transition, forKey: "borderWidth")
            }
        }
        
        var index = 0
        
        required init?(coder: NSCoder) { nil }
        init(_ size: CGSize) {
            super.init(frame: .init(origin: .zero, size: size))
            wantsLayer = true
        }
    }
}
