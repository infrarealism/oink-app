import AppKit

final class Export: NSPopover {
    private weak var main: Main!
    private let sizes: [CGSize]
    private let width = [CGFloat(320), 640, 1024, 1400]
    
    required init?(coder: NSCoder) { nil }
    init(main: Main) {
        sizes =
        self.main = main
        super.init()
        behavior = .transient
        contentSize = .init(width: 700, height: 220)
        contentViewController = .init()
        contentViewController!.view = .init()
        
        let title = Label("Resolution", .systemFont(ofSize: 16, weight: .bold))
        contentViewController!.view.addSubview(title)
        
        let segmented = Segmented(items: ["320x240", "640×480", "1024x768", "1400×1050", "6000x6000"])
        segmented.selected.value = 2
        contentViewController!.view.addSubview(segmented)
        
        let button = Control.Title(text: "Export", background: .systemPink, foreground: .white)
        contentViewController!.view.addSubview(button)
        
        title.leftAnchor.constraint(equalTo: segmented.leftAnchor).isActive = true
        title.bottomAnchor.constraint(equalTo: segmented.topAnchor, constant: -12).isActive = true
        
        segmented.topAnchor.constraint(equalTo: contentViewController!.view.topAnchor, constant: 80).isActive = true
        segmented.centerXAnchor.constraint(equalTo: contentViewController!.view.centerXAnchor).isActive = true
        segmented.widthAnchor.constraint(equalToConstant: 640).isActive = true
        
        button.topAnchor.constraint(equalTo: segmented.bottomAnchor, constant: 40).isActive = true
        button.centerXAnchor.constraint(equalTo: contentViewController!.view.centerXAnchor).isActive = true
    }
}
