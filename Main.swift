import AppKit
import Combine

final class Main: NSView {
    let zoom = CurrentValueSubject<Bool, Never>(false)
    let index = CurrentValueSubject<Int?, Never>(nil)
    let items = CurrentValueSubject<[Photo], Never>([])
    let url: URL
    private weak var grid: Grid!
    private weak var coverflow: Coverflow!
    private var subs = Set<AnyCancellable>()
    
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
        
        let coverflow = Coverflow(main: self)
        coverflow.isHidden = true
        addSubview(coverflow)
        self.coverflow = coverflow
        
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
        
        zoom.dropFirst().debounce(for: .seconds(1), scheduler: DispatchQueue.main).sink {
            coverflow.isHidden = !$0
            grid.isHidden = $0
        }.store(in: &subs)
    }
    
    deinit {
        url.stopAccessingSecurityScopedResource()
    }
}
