import AppKit
import Combine

final class Bar: NSVisualEffectView {
    private(set) weak var toggle: NSSwitch!
    private weak var main: Main!
    private var subs = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) { nil }
    init(main: Main) {
        self.main = main
        super.init(frame: .zero)
        wantsLayer = true
        translatesAutoresizingMaskIntoConstraints = false
        material = .sidebar
        
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
        back.isHidden = true
        back.target = main
        back.action = #selector(main.back)
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
        
        let selected = Label(.systemFont(ofSize: 14, weight: .medium))
        selected.alignment = .center
        selected.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(selected)
        
        let delete = Item(icon: "delete", title: "Delete")
        delete.target = main
        delete.action = #selector(main.delete)
        delete.isHidden = true
        addSubview(delete)
        
        let image = Label(.systemFont(ofSize: 16, weight: .medium))
        image.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(image)
        
        let specs = Label(.systemFont(ofSize: 12, weight: .light))
        specs.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(specs)
        
        let date = Label(.systemFont(ofSize: 12, weight: .light))
        date.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(date)
        
        let export = Item(icon: "export", title: "Export")
        export.target = main
        export.action = #selector(main.export)
        export.alphaValue = 0
        export.isHidden = true
        addSubview(export)
        
        let toggleTitle = Label(.systemFont(ofSize: 14, weight: .regular))
        toggleTitle.stringValue = "Selected"
        toggleTitle.isHidden = true
        addSubview(toggleTitle)
        
        let toggle = NSSwitch()
        toggle.target = main
        toggle.action = #selector(main.toggle)
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.isHidden = true
        addSubview(toggle)
        self.toggle = toggle
        
        widthAnchor.constraint(equalToConstant: 220).isActive = true
        
        back.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        back.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        
        folder.topAnchor.constraint(equalTo: topAnchor, constant: 40).isActive = true
        folder.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        folder.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
        
        items.topAnchor.constraint(equalTo: folder.bottomAnchor).isActive = true
        items.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        items.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
        
        change.topAnchor.constraint(equalTo: items.bottomAnchor, constant: 20).isActive = true
        change.leftAnchor.constraint(equalTo: leftAnchor, constant: 40).isActive = true
        change.rightAnchor.constraint(equalTo: rightAnchor, constant: -40).isActive = true
        
        separator.topAnchor.constraint(equalTo: change.bottomAnchor, constant: 10).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separator.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        separator.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        
        selected.bottomAnchor.constraint(equalTo: delete.topAnchor, constant: -10).isActive = true
        selected.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        selected.rightAnchor.constraint(equalTo: rightAnchor, constant: -30).isActive = true
        
        delete.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30).isActive = true
        delete.leftAnchor.constraint(equalTo: leftAnchor, constant: 40).isActive = true
        delete.rightAnchor.constraint(equalTo: rightAnchor, constant: -40).isActive = true
        
        image.topAnchor.constraint(equalTo: export.bottomAnchor, constant: 20).isActive = true
        image.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        image.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
        
        specs.topAnchor.constraint(equalTo: date.bottomAnchor, constant: 15).isActive = true
        specs.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        specs.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
        
        date.topAnchor.constraint(equalTo: image.bottomAnchor).isActive = true
        date.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        date.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
        
        export.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 20).isActive = true
        export.leftAnchor.constraint(equalTo: leftAnchor, constant: 40).isActive = true
        export.rightAnchor.constraint(equalTo: rightAnchor, constant: -40).isActive = true
        
        toggleTitle.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        toggleTitle.centerYAnchor.constraint(equalTo: toggle.centerYAnchor).isActive = true
        
        toggle.leftAnchor.constraint(equalTo: toggleTitle.rightAnchor, constant: 10).isActive = true
        toggle.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
        
        main.items.dropFirst().receive(on: DispatchQueue.main).sink {
            items.layer!.add(transition, forKey: "transition")
            items.stringValue = count.string(from: .init(value: $0.count))! + " images\n" + bytes.string(from: .init(value: .init($0.reduce(0) { $0 + $1.bytes }), unit: .bytes))
        }.store(in: &subs)

        main.index.dropFirst().debounce(for: .seconds(0.3), scheduler: DispatchQueue.main).sink { [weak self] in
            var changed = true
            if let index = $0 {
                self?.main.map {
                    let item = $0.items.value[index]
                    changed = item.url.lastPathComponent != image.stringValue
                    image.stringValue = item.url.lastPathComponent
                    specs.stringValue = "\(Int(item.size.width))×\(Int(item.size.height))\n" + bytes.string(from: .init(value: .init(item.bytes), unit: .bytes)) + (item.iso == nil ? "" : "\nISO \(item.iso!)")
                    date.stringValue = format.string(from: item.date)
                    self?.updateToggle()
                }
            } else {
                image.stringValue = ""
                specs.stringValue = ""
                date.stringValue = ""
            }
            if changed {
                image.layer!.add(transition, forKey: "transition")
                specs.layer!.add(transition, forKey: "transition")
                date.layer!.add(transition, forKey: "transition")
            }
        }.store(in: &subs)

        main.zoom.dropFirst().sink { [weak self] zoom in
            if zoom {
                separator.isHidden = false
                back.isHidden = false
                export.isHidden = false
                toggleTitle.isHidden = false
                toggle.isHidden = false
            } else {
                selected.isHidden = false
                delete.isHidden = self?.main.grid.selection == false
            }
            NSAnimationContext.runAnimationGroup ({
                $0.duration = 0.3
                $0.allowsImplicitAnimation = true
                selected.alphaValue = zoom ? 0 : 1
                delete.alphaValue = zoom ? 0 : 1
                separator.alphaValue = zoom ? 1 : 0
                back.alphaValue = zoom ? 1 : 0
                export.alphaValue = zoom ? 1 : 0
                toggleTitle.alphaValue = zoom ? 1 : 0
                toggle.alphaValue = zoom ? 1 : 0
            }) {
                if zoom {
                    selected.isHidden = true
                    delete.isHidden = true
                } else {
                    separator.isHidden = true
                    back.isHidden = true
                    export.isHidden = true
                    toggleTitle.isHidden = true
                    toggle.isHidden = true
                    delete.isHidden = self?.main.grid.selection == false
                }
            }
        }.store(in: &subs)

        main.grid.selected.dropFirst().debounce(for: .seconds(0.5), scheduler: DispatchQueue.main).sink { [weak self] in
            let count = $0.filter { $0 }.count
            selected.stringValue = count == 0 ? "" : "\(count) selected"
            delete.isHidden = count == 0 || self?.main.zoom.value == true
        }.store(in: &subs)
    }
    
    func updateToggle() {
        main.index.value.map {
            toggle.state = main.grid.selected.value[$0] ? .on : .off
        }
    }
}
