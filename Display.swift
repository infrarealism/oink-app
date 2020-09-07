import AppKit

final class Display: NSView {
    private weak var item: Photo!
    
    required init?(coder: NSCoder) { nil }
    init(item: Photo) {
        self.item = item
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let layer = CALayer()
        layer.contentsGravity = .resizeAspectFill
        layer.contents = item.thumb
        self.layer = layer
        wantsLayer = true
    }
    
    func hd() {
        let transition = CABasicAnimation(keyPath: "contents")
        transition.duration = 1
        transition.timingFunction = .init(name: .easeOut)
        layer!.contents = item.image
        layer!.add(transition, forKey: "contents")
    }
}
