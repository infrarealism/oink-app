import AppKit
import Combine

extension Grid {
    final class Cell: CALayer {
        weak var item: Photo? {
            didSet {
                sub = item?.thumb.receive(on: DispatchQueue.main).sink { [weak self] in
                    self?.contents = $0
                    if $0 != nil {
                        self?.sub?.cancel()
                    }
                }
            }
        }
        
        var highlighted = false {
            didSet {
                borderWidth = highlighted ? 10 : 0
            }
        }
        
        var index = 0
        private var sub: AnyCancellable?
        
        required init?(coder: NSCoder) { nil }
        override init() {
            super.init()
            contentsGravity = .resizeAspectFill
            masksToBounds = true
            borderColor = NSColor.secondaryLabelColor.cgColor
        }
        
        func update(_ frame: CGRect) {
            ["bounds", "position"].forEach {
                let transition = CABasicAnimation(keyPath: $0)
                transition.duration = 0.3
                transition.timingFunction = .init(name: .easeOut)
                add(transition, forKey: $0)
            }
            self.frame = frame
        }
        
        override class func defaultAction(forKey: String) -> CAAction? {
            switch forKey {
            case "contents": return opacity
            default: return NSNull()
            }
        }
        
        private static var opacity: CABasicAnimation = {
            $0.duration = 0.6
            $0.timingFunction = .init(name: .easeOut)
            $0.fromValue = 0
            return $0
        } (CABasicAnimation(keyPath: "opacity"))
    }
}
