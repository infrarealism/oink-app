import Foundation
import Combine

final class Photo {
    var image: CGImage? {
        render(size: min(1024, min(size.width, size.height)))
    }
    
    let url: URL
    let date: Date
    let iso: Int?
    let size: CGSize
    let bytes: Int
    private let _thumb = CurrentValueSubject<CGImage?, Never>(nil)
    
    init(_ url: URL, date: Date, iso: Int?, size: CGSize, bytes: Int) {
        self.url = url
        self.date = date
        self.iso = iso
        self.size = size
        self.bytes = bytes
    }
    
    var thumb: CurrentValueSubject<CGImage?, Never> {
        if _thumb.value == nil {
            DispatchQueue.global(qos: .utility).async { [weak self] in
                self?._thumb.value = self?.render(size: 100)
            }
        }
        return _thumb
    }
    
    func export(_ size: CGSize) -> Data? {
        let data = NSMutableData()
        guard
            let image = render(size: max(size.width, size.height)),
            let destination = CGImageDestinationCreateWithData(data as CFMutableData, kUTTypeJPEG, 1, nil)
        else { return nil }
        CGImageDestinationAddImage(destination, image, nil)
        CGImageDestinationFinalize(destination)
        return data as Data
    }
    
    private func render(size: CGFloat) -> CGImage? {
        CGImageSourceCreateThumbnailAtIndex(CGImageSourceCreateWithURL(url as CFURL, [kCGImageSourceShouldCache : false] as CFDictionary)!, 0,
                                            [kCGImageSourceCreateThumbnailFromImageAlways : true,
                                             kCGImageSourceThumbnailMaxPixelSize : size] as CFDictionary)
    }
}
