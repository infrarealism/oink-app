import AppKit

final class Display: NSView {
    weak var top: NSLayoutConstraint! { didSet { top.isActive = true } }
    weak var bottom: NSLayoutConstraint! { didSet { bottom.isActive = true } }
    weak var left: NSLayoutConstraint! { didSet { left.isActive = true } }
    weak var right: NSLayoutConstraint! { didSet { right.isActive = true } }
    private weak var item: Photo!
    private weak var bar: Bar!
    private var padding = CGRect.zero
    
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
        
        let bar = Bar(item)
        bar.close.target = self
        bar.close.action = #selector(close)
        addSubview(bar)
        self.bar = bar
        
        bar.top = bar.topAnchor.constraint(equalTo: topAnchor, constant: -60)
        bar.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        bar.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }
    
    func big() {
        padding = .init(x: left.constant, y: top.constant, width: right.constant, height: bottom.constant)
        top.constant = 0
        bottom.constant = 0
        left.constant = 0
        right.constant = 0
    }
    
    func open() {
        let transition = CABasicAnimation(keyPath: "contents")
        transition.duration = 0.3
        transition.timingFunction = .init(name: .easeOut)
        layer!.contents = item.image
        layer!.add(transition, forKey: "contents")
        
        bar.top.constant = 0
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.3
            $0.allowsImplicitAnimation = true
            layoutSubtreeIfNeeded()
        }
    }
    
    @objc private func close(_ button: Control.Button) {
        button.enabled = false
        bar.top.constant = -60
        top.constant = padding.origin.y
        bottom.constant = padding.size.height
        left.constant = padding.origin.x
        right.constant = padding.size.width
        
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.4
            $0.allowsImplicitAnimation = true
            superview!.layoutSubtreeIfNeeded()
        }) { [weak self] in
            self?.removeFromSuperview()
        }
    }
}
