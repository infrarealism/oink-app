import AppKit
import Combine

final class Window: NSWindow {
    private var subs = Set<AnyCancellable>()
    private let session = Session()
    
    init() {
        super.init(contentRect: .init(x: 0, y: 0, width: 1200, height: 800), styleMask:
            [.borderless, .closable, .miniaturizable, .resizable, .titled, .unifiedTitleAndToolbar, .fullSizeContentView],
                   backing: .buffered, defer: false)
        minSize = .init(width: 700, height: 400)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        toolbar = .init()
        toolbar!.showsBaselineSeparator = false
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        center()
        setFrameAutosaveName("Window")
        
        session.bookmark.sink {
            if let bookmark = $0 {
                self.main(bookmark)
            } else {
                self.launch()
            }
        }.store(in: &subs)
        session.load()
    }
    
    override func close() {
        super.close()
        NSApp.terminate(nil)
    }
    
    private func launch() {
        contentView!.subviews.forEach { $0.removeFromSuperview() }
        
        let launch = Launch(session: session)
        contentView!.addSubview(launch)
        
        launch.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        launch.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        launch.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        launch.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
    }
    
    private func main(_ bookmark: Bookmark) {
        contentView!.subviews.forEach { $0.removeFromSuperview() }
        
        let main = Main(session: session, bookmark: bookmark)
        contentView!.addSubview(main)
        
        main.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        main.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        main.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        main.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
    }
}
