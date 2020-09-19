import AppKit
import Combine

extension Coverflow {
    final class Cell: CALayer {
        weak var item: Photo? {
            didSet {
                contents = item?.thumb.value
                sub = item?.image.receive(on: DispatchQueue.main).sink { [weak self] in
                    if $0 != nil {
                        self?.contents = $0
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
