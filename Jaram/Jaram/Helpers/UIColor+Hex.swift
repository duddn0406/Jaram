import UIKit

extension UIColor {
    func toHexString() -> String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }

    convenience init?(hex: String) {
        var hex = hex
        if hex.hasPrefix("#") { hex.removeFirst() }
        guard let int = Int(hex, radix: 16) else { return nil }
        let r = CGFloat((int >> 16) & 0xff) / 255
        let g = CGFloat((int >> 8) & 0xff) / 255
        let b = CGFloat(int & 0xff) / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}
