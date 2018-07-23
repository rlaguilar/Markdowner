//
//  BoldElement.swift
//  Markdowner
//
//  Created by Reynaldo Aguilar on 7/21/18.
//

import Foundation

public class BoldElement: MarkdownElement {
    let symbolsColor: UIColor
    
    public init(symbolsColor: UIColor) {
        self.symbolsColor = symbolsColor
        let pattern = "(?<!\\*)\\*\\*(?![ \\*]).*?(?<![ \\*])\\*\\*(?!\\*)"
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            fatalError()
        }
    
        super.init(regex: regex)
    }
    
    public override func styles(forMatch match: String) -> [MarkdownElement.Style] {
        let fontStyle = Style(
            attributeKey: .fontTraits,
            value: UIFontDescriptorSymbolicTraits.traitBold,
            startIndex: 0,
            length: match.count
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
        
        return foregroundStyles + [fontStyle]
    }
    
    public override func applying(stylesConfiguration: StylesConfiguration) -> BoldElement {
        return BoldElement(symbolsColor: stylesConfiguration.symbolsColor)
    }
    
    public override func replacementRanges(forMatch match: String) -> [ReplacementRange] {
        let ranges = [NSRange(location: 0, length: 2), NSRange(location: match.count - 2, length: 2)]
        return ranges.map { ReplacementRange(range: $0, replacementValue: NSAttributedString()) }
    }
}
