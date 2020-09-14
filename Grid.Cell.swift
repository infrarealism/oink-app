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
        
        var index = 0
        private var sub: AnyCancellable?
        
        required init?(coder: NSCoder) { nil }
        override init() {
            super.init()
            contentsGravity = .resizeAspectFill
            masksToBounds = true
        }
        
        func update(_ frame: CGRect) {
            ["bounds", "position"].forEach {
                let transition = CABasicAnimation(keyPath: $0)
                transition.duration = 0.35
                transition.timingFunction = .init(name: .easeOut)
                add(transition, forKey: $0)
            }
            self.frame = frame
        }
        
        override class func defaultAction(forKey: String) -> CAAction? {
            switch forKey {
            case "contents":
                let transition = CABasicAnimation(keyPath: "opacity")
                transition.duration = 1
                transition.timingFunction = .init(name: .easeOut)
                transition.fromValue = 0
                return transition
            default: return NSNull()
            }
        }
    }
}
