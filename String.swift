import Foundation

extension String {
    static func key(_ value: Self) -> Self {
        NSLocalizedString(value, comment: "")
    }
}
