import AppKit
import Combine

final class Bar: NSVisualEffectView {
    private weak var main: Main!
    private var subs = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) { nil }
    init(main: Main) {
        self.main = main
        super.init(frame: .zero)
        wantsLayer = true
        translatesAutoresizingMaskIntoConstraints = false
        material = .hudWindow
        
        let transition = CATransition()
        transition.timingFunction = .init(name: .easeInEaseOut)
        transition.type = .push
        transition.subtype = .fromBottom
        transition.duration = 0.3
        
        let bytes = ByteCountFormatter()
        
        let count = NumberFormatter()
        count.numberStyle = .decimal
        
        let format = DateFormatter()
        format.dateStyle = .full
        format.timeStyle = .short
        
        let back = Control.Button(icon: "back", color: .labelColor)
        back.alphaValue = 0
        back.target = self
        back.action = #selector(self.back)
        addSubview(back)
        
        let folder = Label(.systemFont(ofSize: 16, weight: .medium))
        folder.stringValue = main.url.lastPathComponent
        folder.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(folder)
        
        let items = Label(.systemFont(ofSize: 12, weight: .light))
        items.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(items)
        
        let change = Item(icon: "folder", title: "Change")
        change.target = NSApp.windows.first
        change.action = #selector(Window.folder)
        addSubview(change)
        
        let separator = Separator()
        separator.alphaValue = 0
        addSubview(separator)
        
        let image = Label(.systemFont(ofSize: 16, weight: .medium))
        image.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(image)
        
        let specs = Label(.systemFont(ofSize: 12, weight: .light))
        specs.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(specs)
        
        let date = Label(.systemFont(ofSize: 12, weight: .light))
        date.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(date)
        
        widthAnchor.constraint(equalToConstant: 220).isActive = true
        
        back.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        back.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        
        folder.topAnchor.constraint(equalTo: topAnchor, constant: 40).isActive = true
        folder.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        folder.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
        
        items.topAnchor.constraint(equalTo: folder.bottomAnchor).isActive = true
        items.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        items.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
        
        change.topAnchor.constraint(equalTo: items.bottomAnchor, constant: 10).isActive = true
        change.leftAnchor.constraint(equalTo: leftAnchor, constant: 40).isActive = true
        change.rightAnchor.constraint(equalTo: rightAnchor, constant: -40).isActive = true
        
        separator.topAnchor.constraint(equalTo: change.bottomAnchor, constant: 10).isActive = true
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
        
        main.items.dropFirst().receive(on: DispatchQueue.main).sink {
            items.layer!.add(transition, forKey: "transition")
            items.stringValue = count.string(from: .init(value: $0.count))! + " images\n" + bytes.string(from: .init(value: .init($0.reduce(0) { $0 + $1.bytes }), unit: .bytes))
        }.store(in: &subs)
        
        main.index.dropFirst().sink {
            if let index = $0 {
                let item = main.items.value[index]
                image.stringValue = item.url.lastPathComponent
                specs.stringValue = "\(Int(item.size.width))×\(Int(item.size.height))\n" + bytes.string(from: .init(value: .init(item.bytes), unit: .bytes)) + (item.iso == nil ? "" : "\nISO \(item.iso!)")
                date.stringValue = format.string(from: item.date)
            } else {
                image.stringValue = ""
                specs.stringValue = ""
                date.stringValue = ""
            }
            image.layer!.add(transition, forKey: "transition")
            specs.layer!.add(transition, forKey: "transition")
            date.layer!.add(transition, forKey: "transition")
        }.store(in: &subs)
        
        main.zoom.dropFirst().sink { zoom in
            NSAnimationContext.runAnimationGroup {
                $0.duration = 0.3
                $0.allowsImplicitAnimation = true
                separator.alphaValue = zoom ? 1 : 0
                back.alphaValue = zoom ? 1 : 0
            }
        }.store(in: &subs)
    }
    
    @objc private func back() {
        main.index.value = nil
        main.zoom.value = false
    }
}
