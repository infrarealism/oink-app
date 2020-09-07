import Foundation

struct Photo {
    let url: URL
    let date: Date
    let iso: Int
    
    /*
     
     let source = CGImageSourceCreateWithURL(url as CFURL, [kCGImageSourceShouldCache : false] as CFDictionary)
     guard
         let dictionary = CGImageSourceCopyPropertiesAtIndex(source!, 0, nil) as? [String: AnyObject],
         let exif = dictionary["{Exif}"]
     else { return }
     
     let image = NSImage(cgImage: CGImageSourceCreateThumbnailAtIndex(source!, 0, [
     kCGImageSourceCreateThumbnailFromImageAlways : false,
     kCGImageSourceCreateThumbnailFromImageIfAbsent : false,
     kCGImageSourceThumbnailMaxPixelSize : 900] as CFDictionary)!, size: .init(width: 900, height: 900))
     */
}
