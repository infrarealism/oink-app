import AppKit

extension Grid {
    final class Cell: NSView {
        weak var item: Photo? {
            didSet {
                guard let image = item?.thumb else {
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
        
        var highlighted = false {
            didSet {
                layer!.borderWidth = highlighted ? 3 : 0
                layer!.borderColor = NSColor.systemIndigo.cgColor
                
                let transition = CABasicAnimation(keyPath: "border")
                transition.duration = 1
                transition.timingFunction = .init(name: .easeOut)
                layer!.add(transition, forKey: "border")
            }
        }
        
        var index = 0
        
        required init?(coder: NSCoder) { nil }
        init(_ size: CGSize) {
            super.init(frame: .init(origin: .zero, size: size))
        }
    }
}
