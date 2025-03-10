import Foundation
import SwiftUICore


let API_URL = "https://6cff-49-246-51-78.ngrok-free.app"

extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
                
        let scanner = Scanner(string: hexSanitized)
        var hexValue: UInt64 = 0
        scanner.scanHexInt64(&hexValue)
        
        let red = Double((hexValue & 0xFF0000) >> 16) / 255.0
        let green = Double((hexValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(hexValue & 0x0000FF) / 255.0
        
        self.init(red:red, green:green, blue:blue)
    }
}


enum PaddingConfig {
    //common
    case sidePadding
    //posterItemDetailView
     //spacing
    case heroSectionBottomPadding
    case heroSectionHorizonSpacing
    case heroSectionVerticalSpacing
     //FontSize
    case heroSectionTitle
    case heroSectionSubTitle
    case buttonFontSize
    case reviewTitle
    case reviewContent
    case detailFontSize
    
    func value() -> CGFloat {
        switch self {
        case .sidePadding: return 16
        case .heroSectionBottomPadding: return 10
        case .heroSectionHorizonSpacing: return 15
        case .heroSectionVerticalSpacing: return 10
        case .heroSectionTitle: return 24
        case .heroSectionSubTitle: return 18
        case .buttonFontSize: return 18
        case .reviewTitle: return 16
        case .reviewContent: return 15
        case .detailFontSize: return 13
        }
    }
}

enum ColorConfig {
    case heroSectionTitle
    case commonGrey
    case commonYello
    case primaryColor
    case effectColor
    case secondColor
    
    func value() -> Color {
        switch self {
        case .heroSectionTitle: return Color(.white)
        case .commonGrey: return Color(hex : "#D9D9D9")
        case .commonYello: return Color(hex : "#FFF049")
        case .effectColor: return Color(hex : "#A31D1D")
        case .primaryColor: return Color(hex : "#FEF9E1")
        case .secondColor: return Color(hex : "#E5D0AC")
        }
    }
}
