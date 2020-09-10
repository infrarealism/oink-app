import AppKit

final class Bar: NSVisualEffectView {
    private weak var main: Main!
    
    required init?(coder: NSCoder) { nil }
    init(main: Main, items: [Photo]) {
        self.main = main
        super.init(frame: .zero)
        wantsLayer = true
        translatesAutoresizingMaskIntoConstraints = false
        material = .hudWindow
        
        let separator = Separator()
        addSubview(separator)
        
        let count = NumberFormatter()
        count.numberStyle = .decimal
        let bytes = ByteCountFormatter()
        
        let title = Label(main.url?.lastPathComponent ?? "", .systemFont(ofSize: 18, weight: .medium))
        title.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(title)
        
        let info = Label(count.string(from: .init(value: items.count))! + " images\n" + bytes.string(from: .init(value: .init(items.reduce(0) { $0 + $1.bytes }), unit: .bytes)), .systemFont(ofSize: 14, weight: .regular))
        info.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(info)
        
        let close = Item(icon: "close", title: "Close")
        close.target = self
        close.action = #selector(self.close)
        addSubview(close)
        
        widthAnchor.constraint(equalToConstant: 180).isActive = true
        
        title.bottomAnchor.constraint(equalTo: info.topAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        title.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
        
        info.bottomAnchor.constraint(equalTo: close.topAnchor, constant: -20).isActive = true
        info.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        info.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
        
        separator.topAnchor.constraint(equalTo: topAnchor).isActive = true
        separator.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        separator.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        separator.widthAnchor.constraint(equalToConstant: 1).isActive = true
        
        close.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30).isActive = true
        close.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        close.rightAnchor.constraint(equalTo: rightAnchor, constant: -25).isActive = true
    }
    
    @objc private func close() {
        main.session.close()
    }
}

private final class Item: Control {
    override var enabled: Bool {
        didSet {
            if enabled {
                hoverOff()
            } else {
                hoverOn()
            }
        }
    }
    
    private weak var icon: NSImageView!
    private weak var label: Label!
    private weak var blur: NSVisualEffectView!
    
    required init?(coder: NSCoder) { nil }
    init(icon: String, title: String) {
        super.init()
        wantsLayer = true
        layer!.cornerRadius = 6
        
        let icon = NSImageView(image: NSImage(named: icon)!)
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.imageScaling = .scaleNone
        addSubview(icon)
        self.icon = icon
        
        let label = Label(title, .systemFont(ofSize: 12, weight: .medium))
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(label)
        self.label = label
        
        bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 8).isActive = true
        
        icon.leftAnchor.constraint(equalTo: leftAnchor, constant: 11).isActive = true
        icon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        label.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 5).isActive = true
        label.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -11).isActive = true
        hoverOff()
    }
    
    override func hoverOn() {
        label.textColor = .labelColor
        icon.contentTintColor = .secondaryLabelColor
        layer!.backgroundColor = .clear
    }
    
    override func hoverOff() {
        label.textColor = .controlBackgroundColor
        icon.contentTintColor = .controlBackgroundColor
        layer!.backgroundColor = NSColor.labelColor.cgColor
    }
}
