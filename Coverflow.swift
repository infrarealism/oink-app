import AppKit
import Combine

final class Coverflow: NSScrollView {
    override var frame: NSRect {
        didSet {
            documentView!.frame.size.width = frame.width
            let total = frame.width - 1
            let width = self.width + 1
            let count = floor(total / width)
            let delta = floor(total.truncatingRemainder(dividingBy: width) / count)
            size = .init(width: self.width + delta, height: self.width + delta)
            refresh()
        }
    }
    
    private weak var main: Main!
    private var subs = Set<AnyCancellable>()
    private var queue = [Cell(), .init(), .init()]
    
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
        
        queue.forEach(content.layer!.addSublayer)
        
        NotificationCenter.default.publisher(for: NSView.boundsDidChangeNotification, object: contentView).sink { [weak self] _ in
            self?.refresh()
        }.store(in: &subs)
        
        main.items.dropFirst().receive(on: DispatchQueue.main).sink { [weak self] _ in
            self?.refresh()
        }.store(in: &subs)
        
        main.index.dropFirst().sink { [weak self] in
            guard let self = self else { return }
//            if let zoomed = self.zoomed {
//                zoomed.update(.init(origin: self.positions[zoomed.index], size: self.size))
//            }
            if let index = $0 {
//                let zoomed = self.cell(index)
//                content.layer!.bringFront(zoomed)
//                zoomed.update(.init(x: 0, y: self.contentView.bounds.minY, width: self.frame.width, height: self.frame.height))
//                self.zoomed = zoomed
            }
        }.store(in: &subs)
    }
    
    private func refresh() {
        documentView!.frame.size.width = frame.width * .init(main.items.value.count)
        render()
    }
    
    private func render() {
        let current = self.current
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
        }
    }
    
    private var current: [Int] {
        [contentView.bounds.midX - frame.width, contentView.bounds.midX, contentView.bounds.midX + frame.width].compactMap {
            {
                $0 >= 0 && $0 < main.items.value.count ? $0 : nil
            } (Int($0 / frame.width))
        }
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
}
