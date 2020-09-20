import AppKit
import Combine

extension Coverflow {
    final class Cell: CALayer {
        weak var item: Photo? {
            didSet {
                subs = []
                item?.image.receive(on: DispatchQueue.main).sink { [weak self] in
                    self?.contents = $0
                }.store(in: &subs)
                item?.thumb.receive(on: DispatchQueue.main).sink { [weak self] in
                    guard self?.contents == nil else { return }
                    self?.contents = $0
                }.store(in: &subs)
            }
        }
        
        var index = 0
        private var subs = Set<AnyCancellable>()
        
        required init?(coder: NSCoder) { nil }
        override init(layer: Any) { super.init(layer: layer) }
        override init() {
            super.init()
            contentsGravity = .resizeAspectFill
            masksToBounds = true
        }
        
        override class func defaultAction(forKey: String) -> CAAction? {
            NSNull()
        }
    }
}
