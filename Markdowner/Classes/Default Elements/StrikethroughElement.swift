//
//  StrikethroughElement.swift
//  Markdowner
//
//  Created by Reynaldo Aguilar on 7/24/18.
//

import Foundation

/// Type used to identify ~strike thorugh elements~.
open class StrikethroughElement: MarkdownElement {
    let symbolsColor: UIColor
    
    public init(symbolsColor: UIColor) {
        self.symbolsColor = symbolsColor
        let pattern = "(?<!~)~~(?![ ~]).*?(?<![ ~])~~(?!~)"
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            fatalError()
        }
        
        super.init(regex: regex)
    }
    
    open override func styles(forMatch match: String) -> [MarkdownElement.Style] {
        let strikeStyle = Style(
            attributeKey: .strikethroughStyle,
            value: NSUnderlineStyle.styleSingle.rawValue,
            startIndex: 2,
            length: match.count - 4
        )
        
        let indicatorRanges = [
            NSRange(location: 0, length: 2),
            NSRange(location: match.count - 2, length: 2)
        ]
        
        let foregroundStyles = indicatorRanges.map {
            Style(
                attributeKey: .foregroundColor,
                value: symbolsColor,
                startIndex: $0.location,
                length: $0.length
            )
        }
        
        return foregroundStyles + [strikeStyle]
    }
    
    open override func applying(stylesConfiguration: StylesConfiguration) -> StrikethroughElement {
        return StrikethroughElement(symbolsColor: stylesConfiguration.symbolsColor)
    }
    
    open override func replacementRanges(forMatch match: String) -> [ReplacementRange] {
        let ranges = [NSRange(location: 0, length: 2), NSRange(location: match.count - 2, length: 2)]
        return ranges.map { ReplacementRange(range: $0, replacementValue: NSAttributedString()) }
    }
}
