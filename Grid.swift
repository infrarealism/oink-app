import AppKit
import Combine

final class Grid: NSScrollView {
    var items = [Photo]() {
        didSet {
            documentView!.layer!.sublayers?.forEach { $0.removeFromSuperlayer() }
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
    
    private weak var main: Main!
    private var subs = Set<AnyCancellable>()
    private var queue = Set<Cell>()
    private var active = Set<Cell>()
    private var positions = [CGPoint]()
    private var size = CGSize.zero
    private var visible = [Bool]()
    private let width = CGFloat(120)
    
    required init?(coder: NSCoder) { nil }
    init(main: Main) {
        self.main = main
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        documentView = Content()
        documentView!.wantsLayer = true
        hasVerticalScroller = true
        contentView.postsBoundsChangedNotifications = true
        
        NotificationCenter.default.publisher(for: NSView.boundsDidChangeNotification, object: contentView).sink { [weak self] _ in
            self?.refresh()
        }.store(in: &subs)
    }
    
    override func mouseDown(with: NSEvent) {
        cell(with)?.highlighted = true
    }
    
    override func mouseUp(with: NSEvent) {
        guard main.cell.value == nil else { return }
        
        active.filter { $0.highlighted }.forEach { $0.highlighted = false }
        guard let cell = cell(with) else { return }
        main.cell.value = cell
        
        let display = Display(main: main)
        display.translatesAutoresizingMaskIntoConstraints = false
        main.addSubview(display)
        
        display.top = display.topAnchor.constraint(equalTo: topAnchor, constant: cell.frame.minY - contentView.bounds.minY)
        display.bottom = display.bottomAnchor.constraint(equalTo: bottomAnchor, constant: (cell.frame.maxY - contentView.bounds.minY) - frame.height)
        display.left = display.leftAnchor.constraint(equalTo: leftAnchor, constant: cell.frame.minX)
        display.right = display.rightAnchor.constraint(equalTo: rightAnchor, constant: cell.frame.maxX - frame.width)
        main.layoutSubtreeIfNeeded()

        DispatchQueue.main.async { [weak self] in
            display.big()
            NSAnimationContext.runAnimationGroup({
                $0.duration = 0.4
                $0.allowsImplicitAnimation = true
                self?.main.layoutSubtreeIfNeeded()
            }) {
                display.open()
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
            cell.removeFromSuperlayer()
            cell.item = nil
            self.visible[index.0] = false
            queue.insert(cell)
        }
        current.forEach { index in
            let cell: Cell
            if visible[index] {
                cell = active.first { $0.index == index }!
            } else {
                cell = queue.popFirst() ?? Cell()
                cell.index = index
                cell.item = items[index]
                documentView!.layer!.addSublayer(cell)
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
    
    private func cell(_ with: NSEvent) -> Cell? {
        positions.map { CGRect(origin: $0, size: size) }.firstIndex { $0.contains(documentView!.convert(with.locationInWindow, from: nil)) }.flatMap { index in
            active.first { $0.index == index }
        }
    }
}

private final class Content: NSView { override var isFlipped: Bool { true } }
