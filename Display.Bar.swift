import AppKit

extension Display {
    final class Bar: NSView {
        weak var top: NSLayoutConstraint! { didSet { top.isActive = true } }
        private(set) weak var close: Control.Button!
        private weak var main: Main!
        
        required init?(coder: NSCoder) { nil }
        init(main: Main) {
            self.main = main
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            wantsLayer = true
            layer!.backgroundColor = .init(gray: 0, alpha: 0.8)
            
            let close = Control.Button(icon: "xmark", color: .labelColor)
            addSubview(close)
            self.close = close
            
            let date = DateFormatter()
            date.dateStyle = .full
            date.timeStyle = .short
            let bytes = ByteCountFormatter()
            
//            let title = main.item!.url.lastPathComponent + " - " + date.string(from: main.item!.date) + " - \(Int(main.item!.size.width))×\(Int(main.item!.size.height)) - " + bytes.string(from: .init(value: .init(main.item!.bytes), unit: .bytes)) + (main.item!.iso == nil ? "" : " - ISO \(main.item!.iso!)")
            
            let label = Label(.systemFont(ofSize: 13, weight: .regular))
//            label.stringValue = title
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            addSubview(label)
            
            let share = Control.Circle(icon: "share", background: .systemIndigo, foreground: .white)
            share.target = self
            share.action = #selector(self.share)
            addSubview(share)
            
            heightAnchor.constraint(equalToConstant: 60).isActive = true
            
            close.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            close.leftAnchor.constraint(equalTo: leftAnchor, constant: 5).isActive = true
            
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            label.leftAnchor.constraint(equalTo: close.rightAnchor, constant: 5).isActive = true
            
            share.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
            share.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        }
        
        @objc private func share(_ button: Control.Circle) {
            guard let item = main.cell.value?.item else { return }
            let export = Export(item: item)
            export.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
}
