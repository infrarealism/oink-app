import AppKit
import Combine

final class Grid: NSScrollView {
    private var subs = Set<AnyCancellable>()
    private var cells = [Cell]()
    private var positions = [CGPoint]()
    private var cellsHidden = [Int]()
    private var cellsVisible = [Int]()
    private let items: [Int]
    private let size = CGSize(width: 100, height: 100)
    
    required init?(coder: NSCoder) { nil }
    init() {
        items = (0 ... 50).map { $0 }
        
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        documentView = NSView(frame: .init(origin: .zero, size: .init(width: 1000, height: 1000)))
        hasVerticalScroller = true
        contentView.postsBoundsChangedNotifications = true
        
        NotificationCenter.default.publisher(for: NSView.boundsDidChangeNotification, object: contentView).sink { [weak self] _ in
//            self?.refresh()
            
//            print(($0.object as! NSClipView).bounds.minY)
        }.store(in: &subs)
    }
    
    override var frame: NSRect {
        didSet {
            updatePositions()
            refresh()
        }
    }
    
    private func updatePositions() {
        var positions = [CGPoint]()
        var current = CGPoint(x: -size.width, y: 0)
        (0 ..< items.count).forEach { _ in
            current.x += size.width
            if current.x + size.width > bounds.width {
                current = .init(x: 0, y: current.y + size.height)
            }
            positions.append(current)
        }
        self.positions = positions
    }
    
    private var visibles: [Int] {
        let min = contentView.bounds.minY - size.height
        let max = contentView.bounds.maxY + 1
        return (0 ..< items.count).filter {
            positions[$0].y > min && positions[$0].y < max
        }
    }
    
    private func refresh() {
        purgeVisible()
        
        visibles.forEach {
            let cell = Cell(size)
            cell.frame.origin = positions[$0]
            documentView!.addSubview(cell)
        }
    }
    
    private func purgeVisible() {
        
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
