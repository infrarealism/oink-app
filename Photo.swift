import Foundation

struct Photo {
    let url: URL
    let date: Date
    let iso: Int
    private var _image: CGImage?
    
    init(_ url: URL, date: Date, iso: Int) {
        self.url = url
        self.date = date
        self.iso = iso
    }
    
    mutating func image() -> CGImage? {
        if _image == nil {
            let source = CGImageSourceCreateWithURL(url as CFURL, [kCGImageSourceShouldCache : false] as CFDictionary)
            _image = CGImageSourceCreateThumbnailAtIndex(source!, 0, [
                kCGImageSourceCreateThumbnailFromImageAlways : false,
                kCGImageSourceCreateThumbnailFromImageIfAbsent : false,
                kCGImageSourceThumbnailMaxPixelSize : 200] as CFDictionary)
        }
        return _image
    }
}
