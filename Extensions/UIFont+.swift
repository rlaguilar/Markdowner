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
            print("WARNING: Unable to resolve descriptor \(traits) for font: \(fontName)")
            print("Will use current font instead")
            return self
        }
    }
}
