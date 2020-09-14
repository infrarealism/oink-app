import AppKit

extension URL {
    var items: [Photo] {
        var items = [Photo]()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        
        FileManager.default.enumerator(at: self, includingPropertiesForKeys: nil, options:
            [.producesRelativePathURLs, .skipsHiddenFiles, .skipsPackageDescendants])?.forEach {
                guard
                    let url = $0 as? URL,
                    url.image,
                    let bytes = (try? FileManager.default.attributesOfItem(atPath: url.path)).flatMap({ $0[.size] as? Int })
                else { return }
                
                var date: Date?
                var iso: Int?
                
                let source = CGImageSourceCreateWithURL(url as CFURL, [kCGImageSourceShouldCache : false] as CFDictionary)
                guard
                    let dictionary = CGImageSourceCopyPropertiesAtIndex(source!, 0, nil) as? [String : AnyObject],
                    let width = dictionary["PixelWidth"] as? Int,
                    let height = dictionary["PixelHeight"] as? Int
                else { return }
                
                if let exif = dictionary["{Exif}"] as? [String : AnyObject] {
                    if let rawDate = exif["DateTimeOriginal"] as? String {
                        date = formatter.date(from: rawDate)
                    }
                    if let isos = exif["ISOSpeedRatings"] as? [Int] {
                        iso = isos.first
                    }
                }
                
                if date == nil {
                    date = (try? FileManager.default.attributesOfItem(atPath: url.path)).flatMap({ $0[.creationDate] as? Date })
                }
                
                if let date = date {
                    items.append(.init(url, date: date, iso: iso, size: .init(width: width, height: height), bytes: bytes))
                }
        }
        return items.sorted { $0.date > $1.date }
    }
    
    private var image: Bool {
        NSImage.imageTypes.contains(mime)
    }
    
    private var mime: String {
        guard
            let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as CFString, nil)
        else { return "" }
        let mime = uti.takeUnretainedValue() as String
        uti.release()
        return mime
    }
}
