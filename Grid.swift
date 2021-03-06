import AppKit
import Combine

final class Grid: NSScrollView {
    override var frame: NSRect {
        didSet {
            documentView!.frame.size.width = frame.width
            let total = frame.width - 1
            let width = self.width + 1
            let count = floor(total / width)
            let delta = total.truncatingRemainder(dividingBy: width) / count
            size = .init(width: self.width + delta, height: self.width + delta)
            refresh()
        }
    }
    
    var selection: Bool {
        !selected.value.filter { $0 }.isEmpty
    }
    
    let selected = CurrentValueSubject<[Bool], Never>([])
    private(set) var positions = [CGPoint]()
    private(set) var size = CGSize.zero
    private weak var zoomed: Cell?
    private weak var main: Main!
    private var subs = Set<AnyCancellable>()
    private var queue = Set<Cell>()
    private var active = Set<Cell>()
    private var visible = [Bool]()
    private let width = CGFloat(120)
    
    required init?(coder: NSCoder) { nil }
    init(main: Main) {
        self.main = main
        super.init(frame: .zero)
        let content = Flip()
        content.wantsLayer = true
        translatesAutoresizingMaskIntoConstraints = false
        documentView = content
        hasVerticalScroller = true
        contentView.postsBoundsChangedNotifications = true
        backgroundColor = .black
        
        NotificationCenter.default.publisher(for: NSView.boundsDidChangeNotification, object: contentView).sink { [weak self] _ in
            guard self?.isHidden == false else { return }
            self?.refresh()
        }.store(in: &subs)
        
        main.items.dropFirst().receive(on: DispatchQueue.main).sink { [weak self] in
            content.layer!.sublayers?.forEach { $0.removeFromSuperlayer() }
            self?.queue = []
            self?.active = []
            self?.visible = .init(repeating: false, count: $0.count)
            self?.selected.value = .init(repeating: false, count: $0.count)
            self?.refresh()
        }.store(in: &subs)
        
        main.index.dropFirst().sink { [weak self] in
            guard let self = self, self.zoomed?.index != $0 else { return }
            if let zoomed = self.zoomed {
                zoomed.update(.init(origin: self.positions[zoomed.index], size: self.size))
                self.zoomed = nil
            }
            if let index = $0 {
                if self.isHidden {
                    self.contentView.bounds.origin.y = max(min(self.positions[index].y - (self.frame.height / 2), content.frame.size.height - self.frame.height), 0)
                    self.refresh()
                }
                let zoomed = self.cell(index)
                content.layer!.bringFront(zoomed)
                zoomed.update(.init(x: 0, y: self.contentView.bounds.minY, width: self.frame.width, height: self.frame.height))
                self.zoomed = zoomed
            }
        }.store(in: &subs)
    }
    
    override func mouseDown(with: NSEvent) {
        guard
            !main.zoom.value,
            let cell = cell(with)
        else { return }
        selected.value[cell.index].toggle()
        cell.highlighted = selected.value[cell.index]
        if with.clickCount == 2 {
            main.zoom.value = true
            main.index.value = cell.index
        }
    }
    
    func toggle(_ index: Int) {
        selected.value[index].toggle()
        active.first { $0.index == index }?.highlighted = selected.value[index]
    }
    
    private func refresh() {
        reposition()
        render()
    }
    
    private func reposition() {
        var positions = [CGPoint]()
        var current = CGPoint(x: -size.width, y: 2)
        (0 ..< main.items.value.count).forEach { _ in
            current.x += size.width + 1
            if current.x + size.width > bounds.width {
                current = .init(x: 1, y: current.y + size.height + 1)
            }
            positions.append(current)
        }
        self.positions = positions
        documentView!.frame.size.height = max(current.y + size.height + 2, frame.size.height)
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
        current.forEach {
            let item = cell($0)
            item.frame = .init(origin: positions[$0], size: size)
            item.highlighted = selected.value[$0]
        }
    }
    
    private var current: Set<Int> {
        let min = contentView.bounds.minY - size.height
        let max = contentView.bounds.maxY + 1
        return .init((0 ..< main.items.value.count).filter {
            positions[$0].y > min && positions[$0].y < max
        })
    }
    
    private func cell(_ index: Int) -> Cell {
        guard visible[index] else {
            let cell = queue.popFirst() ?? Cell()
            cell.index = index
            cell.item = main.items.value[index]
            documentView!.layer!.addSublayer(cell)
            active.insert(cell)
            visible[index] = true
            return cell
        }
        return active.first { $0.index == index }!
    }
    
    private func cell(_ with: NSEvent) -> Cell? {
        positions.map { CGRect(origin: $0, size: size) }.firstIndex { $0.contains(documentView!.convert(with.locationInWindow, from: nil)) }.flatMap { index in
            active.first { $0.index == index }
        }
    }
}
