//
//  InlineCodeElement.swift
//  Markdowner
//
//  Created by Reynaldo Aguilar on 7/26/18.
//

import Foundation

open class InlineCodeElement: MarkdownElement {
    let symbolsColor: UIColor
    let font: UIFont
    
    public init(symbolsColor: UIColor, font: UIFont) {
        self.symbolsColor = symbolsColor
        self.font = font
        
        let pattern = "(?<!`)`(?![ `]).*?(?<![ `])`(?!`)"
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            fatalError()
        }
        
        super.init(regex: regex)
    }
    
    open override func styles(forMatch match: String) -> [MarkdownElement.Style] {
        let fontStyle = Style(
            attributeKey: .font,
            value: font.dynamic(),
            startIndex: 0,
            length: match.count
        )
        
        let indicatorRanges = [
            NSRange(location: 0, length: 1),
            NSRange(location: match.count - 1, length: 1)
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
            font: font
        )
    }
    
    open override func replacementRanges(forMatch match: String) -> [ReplacementRange] {
        let ranges = [NSRange(location: 0, length: 1), NSRange(location: match.count - 1, length: 1)]
        return ranges.map { ReplacementRange(range: $0, replacementValue: NSAttributedString()) }
    }
}
