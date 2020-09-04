import AppKit

final class Launch: NSView {
    private weak var session: Session!
    
    required init?(coder: NSCoder) { nil }
    init(session: Session) {
        self.session = session
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let control = Control.Blob(icon: "folder")
        control.target = self
        control.action = #selector(folder)
        addSubview(control)
        
        let label = Label("Select your photos folder", .systemFont(ofSize: 14, weight: .medium))
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
        browse.beginSheetModal(for: window!) { [weak self] in
            guard $0 == .OK else { return }
            self?.session.update(.init(browse.url!))
        }
    }
}
