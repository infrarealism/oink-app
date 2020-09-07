import AppKit

final class Main: NSView {
    private let url: URL?
    
    required init?(coder: NSCoder) { nil }
    init(bookmark: Bookmark) {
        url = bookmark.access
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let grid = Grid()
        grid.items = (0 ... 5000).map { $0 }
        addSubview(grid)
        
        grid.topAnchor.constraint(equalTo: topAnchor).isActive = true
        grid.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        grid.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        grid.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
 
        FileManager.default.enumerator(at: url!, includingPropertiesForKeys: nil, options:
            [.producesRelativePathURLs, .skipsHiddenFiles, .skipsPackageDescendants])?.forEach {
            guard
                let url = $0 as? URL,
                NSImage.imageTypes.contains(url.mime)
            else { return }
            
            let source = try! CGImageSourceCreateWithURL(url as CFURL, [kCGImageSourceShouldCache : false] as CFDictionary)
            print((CGImageSourceCopyPropertiesAtIndex(source!, 0, nil) as? [String: AnyObject])?["{Exif}"])
                
                let image = NSImage(cgImage: CGImageSourceCreateThumbnailAtIndex(source!, 0, [
                kCGImageSourceCreateThumbnailFromImageAlways : false,
                kCGImageSourceCreateThumbnailFromImageIfAbsent : false,
                kCGImageSourceThumbnailMaxPixelSize : 900] as CFDictionary)!, size: .init(width: 900, height: 900))
             
        }
    }
    
    override func viewDidEndLiveResize() {
        
    }
    
    private func close() {
        url?.stopAccessingSecurityScopedResource()
    }
}
