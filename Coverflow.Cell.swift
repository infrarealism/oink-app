import AppKit
import Combine

extension Coverflow {
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
        
        override class func defaultAction(forKey: String) -> CAAction? {
            NSNull()
        }
    }
}
