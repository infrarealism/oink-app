import AppKit

final class Main: NSView {
    private let url: URL?
    
    required init?(coder: NSCoder) { nil }
    init(bookmark: Bookmark) {
        url = bookmark.access
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let image = NSImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.imageScaling = .scaleProportionallyUpOrDown
        addSubview(image)
        
        let noCache = [kCGImageSourceShouldCache as String : kCFBooleanFalse] as CFDictionary
        
        url.map {
            FileManager.default.enumerator(at: $0, includingPropertiesForKeys: nil, options: [.producesRelativePathURLs, .skipsHiddenFiles, .skipsPackageDescendants])?.forEach {
                guard
                    let url = $0 as? URL,
                    NSImage.imageTypes.contains(url.mime)
                else { return }
                
                let source = try! CGImageSourceCreateWithData(Data(contentsOf: url) as CFData, noCache)
                print(CGImageSourceCopyPropertiesAtIndex(source!, 0, nil) as? [String: AnyObject])
                print("-----------------------------------------------")
                
                if image.image == nil {
                    image.image = try? NSImage(data: Data(contentsOf: url))
                }
            }
        }
        
        image.topAnchor.constraint(equalTo: topAnchor).isActive = true
        image.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        image.widthAnchor.constraint(equalToConstant: 300).isActive = true
        image.heightAnchor.constraint(equalToConstant: 300).isActive = true
    }
    
    private func close() {
        url?.stopAccessingSecurityScopedResource()
    }
}

