import AppKit
import Combine

final class Coverflow: NSScrollView {
    override var frame: NSRect {
        didSet {
            documentView!.frame.size.height = frame.height
            refresh()
        }
    }
    
    private weak var main: Main!
    private var subs = Set<AnyCancellable>()
    private var queue = Set([Cell(), .init(), .init()])
    private var active = Set<Cell>()
    
    required init?(coder: NSCoder) { nil }
    init(main: Main) {
        self.main = main
        super.init(frame: .zero)
        let content = Flip()
        content.wantsLayer = true
        translatesAutoresizingMaskIntoConstraints = false
        documentView = content
        hasHorizontalScroller = true
        contentView.postsBoundsChangedNotifications = true
        
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
        let active = self.active
        active.forEach {
            guard !current.contains($0.index) else { return }
            self.active.remove($0)
            $0.removeFromSuperlayer()
            $0.item = nil
            queue.insert($0)
        }
        current.forEach { index in
            let cell = self.active.first { $0.index == index } ?? {
                let cell = queue.popFirst()!
                cell.index = index
                cell.item = main.items.value[index]
                documentView!.layer!.addSublayer(cell)
                self.active.insert(cell)
                return cell
            } ()
            cell.frame = .init(origin: .init(x: frame.width * .init(index), y: 0), size: frame.size)
        }
    }
    
    private var current: [Int] {
        [contentView.bounds.midX - frame.width, contentView.bounds.midX, contentView.bounds.midX + frame.width].compactMap {
            {
                $0 >= 0 && $0 < main.items.value.count ? $0 : nil
            } (Int($0 / frame.width))
        }
    }
}
