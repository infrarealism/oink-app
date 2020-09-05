import AppKit

final class Scroll: NSScrollView {
    var views: [NSView] { documentView!.subviews }
    var top: NSLayoutYAxisAnchor { documentView!.topAnchor }
    var bottom: NSLayoutYAxisAnchor { documentView!.bottomAnchor }
    var left: NSLayoutXAxisAnchor { documentView!.leftAnchor }
    var right: NSLayoutXAxisAnchor { documentView!.rightAnchor }
    var centerX: NSLayoutXAxisAnchor { documentView!.centerXAnchor }
    var centerY: NSLayoutYAxisAnchor { documentView!.centerYAnchor }
    var width: NSLayoutDimension { documentView!.widthAnchor }
    var height: NSLayoutDimension { documentView!.heightAnchor }
    
    required init?(coder: NSCoder) { nil }
    init() {
        final class Flipped: NSView { override var isFlipped: Bool { true } }
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        hasVerticalScroller = false
        hasHorizontalScroller = false
        documentView = Flipped()
        documentView!.translatesAutoresizingMaskIntoConstraints = false
        documentView!.topAnchor.constraint(equalTo: topAnchor).isActive = true
        documentView!.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
    }
    
    func add(_ view: NSView) { documentView!.addSubview(view) }
    
    func center(_ frame: CGRect, duration: TimeInterval) {
        var frame = frame
        frame.origin.x -= (bounds.width - frame.size.width) / 2
        frame.origin.y -= (bounds.height / 2) - frame.size.height
        frame.size.width = bounds.width
        frame.size.height = bounds.height
        NSAnimationContext.runAnimationGroup {
            $0.duration = duration
            $0.allowsImplicitAnimation = true
            contentView.scrollToVisible(frame)
        }
    }
}
