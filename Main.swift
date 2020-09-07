import AppKit

final class Main: NSView {
    private let url: URL?
    
    required init?(coder: NSCoder) { nil }
    init(bookmark: Bookmark) {
        url = bookmark.access
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let grid = Grid()
        addSubview(grid)
        
        grid.topAnchor.constraint(equalTo: topAnchor).isActive = true
        grid.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        grid.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        grid.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
 
        var photos = [Photo]()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        
        FileManager.default.enumerator(at: url!, includingPropertiesForKeys: nil, options:
            [.producesRelativePathURLs, .skipsHiddenFiles, .skipsPackageDescendants])?.forEach {
                guard
                    let url = $0 as? URL,
                    NSImage.imageTypes.contains(url.mime)
                else { return }
                
                let source = CGImageSourceCreateWithURL(url as CFURL, [kCGImageSourceShouldCache : false] as CFDictionary)
                guard
                    let dictionary = CGImageSourceCopyPropertiesAtIndex(source!, 0, nil) as? [String : AnyObject],
                    let exif = dictionary["{Exif}"] as? [String : AnyObject],
                    let rawDate = exif["DateTimeOriginal"] as? String,
                    let date = formatter.date(from: rawDate),
                    let isos = exif["ISOSpeedRatings"] as? [Int],
                    let iso = isos.first
                else { return }
                photos.append(.init(url, date: date, iso: iso))
        }
        grid.items = photos.sorted { $0.date < $1.date }
    }
    
    override func viewDidEndLiveResize() {
        
    }
    
    private func close() {
        url?.stopAccessingSecurityScopedResource()
    }
}
