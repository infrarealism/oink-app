import AppKit

final class Export: NSPopover {
    private weak var main: Main!
    private weak var segmented: Segmented!
    private let sizes: [CGSize]
    private let widths = [CGFloat(320), 640, 1024, 1400]
    
    required init?(coder: NSCoder) { nil }
    init(main: Main) {
        sizes = (widths.filter { $0 < main.item!.size.width } + [main.item!.size.width]).map {
            .init(width: $0, height: ceil($0 / main.item!.size.width * main.item!.size.height))
        }
        self.main = main
        super.init()
        behavior = .transient
        contentSize = .init(width: 700, height: 220)
        contentViewController = .init()
        contentViewController!.view = .init()
        
        let title = Label("Resolution", .systemFont(ofSize: 16, weight: .bold))
        contentViewController!.view.addSubview(title)
        
        let segmented = Segmented(items: sizes.map { "\(Int($0.width))×\(Int($0.height))" })
        segmented.selected.value = widths.count / 2
        contentViewController!.view.addSubview(segmented)
        self.segmented = segmented
        
        let button = Control.Title(text: "Export", background: .systemPink, foreground: .white)
        button.target = self
        button.action = #selector(save)
        contentViewController!.view.addSubview(button)
        
        title.leftAnchor.constraint(equalTo: segmented.leftAnchor).isActive = true
        title.bottomAnchor.constraint(equalTo: segmented.topAnchor, constant: -12).isActive = true
        
        segmented.topAnchor.constraint(equalTo: contentViewController!.view.topAnchor, constant: 80).isActive = true
        segmented.centerXAnchor.constraint(equalTo: contentViewController!.view.centerXAnchor).isActive = true
        segmented.widthAnchor.constraint(equalToConstant: 640).isActive = true
        
        button.topAnchor.constraint(equalTo: segmented.bottomAnchor, constant: 40).isActive = true
        button.centerXAnchor.constraint(equalTo: contentViewController!.view.centerXAnchor).isActive = true
    }
    
    @objc private func save() {
        let size = sizes[segmented.selected.value]
        let main = self.main!
        let save = NSSavePanel()
        save.nameFieldStringValue = main.item!.url.lastPathComponent
        save.allowedFileTypes = ["jpg"]
        save.beginSheetModal(for: main.window!) {
            if $0 == .OK, let url = save.url {
                try? main.item!.export(size).write(to: url, options: .atomic)
                NSWorkspace.shared.activateFileViewerSelecting([url])
            }
        }
    }
}
