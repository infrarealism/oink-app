import Foundation

extension Photo {
    static let thumb = DispatchQueue(label: "", qos: .utility)
    static let image = DispatchQueue(label: "", qos: .utility)
}
