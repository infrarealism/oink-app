import Foundation
import Balam
import Combine

final class Session {
    private(set) var bookmark = PassthroughSubject<Bookmark?, Never>()
    private let store = Balam("Oink")
    
    func load() {
        var sub: AnyCancellable?
        sub = store.nodes(Bookmark.self).sink { [weak self] in
            if let bookmark = $0.first,
                let access = bookmark.access {
                    let remove = !FileManager.default.fileExists(atPath: access.path) || access.pathComponents.contains(".Trash")
                    access.stopAccessingSecurityScopedResource()
                    if remove {
                        self?.close()
                    } else {
                        self?.bookmark.send(bookmark)
                    }
            } else {
                self?.bookmark.send(nil)
            }
            sub?.cancel()
        }
    }
    
    func update(_ bookmark: Bookmark) {
        store.remove(bookmark)
        store.add(bookmark)
        self.bookmark.send(bookmark)
    }
    
    func close() {
        store.remove(Bookmark.self) { _ in true }
        bookmark.send(nil)
    }
}
