import AppKit
import Combine

final class Main: NSView {
    let cell = CurrentValueSubject<Grid.Cell?, Never>(nil)
    let items = CurrentValueSubject<[Photo], Never>([])
    let url: URL
    private weak var grid: Grid!
    
    required init?(coder: NSCoder) { nil }
    init(url: URL) {
        self.url = url
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let bar = Bar(main: self)
        addSubview(bar)
        
        let grid = Grid(main: self)
        addSubview(grid)
        self.grid = grid
        
        bar.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bar.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bar.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        
        grid.topAnchor.constraint(equalTo: topAnchor).isActive = true
        grid.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        grid.leftAnchor.constraint(equalTo: bar.rightAnchor).isActive = true
        grid.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        DispatchQueue.global(qos: .utility).async { [weak self] in
            self?.items.value = url.items
        }
    }
    
    deinit {
        url.stopAccessingSecurityScopedResource()
    }
    
    func select(_ cell: Grid.Cell) {
        cell.removeFromSuperlayer()
        grid.documentView!.layer!.addSublayer(cell)
        cell.update(.init(x: 0, y: -grid.contentView.bounds.minY, width: grid.frame.width, height: grid.frame.height))
        self.cell.value = cell
    }
}
