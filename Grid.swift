import AppKit
import Combine

final class Grid: NSScrollView {
    private var subs = Set<AnyCancellable>()
    private var queue = Set<Cell>()
    private var active = Set<Cell>()
    private var positions = [CGPoint]()
    private var visible: [Bool]
    private let items: [Int]
    private let size = CGSize(width: 100, height: 100)
    
    required init?(coder: NSCoder) { nil }
    init() {
        items = (0 ... 5000).map { $0 }
        visible = .init(repeating: false, count: items.count)
        
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        documentView = .init()
        hasVerticalScroller = true
        contentView.postsBoundsChangedNotifications = true
        
        NotificationCenter.default.publisher(for: NSView.boundsDidChangeNotification, object: contentView).sink { [weak self] _ in
            self?.refresh()
            
//            print(($0.object as! NSClipView).bounds.minY)
        }.store(in: &subs)
    }
    
    override var frame: NSRect {
        didSet {
            documentView!.frame.size.width = frame.width
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
        documentView!.frame.size.height = current.y + size.height
    }
    
    private var current: Set<Int> {
        let min = contentView.bounds.minY - size.height
        let max = contentView.bounds.maxY + 1
        return .init((0 ..< items.count).filter {
            positions[$0].y > min && positions[$0].y < max
        })
    }
    
    private func refresh() {
        let current = self.current
        let visible = self.visible
        visible.enumerated().filter { $0.1 }.forEach { index in
            guard !current.contains(index.0) else { return }
            let cell = active.remove(at: active.firstIndex { $0.index == index.0 }!)
            cell.removeFromSuperview()
            cell.index = nil
            self.visible[index.0] = false
            queue.insert(cell)
        }
        print("cells: \(active.count), queued: \(queue.count)")
        current.forEach {
            guard !visible[$0] else { return }
            let cell = queue.popFirst() ?? Cell(size)
            cell.index = $0
            cell.frame.origin = positions[$0]
            documentView!.addSubview(cell)
            active.insert(cell)
            self.visible[$0] = true
        }
        
        print("cells: \(active.count), queued: \(queue.count)")
    }
}

private final class Cell: NSView {
    var index: Int? {
        didSet {
            label.stringValue = "\(index ?? -1)"
        }
    }
    private weak var label: Label!
    
    required init?(coder: NSCoder) { nil }
    init(_ size: CGSize) {
        super.init(frame: .init(origin: .zero, size: size))
        wantsLayer = true
        layer!.backgroundColor = NSColor.systemIndigo.withAlphaComponent(0.5).cgColor
        
        let label = Label("", .systemFont(ofSize: 20, weight: .bold))
        addSubview(label)
        self.label = label
        
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}
