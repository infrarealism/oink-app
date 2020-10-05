import AppKit
import Combine

final class Window: NSWindow {
    private var subs = Set<AnyCancellable>()
    private let session = Session()
    
    init() {
        super.init(contentRect: .init(x: 0, y: 0, width: 1200, height: 800), styleMask:
            [.borderless, .closable, .miniaturizable, .resizable, .titled, .unifiedTitleAndToolbar, .fullSizeContentView],
                   backing: .buffered, defer: false)
        minSize = .init(width: 800, height: 500)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        toolbar = .init()
        toolbar!.showsBaselineSeparator = false
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        center()
        setFrameAutosaveName("Window")
        
        session.bookmark.sink { [weak self] in
            if let bookmark = $0 {
                self?.main(bookmark)
            } else {
                self?.launch()
            }
        }.store(in: &subs)
    }
    
    override func close() {
        super.close()
        NSApp.terminate(nil)
    }
    
    @objc func folder() {
        let browse = NSOpenPanel()
        browse.canChooseFiles = false
        browse.canChooseDirectories = true
        browse.prompt = "Select"
        browse.beginSheetModal(for: self) { [weak self] in
            guard $0 == .OK else { return }
            let bookmark = Bookmark(browse.url!)
            self?.session.update(bookmark)
            self?.main(bookmark)
        }
    }
    
    private func launch() {
        contentView!.subviews.forEach { $0.removeFromSuperview() }
        
        let launch = Launch()
        contentView!.addSubview(launch)
        
        launch.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        launch.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        launch.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        launch.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
    }
    
    private func main(_ bookmark: Bookmark) {
        contentView!.subviews.forEach { $0.removeFromSuperview() }
        
        guard let url = bookmark.access else { return }
        let main = Main(url: url)
        contentView!.addSubview(main)
        
        main.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        main.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        main.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        main.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
    }
}
