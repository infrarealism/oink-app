import AppKit

final class Main: NSView {
    weak var item: Photo?
    private(set) weak var session: Session!
    private let url: URL?
    
    required init?(coder: NSCoder) { nil }
    init(session: Session, bookmark: Bookmark) {
        self.session = session
        url = bookmark.access
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
 
        var photos = [Photo]()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        
        FileManager.default.enumerator(at: url!, includingPropertiesForKeys: nil, options:
            [.producesRelativePathURLs, .skipsHiddenFiles, .skipsPackageDescendants])?.forEach {
                guard
                    let url = $0 as? URL,
                    NSImage.imageTypes.contains(url.mime),
                    let bytes = (try? FileManager.default.attributesOfItem(atPath: url.path)).flatMap({ $0[.size] as? Int })
                else { return }
                
                let source = CGImageSourceCreateWithURL(url as CFURL, [kCGImageSourceShouldCache : false] as CFDictionary)
                guard
                    let dictionary = CGImageSourceCopyPropertiesAtIndex(source!, 0, nil) as? [String : AnyObject],
                    let exif = dictionary["{Exif}"] as? [String : AnyObject],
                    let width = dictionary["PixelWidth"] as? Int,
                    let height = dictionary["PixelHeight"] as? Int,
                    let rawDate = exif["DateTimeOriginal"] as? String,
                    let date = formatter.date(from: rawDate),
                    let isos = exif["ISOSpeedRatings"] as? [Int],
                    let iso = isos.first
                else { return }
                
                photos.append(.init(url, date: date, iso: iso, size: .init(width: width, height: height), bytes: bytes))
        }
        grid.items = photos.sorted { $0.date < $1.date }
    }
    
    private func close() {
        url?.stopAccessingSecurityScopedResource()
    }
}
