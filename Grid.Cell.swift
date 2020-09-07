import AppKit

extension Grid {
    final class Cell: NSView {
        var item: Photo? {
            didSet {
                image.image = item?.image().map { NSImage(cgImage: $0, size: .init(width: 200, height: 200)) }
            }
        }
        
        var index = 0
        private weak var image: NSImageView!
        
        required init?(coder: NSCoder) { nil }
        init(_ size: CGSize) {
            super.init(frame: .init(origin: .zero, size: size))
            wantsLayer = true
            layer!.backgroundColor = NSColor.systemIndigo.withAlphaComponent(0.5).cgColor
            
            let image = NSImageView()
            image.translatesAutoresizingMaskIntoConstraints = false
            image.imageScaling = .scaleProportionallyUpOrDown
            addSubview(image)
            self.image = image
            
            image.topAnchor.constraint(equalTo: topAnchor).isActive = true
            image.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            image.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            image.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        }
    }
}
