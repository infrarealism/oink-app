import Foundation
import Balam
import Combine

final class Session {
    private let store = Balam("Oink")
    
    var bookmark: Future <Bookmark?, Never> {
        .init { [weak self] promise in
            var sub: AnyCancellable?
            sub = self?.store.nodes(Bookmark.self).sink {
                if let bookmark = $0.first,
                    let access = bookmark.access {
                        let remove = !FileManager.default.fileExists(atPath: access.path) || access.pathComponents.contains(".Trash")
                        access.stopAccessingSecurityScopedResource()
                        if remove {
                            self?.close()
                            promise(.success(nil))
                        } else {
                            promise(.success(bookmark))
                        }
                } else {
                    promise(.success(nil))
                }
                sub?.cancel()
            }
        }
    }
    
    func update(_ bookmark: Bookmark) {
        store.remove(bookmark)
        store.add(bookmark)
    }
    
    func close() {
        store.remove(Bookmark.self) { _ in true }
    }
}
