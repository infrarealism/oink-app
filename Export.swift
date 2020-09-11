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
        contentSize = .init(width: 700, height: 260)
        contentViewController = .init()
        contentViewController!.view = .init()
        
        let title = Label("Resolution", .systemFont(ofSize: 16, weight: .bold))
        contentViewController!.view.addSubview(title)
        
        let segmented = Segmented(items: sizes.map { "\(Int($0.width))×\(Int($0.height))" })
        segmented.selected.value = sizes.count / 2
        contentViewController!.view.addSubview(segmented)
        self.segmented = segmented
        
        let export = Control.Title(text: "Export", background: .systemPink, foreground: .white)
        export.target = self
        export.action = #selector(save)
        contentViewController!.view.addSubview(export)
        
        let cancel = Control.Title(text: "Cancel", background: .clear, foreground: .labelColor)
        cancel.target = self
        cancel.action = #selector(close)
        contentViewController!.view.addSubview(cancel)
        
        title.leftAnchor.constraint(equalTo: segmented.leftAnchor).isActive = true
        title.bottomAnchor.constraint(equalTo: segmented.topAnchor, constant: -12).isActive = true
        
        segmented.topAnchor.constraint(equalTo: contentViewController!.view.topAnchor, constant: 80).isActive = true
        segmented.centerXAnchor.constraint(equalTo: contentViewController!.view.centerXAnchor).isActive = true
        segmented.widthAnchor.constraint(equalToConstant: 640).isActive = true
        
        export.topAnchor.constraint(equalTo: segmented.bottomAnchor, constant: 40).isActive = true
        export.centerXAnchor.constraint(equalTo: contentViewController!.view.centerXAnchor).isActive = true
        
        cancel.topAnchor.constraint(equalTo: export.bottomAnchor, constant: 10).isActive = true
        cancel.centerXAnchor.constraint(equalTo: contentViewController!.view.centerXAnchor).isActive = true
    }
    
    @objc private func save() {
        let size = sizes[segmented.selected.value]
        let main = self.main!
        let save = NSSavePanel()
        save.nameFieldStringValue = main.item!.url.lastPathComponent
        save.allowedFileTypes = ["jpg"]
        save.beginSheetModal(for: main.window!) {
            if $0 == .OK, let url = save.url {
                main.item!.export(size).map {
                    try? $0.write(to: url, options: .atomic)
                    NSWorkspace.shared.activateFileViewerSelecting([url])
                }
            }
        }
    }
}
