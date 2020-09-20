import Foundation

extension Photo {
    static let thumb = Set([DispatchQueue(label: "", qos: .utility), DispatchQueue(label: "", qos: .utility), DispatchQueue(label: "", qos: .utility)])
    static let image = DispatchQueue(label: "", qos: .utility)
}
