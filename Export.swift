import AppKit

final class Export: NSPopover {
    private weak var item: Photo?
    
    required init?(coder: NSCoder) { nil }
    init(item: Photo) {
        self.item = item
        super.init()
        behavior = .transient
        contentSize = .init(width: 500, height: 200)
        contentViewController = .init()
        contentViewController!.view = .init()
        
        let segmented = Segmented(items: ["640×480", "800x600", "960x720", "1024x768", "1280x960"])
        segmented.selected.value = 2
        contentViewController!.view.addSubview(segmented)
        
        segmented.topAnchor.constraint(equalTo: contentViewController!.view.topAnchor, constant: 50).isActive = true
        segmented.leftAnchor.constraint(equalTo: contentViewController!.view.leftAnchor, constant: 10).isActive = true
        segmented.widthAnchor.constraint(equalToConstant: 400).isActive = true
    }
}
