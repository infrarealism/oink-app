import AppKit

extension Grid {
    final class Cell: CALayer {
        weak var item: Photo? {
            didSet {
                guard let image = item?.thumb else { return }
                contents = image
                
                let transition = CABasicAnimation(keyPath: "opacity")
                transition.duration = 1
                transition.timingFunction = .init(name: .easeOut)
                transition.fromValue = 0
                add(transition, forKey: "opacity")
            }
        }
        
        var highlighted = false {
            didSet {
//                layer!.borderWidth = highlighted ? 3 : 0
//                layer!.borderColor = NSColor.systemIndigo.cgColor
//
//                let transition = CABasicAnimation(keyPath: "borderWidth")
//                transition.duration = 0.3
//                transition.timingFunction = .init(name: .easeOut)
//                layer!.add(transition, forKey: "borderWidth")
            }
        }
        
        var index = 0
        
        override class func defaultAction(forKey event: String) -> CAAction? {
            switch event {
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
