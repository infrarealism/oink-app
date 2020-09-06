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
        
        /*
        let scroll = Scroll()
        addSubview(scroll)
        
        let image = NSImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.imageScaling = .scaleProportionallyUpOrDown
        addSubview(image)
        
        let noCache = [kCGImageSourceShouldCache : false] as CFDictionary
        
        url.map {
            FileManager.default.enumerator(at: $0, includingPropertiesForKeys: nil, options: [.producesRelativePathURLs, .skipsHiddenFiles, .skipsPackageDescendants])?.forEach {
                guard
                    let url = $0 as? URL,
                    NSImage.imageTypes.contains(url.mime)
                else { return }
                
                let source = try! CGImageSourceCreateWithURL(url as CFURL, nil)
                print(CGImageSourceCopyPropertiesAtIndex(source!, 0, nil) as? [String: AnyObject])
//                print("-----------------------------------------------")
                
                if image.image == nil {
                    
                    let x = try! NSBitmapImageRep(data: Data(contentsOf: url))
//                    print(x)
                    
//                    image.image = try! NSImage(data: Data(contentsOf: url))
                    image.image = NSImage(cgImage: CGImageSourceCreateThumbnailAtIndex(source!, 0, [
                    kCGImageSourceCreateThumbnailFromImageAlways : false,
                    kCGImageSourceCreateThumbnailFromImageIfAbsent : false,
                    kCGImageSourceThumbnailMaxPixelSize : 900] as CFDictionary)!, size: .init(width: 900, height: 900))
//                    image.image = NSImage(cgImage: CGImageSourceCreateImageAtIndex(source!, 0, nil)!, size: .init(width: 50, height: 50))
//                    print(raw?.representations)
                    
                }
            }
        }
        
        image.topAnchor.constraint(equalTo: topAnchor).isActive = true
        image.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        image.widthAnchor.constraint(equalToConstant: 400).isActive = true
        image.heightAnchor.constraint(equalToConstant: 400).isActive = true
        */
    }
    
    override func viewDidEndLiveResize() {
        
    }
    
    private func close() {
        url?.stopAccessingSecurityScopedResource()
    }
}
