import AppKit
import Combine

final class Main: NSView {
    private(set) weak var session: Session!
    let cell = CurrentValueSubject<Grid.Cell?, Never>(nil)
    let items = CurrentValueSubject<[Photo], Never>([])
    let url: URL
    
    required init?(coder: NSCoder) { nil }
    init(session: Session, url: URL) {
        self.session = session
        self.url = url
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let bar = Bar(main: self)
        addSubview(bar)
        
        let grid = Grid(main: self)
        addSubview(grid)
        
        bar.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bar.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bar.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        
        grid.topAnchor.constraint(equalTo: topAnchor).isActive = true
        grid.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        grid.leftAnchor.constraint(equalTo: bar.rightAnchor).isActive = true
        grid.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        DispatchQueue.global(qos: .utility).async { [weak self] in
            self?.load()
        }
    }
    
    deinit {
        url.stopAccessingSecurityScopedResource()
    }
    
    private func load() {
        var items = [Photo]()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        
        FileManager.default.enumerator(at: url, includingPropertiesForKeys: nil, options:
            [.producesRelativePathURLs, .skipsHiddenFiles, .skipsPackageDescendants])?.forEach {
                guard
                    let url = $0 as? URL,
                    NSImage.imageTypes.contains(url.mime),
                    let bytes = (try? FileManager.default.attributesOfItem(atPath: url.path)).flatMap({ $0[.size] as? Int })
                else { return }
                
                var date: Date?
                var iso: Int?
                
                let source = CGImageSourceCreateWithURL(url as CFURL, [kCGImageSourceShouldCache : false] as CFDictionary)
                guard
                    let dictionary = CGImageSourceCopyPropertiesAtIndex(source!, 0, nil) as? [String : AnyObject],
                    let width = dictionary["PixelWidth"] as? Int,
                    let height = dictionary["PixelHeight"] as? Int
                else { return }
                
                if let exif = dictionary["{Exif}"] as? [String : AnyObject] {
                    if let rawDate = exif["DateTimeOriginal"] as? String {
                        date = formatter.date(from: rawDate)
                    }
                    if let isos = exif["ISOSpeedRatings"] as? [Int] {
                        iso = isos.first
                    }
                }
                
                if date == nil {
                    date = (try? FileManager.default.attributesOfItem(atPath: url.path)).flatMap({ $0[.creationDate] as? Date })
                }
                
                if let date = date {
                    items.append(.init(url, date: date, iso: iso, size: .init(width: width, height: height), bytes: bytes))
                }
        }
        self.items.value = items.sorted { $0.date > $1.date }
    }
}
