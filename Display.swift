import AppKit

final class Display: NSView {
    private weak var item: Photo!
    private weak var top: NSLayoutConstraint!
    
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
        
        let bar = NSView()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.wantsLayer = true
        bar.layer!.backgroundColor = .init(gray: 0, alpha: 0.7)
        addSubview(bar)
        
        top = bar.topAnchor.constraint(equalTo: topAnchor, constant: -100)
        top.isActive = true
        bar.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        bar.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        bar.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    func open() {
        let transition = CABasicAnimation(keyPath: "contents")
        transition.duration = 0.3
        transition.timingFunction = .init(name: .easeOut)
        layer!.contents = item.image
        layer!.add(transition, forKey: "contents")
        
        top.constant = 0
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.3
            $0.allowsImplicitAnimation = true
            layoutSubtreeIfNeeded()
        }
    }
}
