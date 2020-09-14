import AppKit

final class Launch: NSView {
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let control = Control.Blob(icon: "folder")
        control.target = self
        control.action = #selector(folder)
        addSubview(control)
        
        let label = Label(.systemFont(ofSize: 14, weight: .medium))
        label.stringValue = "Select your photos folder"
        addSubview(label)
        
        control.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        control.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        label.topAnchor.constraint(equalTo: control.bottomAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    @objc private func folder() {
        let browse = NSOpenPanel()
        browse.canChooseFiles = false
        browse.canChooseDirectories = true
        browse.prompt = "Select"
        browse.beginSheetModal(for: window!) {
            guard $0 == .OK else { return }
            (NSApp.windows.first as! Window).create(.init(browse.url!))
        }
    }
}
