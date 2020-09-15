import AppKit

extension CALayer {
    func bringFront(_ layer: CALayer) {
        layer.removeFromSuperlayer()
        addSublayer(layer)
    }
}
