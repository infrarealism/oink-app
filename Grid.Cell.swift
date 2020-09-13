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
                borderWidth = highlighted ? 3 : 0
                borderColor = NSColor.systemIndigo.cgColor

                let transition = CABasicAnimation(keyPath: "borderWidth")
                transition.duration = 0.3
                transition.timingFunction = .init(name: .easeOut)
                add(transition, forKey: "borderWidth")
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
