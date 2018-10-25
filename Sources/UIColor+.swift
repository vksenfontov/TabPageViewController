//
//  UIColor+.swift
//  
//
//  Created by Masayoshi Ukida on 2018/09/19.
//  Copyright © 2018 Seesaa Inc. All rights reserved.
//

import UIKit

extension UIColor {
    @nonobjc class var darkBlueGrey: UIColor {
        
        return UIColor(red: 30.0 / 255.0, green: 45.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0)
        
    }
    
    @nonobjc class var tomato: UIColor {
        
        return UIColor(red: 239.0 / 255.0, green: 37.0 / 255.0, blue: 37.0 / 255.0, alpha: 1.0)
        
    }
    
    @nonobjc class var gray33: UIColor {
        
        return UIColor(white: 33.0 / 255.0, alpha: 1.0)
        
    }
    
    @nonobjc class var gray66: UIColor {
        
        return UIColor(white: 66.0 / 255.0, alpha: 1.0)
        
    }
    
    @nonobjc class var gray117: UIColor {
        
        return UIColor(white: 117.0 / 255.0, alpha: 1.0)
        
    }
    
    @nonobjc class var gray153: UIColor {
        
        return UIColor(white: 153.0 / 255.0, alpha: 1.0)
        
    }
    
    @nonobjc class var gray189: UIColor {
        
        return UIColor(white: 189.0 / 255.0, alpha: 1.0)
        
    }
    
    @nonobjc class var white: UIColor {
        
        return UIColor(white: 1.0, alpha: 1.0)
        
    }
    
    @nonobjc class var tealish: UIColor {
        
        return UIColor(red: 47.0 / 255.0, green: 168.0 / 255.0, blue: 179.0 / 255.0, alpha: 1.0)
        
    }
    
    @nonobjc public class var bubbleGumPink: UIColor {
        
        return UIColor(red: 241.0 / 255.0, green: 107.0 / 255.0, blue: 170.0 / 255.0, alpha: 1.0)
        
    }
    
    @nonobjc class var mediumPink: UIColor {
        
        return UIColor(red: 238.0 / 255.0, green: 91.0 / 255.0, blue: 160.0 / 255.0, alpha: 1.0)
        
    }
    
    @nonobjc class var lightPink: UIColor {
        
        return UIColor(red: 253.0 / 255.0, green: 240.0 / 255.0, blue: 246.0 / 255.0, alpha: 1.0)
        
    }
    
    @nonobjc class var mediumGreen: UIColor {
        
        return UIColor(red: 51.0 / 255.0, green: 153.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
        
    }
    
    @nonobjc class var barbiePink: UIColor {
        
        return UIColor(red: 232.0 / 255.0, green: 82.0 / 255.0, blue: 152.0 / 255.0, alpha: 1.0)
        
    }
    
    @nonobjc class var softBlue: UIColor {
        
        return UIColor(red: 102.0 / 255.0, green: 143.0 / 255.0, blue: 234.0 / 255.0, alpha: 1.0)
        
    }
    
    @nonobjc class var gold: UIColor {
        
        return UIColor(red: 235.0 / 255.0, green: 159.0 / 255.0, blue: 13.0 / 255.0, alpha: 1.0)
        
    }
    
    @nonobjc class var rosyPink: UIColor {
        
        return UIColor(red: 252.0 / 255.0, green: 99.0 / 255.0, blue: 137.0 / 255.0, alpha: 1.0)
        
    }
}

// MARK: - hex string
extension UIColor {
    @objc(initWithHex:)
    public convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (1, 1, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: 1.0)
    }
    
    
    func hex() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format:"#%06x", rgb)
    }
}
