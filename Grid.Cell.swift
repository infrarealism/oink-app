import AppKit

extension Grid {
    final class Cell: NSView {
        var item: Photo? {
            didSet {
                image.image = item?.image()
            }
        }
        
        var index = 0
        private weak var image: Image!
        
        required init?(coder: NSCoder) { nil }
        init(_ size: CGSize) {
            super.init(frame: .init(origin: .zero, size: size))
            
            let image = Image()
            addSubview(image)
            self.image = image
            
            image.topAnchor.constraint(equalTo: topAnchor).isActive = true
            image.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            image.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            image.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        }
    }
}
