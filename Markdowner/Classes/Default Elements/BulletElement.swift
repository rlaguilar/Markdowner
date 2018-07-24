//
//  BulletElement.swift
//  Markdowner
//
//  Created by Reynaldo Aguilar on 7/21/18.
//

import Foundation

open class BulletElement: MarkdownElement {
    let symbolsColor: UIColor
    let textColor: UIColor
    let font: UIFont
    
    public init(symbolsColor: UIColor, textColor: UIColor, font: UIFont) {
        self.symbolsColor = symbolsColor
        self.textColor = textColor
        self.font = font
        
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
        let replacementValue = NSAttributedString(
            string: "• ",
            attributes: [.foregroundColor: textColor, .font: font.dynamic()]
        )
        
        return [ReplacementRange(range: range, replacementValue: replacementValue)]
    }
    
    open override func applying(stylesConfiguration: StylesConfiguration) -> BulletElement {
        return BulletElement(
            symbolsColor: stylesConfiguration.symbolsColor,
            textColor: stylesConfiguration.textColor,
            font: stylesConfiguration.baseFont
        )
    }
}
