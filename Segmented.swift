import AppKit
import Combine

final class Segmented: NSView {
    let selected = CurrentValueSubject<Int, Never>(0)
    private var subs = Set<AnyCancellable>()
    
    private weak var indicator: NSView!
    private weak var indicatorCenter: NSLayoutConstraint? {
        didSet {
            oldValue?.isActive = false
            indicatorCenter!.isActive = true
        }
    }
    
    required init?(coder: NSCoder) { nil }
    init(items: [String]) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        layer!.backgroundColor = NSColor.controlBackgroundColor.cgColor
        layer!.cornerRadius = 6
        
        let indicator = NSView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.wantsLayer = true
        indicator.layer!.backgroundColor = NSColor.systemPink.cgColor
        indicator.layer!.cornerRadius = layer!.cornerRadius
        addSubview(indicator)
        self.indicator = indicator
        
        var left = leftAnchor
        items.map(Item.init).forEach {
            $0.target = self
            $0.action = #selector(select(item:))
            addSubview($0)
            
            $0.leftAnchor.constraint(equalTo: left).isActive = true
            $0.topAnchor.constraint(equalTo: topAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            $0.widthAnchor.constraint(equalTo: indicator.widthAnchor).isActive = true
            left = $0.rightAnchor
        }
        
        heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        indicator.topAnchor.constraint(equalTo: topAnchor).isActive = true
        indicator.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        indicator.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1 / CGFloat(items.count)).isActive = true
        
        layoutSubtreeIfNeeded()
        
        selected.sink { [weak self] _ in
            self?.update()
        }.store(in: &subs)
    }
    
    private func update() {
        indicatorCenter = indicator.centerXAnchor.constraint(equalTo: subviews.filter { $0 is Item }[selected.value].centerXAnchor)
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.5
            $0.allowsImplicitAnimation = true
            layoutSubtreeIfNeeded()
        }
    }
    
    @objc private func select(item: Item) {
        let index = subviews.compactMap { $0 as? Item }.firstIndex(of: item)!
        guard index != selected.value else { return }
        selected.value = index
    }
}

private final class Item: Control {
    required init?(coder: NSCoder) { nil }
    init(title: String) {
        super.init()
        
        let label = Label(.systemFont(ofSize: 12, weight: .bold))
        label.stringValue = title
        addSubview(label)
        
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}
