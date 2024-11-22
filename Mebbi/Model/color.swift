import SwiftUI

class ColorSelection: ObservableObject {
    @Published var corSelecionada: String?
    let coresRGB: [String] = [
        "255, 255, 255", "235, 235, 235", "214, 214, 214", "194, 194, 194", "173, 173, 173",
        "153, 153, 153", "133, 133, 133", "112, 112, 112", "92, 92, 92", "71, 71, 71",
        "51, 51, 51", "0, 0, 0", "0, 55, 75", "0, 29, 87", "18, 5, 59",
        "46, 5, 61", "60, 7, 27", "92, 7, 2", "89, 28, 0", "88, 51, 0",
        "86, 62, 0", "101, 97, 0", "80, 85, 5", "38, 61, 15", "1, 77, 101",
        "1, 47, 124", "26, 10, 82", "69, 12, 89", "84, 16, 41", "130, 17, 0",
        "123, 41, 1", "122, 74, 0", "120, 88, 1", "141, 134, 2", "111, 119, 10",
        "56, 87, 27", "1, 109, 143", "1, 65, 170", "45, 9, 119", "96, 24, 124",
        "121, 26, 60", "181, 26, 0", "173, 62, 0", "169, 105, 0", "165, 123, 1",
        "196, 188, 1", "155, 165, 14", "78, 121, 39", "1, 140, 181", "1, 86, 215",
        "56, 26, 148", "122, 34, 157", "153, 36, 80", "226, 37, 0", "218, 82, 0",
        "211, 131, 2", "210, 157, 1", "243, 236, 0", "196, 208, 23", "102, 157, 53",
        "0, 161, 217", "1, 97, 254", "77, 34, 178", "152, 43, 188", "184, 45, 92",
        "253, 65, 20", "254, 106, 0", "253, 171, 0", "252, 199, 0", "255, 251, 64",
        "216, 235, 55", "118, 186, 63", "2, 199, 252", "59, 135, 254", "94, 48, 236",
        "190, 56, 243", "229, 59, 122", "255, 98, 81", "254, 134, 73", "255, 180, 63",
        "252, 204, 62", "254, 247, 107", "228, 239, 101", "151, 211, 95", "83, 214, 252",
        "116, 167, 255", "133, 79, 253", "210, 87, 255", "239, 114, 158", "254, 140, 130",
        "254, 165, 125", "254, 199, 119", "254, 216, 118", "254, 249, 147", "234, 242, 143",
        "178, 221, 139", "147, 227, 254", "167, 198, 255", "177, 140, 254", "225, 146, 255",
        "244, 164, 193", "254, 181, 175", "254, 197, 170", "254, 216, 169", "253, 229, 169",
        "254, 251, 184", "242, 247, 183", "205, 232, 181"
    ]
    
    func colorFromRGBString(_ rgbString: String) -> Color {
        let rgb = rgbString.split(separator: ",").map { Double($0.trimmingCharacters(in: .whitespaces)) ?? 0.0 }
        guard rgb.count == 3 else { return Color.clear }
        return Color(red: rgb[0] / 255, green: rgb[1] / 255, blue: rgb[2] / 255)
    }
}


extension UIColor {
    convenience init?(hex: String) {
        var rgb: UInt64 = 0
        var alpha: CGFloat = 1.0
        let scanner = Scanner(string: hex)
        
        if hex.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        
        guard scanner.scanHexInt64(&rgb) else {
            return nil
        }
        
        let red = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let green = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let blue = CGFloat(rgb & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    func toColor() -> Color {
        return Color(self)
    }
}

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        let scanner = Scanner(string: hexSanitized)
        scanner.scanLocation = 0
        
        if scanner.scanHexInt64(&rgb) {
            let red = Double((rgb >> 16) & 0xFF) / 255.0
            let green = Double((rgb >> 8) & 0xFF) / 255.0
            let blue = Double(rgb & 0xFF) / 255.0
            
            self.init(red: red, green: green, blue: blue)
        } else {
            return nil
        }
    }
}
