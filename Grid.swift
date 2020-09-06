import AppKit
import Combine

final class Grid: NSScrollView {
    private var subs = Set<AnyCancellable>()
    private var queue = Set<Cell>()
    private var active = Set<Cell>()
    private var positions = [CGPoint]()
    private var visible: [Bool]
    private let items: [Int]
    private var padding = CGPoint.zero
    private let size = CGSize(width: 100, height: 100)
    
    required init?(coder: NSCoder) { nil }
    init() {
        items = (0 ... 5000).map { $0 }
        visible = .init(repeating: false, count: items.count)
        
        final class Flipped: NSView { override var isFlipped: Bool { true } }
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        documentView = Flipped()
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
            self.visible[index.0] = false
            queue.insert(cell)
        }
        print("cells: \(active.count), queued: \(queue.count)")
        current.forEach { index in
            guard !visible[index] else {
                active.first { $0.index == index }!.frame.origin = positions[index]
                return
            }
            let cell = queue.popFirst() ?? Cell(size)
            cell.index = index
            cell.frame.origin = positions[index]
            documentView!.addSubview(cell)
            active.insert(cell)
            self.visible[index] = true
        }
        
        print("cells: \(active.count), queued: \(queue.count)")
    }
}
