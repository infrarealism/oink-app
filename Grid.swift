import AppKit
import Combine

final class Grid: NSScrollView {
    private var subs = Set<AnyCancellable>()
    private var cells = [Cell]()
    private var cellsHidden = [Int]()
    private let items: [Int]
    private let size = CGSize(width: 100, height: 100)
    
    required init?(coder: NSCoder) { nil }
    init() {
        items = (0 ... 500).map { $0 }
        
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        documentView = NSView(frame: .init(origin: .zero, size: .init(width: 1000, height: 1000)))
        hasVerticalScroller = true
        contentView.postsBoundsChangedNotifications = true
        
        NotificationCenter.default.publisher(for: NSView.boundsDidChangeNotification, object: contentView)
            .sink {
                print(($0.object as! NSClipView).bounds.minY)
        }.store(in: &subs)
        
        items.forEach { _ in
            let cell = Cell(size)
            documentView!.addSubview(cell)
        }
    }
}

private final class Cell: NSView {
    private(set) weak var label: Label!
    
    required init?(coder: NSCoder) { nil }
    init(_ size: CGSize) {
        super.init(frame: .init(origin: .zero, size: size))
        wantsLayer = true
        layer!.backgroundColor = NSColor.systemIndigo.cgColor
        
        let label = Label("", .systemFont(ofSize: 20, weight: .bold))
        addSubview(label)
        self.label = label
        
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}
