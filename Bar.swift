import AppKit
import Combine

final class Bar: NSVisualEffectView {
    private weak var main: Main!
    private weak var items: Label!
    private weak var image: Label!
    private weak var specs: Label!
    private weak var date: Label!
    private weak var grid: Item!
    private weak var separator: Separator!
    private var subs = Set<AnyCancellable>()
    private let transition = CATransition()
    
    required init?(coder: NSCoder) { nil }
    init(main: Main) {
        self.main = main
        super.init(frame: .zero)
        wantsLayer = true
        translatesAutoresizingMaskIntoConstraints = false
        material = .hudWindow
        
        transition.timingFunction = .init(name: .easeInEaseOut)
        transition.type = .moveIn
        transition.subtype = .fromTop
        transition.duration = 1
        
        let folder = Label(.systemFont(ofSize: 18, weight: .medium))
        folder.stringValue = main.url.lastPathComponent
        folder.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(folder)
        
        let items = Label(.systemFont(ofSize: 14, weight: .light))
        items.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(items)
        self.items = items
        
        let separator = Separator()
        separator.alphaValue = 0
        addSubview(separator)
        self.separator = separator
        
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
        
        let grid = Item(icon: "grid", title: "View all")
        grid.target = self
        grid.action = #selector(viewAll)
        grid.alphaValue = 0
        addSubview(grid)
        self.grid = grid
        
        let close = Item(icon: "close", title: "Close")
        close.target = self
        close.action = #selector(self.close)
        addSubview(close)
        
        widthAnchor.constraint(equalToConstant: 220).isActive = true
        
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
        
        grid.topAnchor.constraint(equalTo: specs.bottomAnchor, constant: 30).isActive = true
        grid.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
        grid.rightAnchor.constraint(equalTo: rightAnchor, constant: -30).isActive = true
        
        close.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30).isActive = true
        close.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
        close.rightAnchor.constraint(equalTo: rightAnchor, constant: -30).isActive = true
        
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
        
        self.items.layer!.add(transition, forKey: "transition")
        
        self.items.stringValue = count.string(from: .init(value: items.count))! + " images\n" + bytes.string(from: .init(value: .init(items.reduce(0) { $0 + $1.bytes }), unit: .bytes))
    }
    
    private func update(_ item: Photo) {
        let format = DateFormatter()
        format.dateStyle = .full
        format.timeStyle = .short
        
        let bytes = ByteCountFormatter()
        
        image.stringValue = item.url.lastPathComponent
        specs.stringValue = "\(Int(item.size.width))×\(Int(item.size.height))\n" + bytes.string(from: .init(value: .init(item.bytes), unit: .bytes)) + (item.iso == nil ? "" : "\nISO \(item.iso!)")
        date.stringValue = format.string(from: item.date)
        
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.5
            $0.allowsImplicitAnimation = true
            separator.alphaValue = 1
            grid.alphaValue = 1
            image.alphaValue = 1
            specs.alphaValue = 1
            date.alphaValue = 1
        }
    }
    
    @objc private func viewAll() {
        main.clear()
        
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.3
            $0.allowsImplicitAnimation = true
            separator.alphaValue = 0
            grid.alphaValue = 0
            image.alphaValue = 0
            specs.alphaValue = 0
            date.alphaValue = 0
        }
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
        
        let label = Label(.systemFont(ofSize: 14, weight: .medium))
        label.stringValue = title
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(label)
        self.label = label
        
        bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 10).isActive = true
        
        icon.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        icon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        label.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 10).isActive = true
        label.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -15).isActive = true
        hoverOff()
    }
    
    override func hoverOff() {
        label.textColor = .labelColor
        icon.contentTintColor = .labelColor
        layer!.backgroundColor = .clear
    }
    
    override func hoverOn() {
        label.textColor = .controlBackgroundColor
        icon.contentTintColor = .controlBackgroundColor
        layer!.backgroundColor = NSColor.labelColor.cgColor
    }
}
