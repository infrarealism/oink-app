import AppKit
import Combine

final class Main: NSView {
    private(set) weak var grid: Grid!
    let zoom = CurrentValueSubject<Bool, Never>(false)
    let index = CurrentValueSubject<Int?, Never>(nil)
    let items = CurrentValueSubject<[Photo], Never>([])
    let url: URL
    private weak var bar: Bar!
    private weak var coverflow: Coverflow!
    private var subs = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) { nil }
    init(url: URL) {
        self.url = url
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let grid = Grid(main: self)
        addSubview(grid)
        self.grid = grid
        
        let coverflow = Coverflow(main: self)
        coverflow.isHidden = true
        addSubview(coverflow)
        self.coverflow = coverflow
        
        let bar = Bar(main: self)
        addSubview(bar)
        self.bar = bar
        
        bar.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bar.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bar.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        
        grid.topAnchor.constraint(equalTo: topAnchor).isActive = true
        grid.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        grid.leftAnchor.constraint(equalTo: bar.rightAnchor).isActive = true
        grid.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        coverflow.topAnchor.constraint(equalTo: topAnchor).isActive = true
        coverflow.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        coverflow.leftAnchor.constraint(equalTo: bar.rightAnchor).isActive = true
        coverflow.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        DispatchQueue.global(qos: .utility).async { [weak self] in
            self?.items.value = url.items
        }
        
        zoom.dropFirst().sink {
            if $0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    coverflow.isHidden = false
                    grid.isHidden = true
                }
            } else {
                coverflow.isHidden = true
                grid.isHidden = false
            }
        }.store(in: &subs)
        
        (NSApp.mainMenu as! Menu).main = self
    }
    
    deinit {
        url.stopAccessingSecurityScopedResource()
    }
    
    @objc func delete() {
        let alert = NSAlert()
        alert.messageText = "Delete selected?"
        alert.informativeText = "Can't be undone"
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "Delete")
        alert.alertStyle = .warning
        alert.beginSheetModal(for: window!) { [weak self] in
            guard let self = self, $0 == .alertSecondButtonReturn else { return }
            self.items.value = self.items.value.enumerated().reduce(into: [Photo]()) {
                guard self.grid.selected.value[$1.0] else {
                    $0.append($1.1)
                    return
                }
                try? FileManager.default.trashItem(at: $1.1.url, resultingItemURL: nil)
                return
            }
        }
    }
    
    @objc func export(_ button: Bar.Item) {
        index.value.map {
            Export(item: items.value[$0]).show(relativeTo: button.bounds, of: button, preferredEdge: .maxX)
        }
    }
    
    @objc func toggle() {
        index.value.map(grid.toggle)
        bar.updateToggle()
    }
    
    @objc func back() {
        index.value = nil
        zoom.value = false
    }
    
    @objc func previous() {
        index.value.map {
            index.value = max(0, $0 - 1)
            coverflow.animateCenter()
        }
    }
    
    @objc func next() {
        index.value.map {
            index.value = min(items.value.count - 1, $0 + 1)
            coverflow.animateCenter()
        }
    }
}
