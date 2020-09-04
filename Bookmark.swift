import Foundation

struct Bookmark: Codable, Equatable {
    let id: URL
    private let data: Data
    
    var access: URL? { data.access }
    var location: String { id.directory ?? id.absoluteString }
    
    init(_ url: URL) {
        id = url
        data = url.bookmark
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        true
    }
    
    func hash(into: inout Hasher) {
        
    }
}

private extension Data {
    var access: URL? {
        var stale = false
        return (try? URL(resolvingBookmarkData: self, options: .withSecurityScope, bookmarkDataIsStale: &stale)).flatMap {
            $0.startAccessingSecurityScopedResource() ? $0 : nil
        }
    }
}

private extension URL {
    var bookmark: Data {
        try! bookmarkData(options: .withSecurityScope)
    }
    
    var directory: String? {
        getpwuid(getuid()).pointee.pw_dir.map {
            FileManager.default.string(withFileSystemRepresentation: $0, length: .init(strlen($0)))
        }.map {
            NSString(string: path.replacingOccurrences(of: $0, with: "~")).abbreviatingWithTildeInPath
        }
    }
}
