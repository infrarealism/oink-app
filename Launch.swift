import AppKit

final class Launch: NSView {
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let image = NSImageView(image: NSImage(named: "oink_folder")!)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.imageScaling = .scaleNone
        addSubview(image)
        
        let control = Control.Blob(icon: "folder")
        control.target = NSApp.windows.first
        control.action = #selector(Window.folder)
        addSubview(control)
        
        let label = Label(.systemFont(ofSize: 14, weight: .medium))
        label.stringValue = "Select your photos folder"
        addSubview(label)
        
        image.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        image.bottomAnchor.constraint(equalTo: control.topAnchor, constant: -20).isActive = true
        
        control.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        control.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        label.topAnchor.constraint(equalTo: control.bottomAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
}
