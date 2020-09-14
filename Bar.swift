import AppKit
import Combine

final class Bar: NSVisualEffectView {
    private weak var main: Main!
    private weak var items: Label!
    private weak var image: Label!
    private weak var specs: Label!
    private weak var date: Label!
    private var subs = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) { nil }
    init(main: Main) {
        self.main = main
        super.init(frame: .zero)
        wantsLayer = true
        translatesAutoresizingMaskIntoConstraints = false
        material = .hudWindow
        
        let folder = Label(.systemFont(ofSize: 18, weight: .medium))
        folder.stringValue = main.url.lastPathComponent
        folder.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(folder)
        
        let items = Label(.systemFont(ofSize: 14, weight: .light))
        items.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(items)
        self.items = items
        
        let separator = Separator()
        addSubview(separator)
        
        let image = Label(.systemFont(ofSize: 18, weight: .medium))
        image.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(image)
        self.image = image
        
        let specs = Label(.systemFont(ofSize: 14, weight: .light))
        specs.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(specs)
        self.specs = specs
        
        let date = Label(.systemFont(ofSize: 14, weight: .light))
        date.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(date)
        self.date = date
        
        let close = Item(icon: "close", title: "Close")
        close.target = self
        close.action = #selector(self.close)
        addSubview(close)
        
        widthAnchor.constraint(equalToConstant: 250).isActive = true
        
        folder.topAnchor.constraint(equalTo: topAnchor, constant: 40).isActive = true
        folder.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        folder.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
        
        items.topAnchor.constraint(equalTo: folder.bottomAnchor).isActive = true
        items.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        items.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
        
        separator.topAnchor.constraint(equalTo: items.bottomAnchor, constant: 20).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separator.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        separator.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        
        image.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 20).isActive = true
        image.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        image.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
        
        specs.topAnchor.constraint(equalTo: date.bottomAnchor, constant: 15).isActive = true
        specs.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        specs.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
        
        date.topAnchor.constraint(equalTo: image.bottomAnchor).isActive = true
        date.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        date.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
        
        close.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30).isActive = true
        close.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        close.rightAnchor.constraint(equalTo: rightAnchor, constant: -25).isActive = true
        
        main.items.dropFirst().receive(on: DispatchQueue.main).sink { [weak self] in
            self?.update($0)
        }.store(in: &subs)
        
        main.cell.dropFirst().sink { [weak self] in
            $0?.item.map {
                self?.update($0)
            }
        }.store(in: &subs)
    }
    
    private func update(_ items: [Photo]) {
        let count = NumberFormatter()
        count.numberStyle = .decimal
        let bytes = ByteCountFormatter()
        
        let transition = CATransition()
        transition.timingFunction = .init(name: .easeInEaseOut)
        transition.type = .fade
        transition.duration = 1
        self.items.layer!.add(transition, forKey: "transition")
        
        self.items.stringValue = count.string(from: .init(value: items.count))! + " images\n" + bytes.string(from: .init(value: .init(items.reduce(0) { $0 + $1.bytes }), unit: .bytes))
    }
    
    private func update(_ item: Photo) {
        let format = DateFormatter()
        format.dateStyle = .full
        format.timeStyle = .short
        
        let bytes = ByteCountFormatter()
        
        let transition = CATransition()
        transition.timingFunction = .init(name: .easeInEaseOut)
        transition.type = .fade
        transition.duration = 1
        image.layer!.add(transition, forKey: "transition")
        specs.layer!.add(transition, forKey: "transition")
        date.layer!.add(transition, forKey: "transition")
        
        image.stringValue = item.url.lastPathComponent
        specs.stringValue = "\(Int(item.size.width))×\(Int(item.size.height))\n" + bytes.string(from: .init(value: .init(item.bytes), unit: .bytes)) + (item.iso == nil ? "" : "\nISO \(item.iso!)")
        date.stringValue = format.string(from: item.date)
    }
    
    @objc private func close() {
        (NSApp.windows.first as! Window).clear()
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
        
        let label = Label(.systemFont(ofSize: 12, weight: .medium))
        label.stringValue = title
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
