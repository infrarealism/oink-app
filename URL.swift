import Foundation

extension URL {
    var mime: String {
        guard
            let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as CFString, nil)
        else { return "" }
        let mime = uti.takeRetainedValue() as String
        uti.release()
        return mime
    }
}
