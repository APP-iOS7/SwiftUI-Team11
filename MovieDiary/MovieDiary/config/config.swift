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
        case .heroSectionBottomPadding: return 25
        case .heroSectionHorizonSpacing: return 15
        case .heroSectionVerticalSpacing: return 10
        case .heroSectionTitle: return 24
        case .heroSectionSubTitle: return 18
        case .buttonFontSize: return 18
        case .reviewTitle: return 15
        case .reviewContent: return 13
        case .detailFontSize: return 10
        }
    }
}

enum ColorConfig {
    case heroSectionTitle
    case commonGrey
    case commonYello
    
    func value() -> Color {
        switch self {
        case .heroSectionTitle: return Color(.white)
        case .commonGrey: return Color(hex : "#8E8E8E")
        case .commonYello: return Color(hex : "#FFF049")
        }
    }
}
