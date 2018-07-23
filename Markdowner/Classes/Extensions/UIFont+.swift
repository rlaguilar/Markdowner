//
//  UIFont+.swift
//  Markdowner
//
//  Created by Reynaldo Aguilar on 7/22/18.
//

import Foundation

extension UIFont {
    func adding(traits: UIFontDescriptorSymbolicTraits) -> UIFont {
        let newTraits: UIFontDescriptorSymbolicTraits = [fontDescriptor.symbolicTraits, traits]
        if let newFontDescriptor = fontDescriptor.withSymbolicTraits(newTraits) {
            return UIFont(descriptor: newFontDescriptor, size: pointSize)
        }
        else {
            NSLog("WARNING: Unable to resolve descriptor \(traits) for font: \(fontName)")
            NSLog("Will use current font instead")
            return self
        }
    }

    open func dynamic(withSize size: CGFloat = 0, forTextStyle textStyle: UIFontTextStyle = .body) -> UIFont {
        let defaultSize = size == 0 ? pointSize : size
        let newFont = withSize(defaultSize)
        
        if #available(iOS 11.0, *) {
            let metrics = UIFontMetrics(forTextStyle: textStyle)
            return metrics.scaledFont(for: newFont)
        } else {
            NSLog("Markdowner WARNING: iOS 11 not available. Won't compute dynamic font")
            return newFont
        }
    }
}
