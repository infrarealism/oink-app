import Foundation

extension URL {
    var mime: String {
        guard
            let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as CFString, nil)
        else { return "" }
        let mime = uti.takeUnretainedValue() as String
        uti.release()
        return mime
    }
}
