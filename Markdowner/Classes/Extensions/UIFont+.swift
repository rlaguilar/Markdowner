//
//  UIFont+.swift
//  Markdowner
//
//  Created by Reynaldo Aguilar on 7/22/18.
//

import Foundation

extension UIFont {
    
    /// Returns a new font that is the combination of the current font with a new symbolic trait.
    /// If the current font doesn't support the given traits then `self` is returned.
    ///
    /// - Parameter traits: New traits to add to the current font.
    /// - Returns: A new font object that, if possible, contains the new traits.
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

    /// Computes a variation of the current font that supports dymamic font size.
    ///
    /// - Parameters:
    ///   - size: Base size to use for the new font. If this value is equal to `0` then the size of
    ///     the current font will be used.
    ///   - textStyle: Text style that will be used as the base for the new font. Default value is
    ///     `UIFontTextStyle.body`
    /// - Returns: A new font based in `self` that supports dynamic font size.
    /// - NOTE: This function only computes a dynamic font in iOS 11 and later. In prior versions it
    ///   just returns `self`.
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
