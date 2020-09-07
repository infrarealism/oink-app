import Foundation

final class Photo {
    var thumb: CGImage? {
        if _thumb == nil {
            _thumb = render(size: 200)
        }
        return _thumb
    }
    
    var image: CGImage? {
        if _image == nil {
            _image = render(size: 1000)
        }
        return _image
    }
    
    let url: URL
    let date: Date
    let iso: Int
    private var _thumb: CGImage?
    private var _image: CGImage?
    
    init(_ url: URL, date: Date, iso: Int) {
        self.url = url
        self.date = date
        self.iso = iso
    }
    
    private func render(size: CGFloat) -> CGImage? {
        CGImageSourceCreateThumbnailAtIndex(CGImageSourceCreateWithURL(url as CFURL, [kCGImageSourceShouldCache : false] as CFDictionary)!, 0,
                                            [kCGImageSourceCreateThumbnailFromImageAlways : false,
                                             kCGImageSourceCreateThumbnailFromImageIfAbsent : false,
                                             kCGImageSourceThumbnailMaxPixelSize : size] as CFDictionary)
    }
}
