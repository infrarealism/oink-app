import AppKit

final class Main: NSView {
    weak var item: Photo?
    private(set) weak var session: Session!
    let url: URL?
    private weak var bar: Bar!
    
    deinit {
        url?.stopAccessingSecurityScopedResource()
    }
    
    required init?(coder: NSCoder) { nil }
    init(session: Session, bookmark: Bookmark) {
        self.session = session
        url = bookmark.access
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let bar = Bar(main: self)
        addSubview(bar)
        self.bar = bar
        
        bar.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bar.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bar.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let items = self?.items else { return }
            DispatchQueue.main.async {
                guard let self = self else { return }
                bar.update(items)
                let grid = Grid(main: self, items: items.sorted { $0.date > $1.date })
                self.addSubview(grid)
                
                grid.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
                grid.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
                grid.leftAnchor.constraint(equalTo: bar.rightAnchor).isActive = true
                grid.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
            }
        }
    }
    
    private var items: [Photo] {
        var items = [Photo]()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        
        FileManager.default.enumerator(at: url!, includingPropertiesForKeys: nil, options:
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
        return items
    }
}
