//
//  InlineCodeElement.swift
//  Markdowner
//
//  Created by Reynaldo Aguilar on 7/26/18.
//

import Foundation

/// Type used to identify `inline code blocks`.
open class InlineCodeElement: MarkdownElement {
    public let symbolsColor: UIColor
    public let font: UIFont
    public let useDynamicType: Bool
    
    public init(symbolsColor: UIColor, font: UIFont, useDynamicType: Bool) {
        self.symbolsColor = symbolsColor
        self.font = font
        self.useDynamicType = useDynamicType
        
        let pattern = "(?<!`)`(?![ `]).*?(?<![ `])`(?!`)"
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            fatalError()
        }
        
        super.init(regex: regex)
    }
    
    open override func styles(forMatch match: NSString) -> [MarkdownElement.Style] {
        let fontStyle = Style(
            attributeKey: .font,
            value: useDynamicType ? font.dynamic() : font,
            startIndex: 0,
            length: match.length
        )
        
        let indicatorRanges = [
            NSRange(location: 0, length: 1),
            NSRange(location: match.length - 1, length: 1)
        ]
        
        let foregroundStyles = indicatorRanges.map {
            Style(
                attributeKey: .foregroundColor,
                value: symbolsColor,
                startIndex: $0.location,
                length: $0.length
            )
        }
        
        return foregroundStyles + [fontStyle]
    }
    
    open override func applying(stylesConfiguration: StylesConfiguration) -> InlineCodeElement {
        return InlineCodeElement(
            symbolsColor: stylesConfiguration.symbolsColor,
            font: font,
            useDynamicType: stylesConfiguration.useDynamicType
        )
    }
    
    open override func replacementRanges(forMatch match: NSString) -> [ReplacementRange] {
        let ranges = [NSRange(location: 0, length: 1), NSRange(location: match.length - 1, length: 1)]
        return ranges.map { ReplacementRange(range: $0, replacementValue: NSAttributedString()) }
    }
}
