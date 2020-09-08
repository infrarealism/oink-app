import Foundation

final class Photo {
    var thumb: CGImage? {
        if _thumb == nil {
            _thumb = render(size: 200)
        }
        return _thumb
    }
    
    var image: CGImage? {
        render(size: min(1024, min(size.width, size.height)))
    }
    
    let url: URL
    let date: Date
    let iso: Int
    let size: CGSize
    let bytes: Int
    private var _thumb: CGImage?
    
    init(_ url: URL, date: Date, iso: Int, size: CGSize, bytes: Int) {
        self.url = url
        self.date = date
        self.iso = iso
        self.size = size
        self.bytes = bytes
    }
    
    private func render(size: CGFloat) -> CGImage? {
        CGImageSourceCreateThumbnailAtIndex(CGImageSourceCreateWithURL(url as CFURL, [kCGImageSourceShouldCache : false] as CFDictionary)!, 0,
                                            [kCGImageSourceCreateThumbnailFromImageAlways : false,
                                             kCGImageSourceCreateThumbnailFromImageIfAbsent : false,
                                             kCGImageSourceThumbnailMaxPixelSize : size] as CFDictionary)
    }
}
