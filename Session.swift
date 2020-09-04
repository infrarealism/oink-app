import Foundation
import Balam
import Combine

final class Session {
    private(set) var bookmark = PassthroughSubject<Bookmark?, Never>()
    private let store = Balam("Oink")
    
    func load() {
        var sub: AnyCancellable?
        sub = store.nodes(Bookmark.self).sink {
            self.bookmark.send($0.first)
            sub?.cancel()
        }
    }
    
    func update(_ bookmark: Bookmark) {
        store.remove(bookmark)
        store.add(bookmark)
        self.bookmark.send(bookmark)
    }
}
