import AppKit

final class Export: NSPopover {
    private weak var main: Main!
    
    required init?(coder: NSCoder) { nil }
    init(main: Main) {
        self.main = main
        super.init()
        behavior = .transient
        contentSize = .init(width: 700, height: 200)
        contentViewController = .init()
        contentViewController!.view = .init()
        
        let segmented = Segmented(items: ["320x240", "640×480", "1024x768", "1400×1050", "6000x6000"])
        segmented.selected.value = 2
        contentViewController!.view.addSubview(segmented)
        
        segmented.topAnchor.constraint(equalTo: contentViewController!.view.topAnchor, constant: 50).isActive = true
        segmented.centerXAnchor.constraint(equalTo: contentViewController!.view.centerXAnchor).isActive = true
        segmented.widthAnchor.constraint(equalToConstant: 640).isActive = true
    }
}
