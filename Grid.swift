import AppKit
import Combine

final class Grid: NSScrollView {
    var items = [Photo]() {
        didSet {
            documentView!.subviews.forEach { $0.removeFromSuperview() }
            queue = []
            active = []
            visible = .init(repeating: false, count: items.count)
            refresh()
        }
    }
    
    override var frame: NSRect {
        didSet {
            documentView!.frame.size.width = frame.width
            refresh()
        }
    }
    
    private var subs = Set<AnyCancellable>()
    private var queue = Set<Cell>()
    private var active = Set<Cell>()
    private var positions = [CGPoint]()
    private var visible = [Bool]()
    private var padding = CGPoint(x: 0, y: 50)
    private let size = CGSize(width: 200, height: 200)
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        documentView = Content()
        hasVerticalScroller = true
        contentView.postsBoundsChangedNotifications = true
        
        NotificationCenter.default.publisher(for: NSView.boundsDidChangeNotification, object: contentView).sink { [weak self] _ in
            self?.refresh()
        }.store(in: &subs)
    }
    
    private func refresh() {
        updatePositions()
        render()
    }
    
    private func updatePositions() {
        var positions = [CGPoint]()
        padding.x = bounds.width.truncatingRemainder(dividingBy: size.width) / 2
        var current = CGPoint(x: padding.x - size.width, y: padding.y)
        (0 ..< items.count).forEach { _ in
            current.x += size.width
            if current.x + size.width > bounds.width {
                current = .init(x: padding.x, y: current.y + size.height)
            }
            positions.append(current)
        }
        self.positions = positions
        documentView!.frame.size.height = current.y + size.height + padding.y
    }
    
    private func render() {
        let current = self.current
        let visible = self.visible
        visible.enumerated().filter { $0.1 }.forEach { index in
            guard !current.contains(index.0) else { return }
            let cell = active.remove(at: active.firstIndex { $0.index == index.0 }!)
            cell.removeFromSuperview()
            cell.item = nil
            self.visible[index.0] = false
            queue.insert(cell)
        }
        current.forEach { index in
            guard !visible[index] else {
                active.first { $0.index == index }!.frame.origin = positions[index]
                return
            }
            let cell = queue.popFirst() ?? Cell(size)
            cell.index = index
            cell.item = items[index]
            cell.frame.origin = positions[index]
            documentView!.addSubview(cell)
            active.insert(cell)
            self.visible[index] = true
        }
    }
    
    private var current: Set<Int> {
        let min = contentView.bounds.minY - size.height
        let max = contentView.bounds.maxY + 1
        return .init((0 ..< items.count).filter {
            positions[$0].y > min && positions[$0].y < max
        })
    }
}

private final class Content: NSView { override var isFlipped: Bool { true } }
