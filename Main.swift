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
        addSubview(image)
        
        url.map {
            FileManager.default.enumerator(at: $0, includingPropertiesForKeys: nil, options: [.producesRelativePathURLs, .skipsHiddenFiles, .skipsPackageDescendants])?.forEach {
                let url = $0 as! URL
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
