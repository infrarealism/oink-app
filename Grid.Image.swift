import AppKit

extension Grid {
    final class Image: NSView {
        var image: CGImage? {
            didSet {
                guard let image = self.image else {
                    self.layer = nil
                    wantsLayer = false
                    return
                }
                let layer = CALayer()
                layer.contentsGravity = .resizeAspectFill
                layer.contents = image
                
                let transition = CABasicAnimation(keyPath: "opacity")
                transition.duration = 1
                transition.timingFunction = .init(name: .easeOut)
                transition.fromValue = 0
                layer.add(transition, forKey: "opacity")
                self.layer = layer
                wantsLayer = true
            }
        }
        
        required init?(coder: NSCoder) { nil }
        init() {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
        }
    }
}
