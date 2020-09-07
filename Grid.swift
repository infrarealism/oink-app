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
            let count = floor(frame.width / width)
            let delta = floor(frame.width.truncatingRemainder(dividingBy: width) / count)
            size = .init(width: width + delta, height: width + delta)
            refresh()
        }
    }
    
    private var subs = Set<AnyCancellable>()
    private var queue = Set<Cell>()
    private var active = Set<Cell>()
    private var positions = [CGPoint]()
    private var visible = [Bool]()
    private var size = CGSize.zero
    private let width = CGFloat(320)
    
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
    
    override func mouseDown(with: NSEvent) {
        guard let cell = hitTest(with.locationInWindow) as? Grid.Cell else { return }
        cell.highlighted = true
    }
    
    override func mouseUp(with: NSEvent) {
        active.filter { $0.highlighted }.forEach { $0.highlighted = false }
        guard let cell = hitTest(with.locationInWindow) as? Grid.Cell else { return }
        
        let display = Display(item: cell.item!)
        display.translatesAutoresizingMaskIntoConstraints = false
        superview!.addSubview(display)
        
        let top = display.topAnchor.constraint(equalTo: topAnchor, constant: cell.frame.minY - contentView.bounds.minY)
        let bottom = display.bottomAnchor.constraint(equalTo: bottomAnchor, constant: cell.frame.maxY - frame.height)
        let left = display.leftAnchor.constraint(equalTo: leftAnchor, constant: cell.frame.minX)
        let right = display.rightAnchor.constraint(equalTo: rightAnchor, constant: cell.frame.maxX - frame.width)
        top.isActive = true
        bottom.isActive = true
        left.isActive = true
        right.isActive = true
        
        superview!.layoutSubtreeIfNeeded()

        DispatchQueue.main.async { [weak self] in
            top.constant = 0
            bottom.constant = 0
            left.constant = 0
            right.constant = 0
        
            NSAnimationContext.runAnimationGroup({
                $0.duration = 0.5
                $0.allowsImplicitAnimation = true
                self?.superview!.layoutSubtreeIfNeeded()
            }) {
                display.hd()
            }
        }
    }
    
    private func refresh() {
        updatePositions()
        render()
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
            let cell: Cell
            if visible[index] {
                cell = active.first { $0.index == index }!
            } else {
                cell = queue.popFirst() ?? Cell(size)
                cell.index = index
                cell.item = items[index]
                documentView!.addSubview(cell)
                active.insert(cell)
                self.visible[index] = true
            }
            cell.frame = .init(origin: positions[index], size: size)
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
