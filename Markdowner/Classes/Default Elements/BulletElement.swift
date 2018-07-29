//
//  BulletElement.swift
//  Markdowner
//
//  Created by Reynaldo Aguilar on 7/21/18.
//

import Foundation

/// Type used to identify bullet elements.
/// - NOTE: - This is a example of a bullet.
open class BulletElement: MarkdownElement {
    public let symbolsColor: UIColor
    public let textColor: UIColor
    public let font: UIFont
    public let useDynamicType: Bool
    
    public init(symbolsColor: UIColor, textColor: UIColor, font: UIFont, useDynamicType: Bool) {
        self.symbolsColor = symbolsColor
        self.textColor = textColor
        self.font = font
        self.useDynamicType = useDynamicType
        
        let pattern = "^[-|*] .+"
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .anchorsMatchLines) else {
            fatalError()
        }
        
        super.init(regex: regex)
    }
    
    open override func styles(forMatch match: String) -> [MarkdownElement.Style] {
        let indicatorColorStyle = Style.init(
            attributeKey: .foregroundColor,
            value: symbolsColor,
            startIndex: 0,
            length: 1
        )
        
        return [indicatorColorStyle]
    }
    
    open override func replacementRanges(forMatch match: String) -> [ReplacementRange] {
        let range = NSRange(location: 0, length: 2)
        let font = useDynamicType ? self.font.dynamic() : self.font
        
        let replacementValue = NSAttributedString(
            string: "• ",
            attributes: [.foregroundColor: textColor, .font: font]
        )
        
        return [ReplacementRange(range: range, replacementValue: replacementValue)]
    }
    
    open override func applying(stylesConfiguration: StylesConfiguration) -> BulletElement {
        return BulletElement(
            symbolsColor: stylesConfiguration.symbolsColor,
            textColor: stylesConfiguration.textColor,
            font: stylesConfiguration.baseFont,
            useDynamicType: stylesConfiguration.useDynamicType
        )
    }
}
