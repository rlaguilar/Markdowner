//
//  ItalicElement.swift
//  Markdowner
//
//  Created by Reynaldo Aguilar on 7/21/18.
//

import Foundation

public class ItalicElement: MarkdownElement {
    let symbolsColor: UIColor
    
    public init(symbolsColor: UIColor) {
        self.symbolsColor = symbolsColor
        
        let patterPlaceholder = "(?<!@)@(?![ @]).*?(?<![ @])@(?!@)"

        let pattern = ["\\*", "_"].map { patterPlaceholder.replacingOccurrences(of: "@", with: $0) }
            .joined(separator: "|")
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            fatalError()
        }
        
        super.init(regex: regex)
    }
    
    public override func styles(forMatch match: String) -> [MarkdownElement.Style] {
        let fontStyle = Style(
            attributeKey: .fontTraits,
            value: UIFontDescriptorSymbolicTraits.traitItalic,
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
    
    public override func applying(stylesConfiguration: StylesConfiguration) -> ItalicElement {
        return ItalicElement(symbolsColor: stylesConfiguration.symbolsColor)
    }
    
    public override func replacementRanges(forMatch match: String) -> [ReplacementRange] {
        let ranges = [NSRange(location: 0, length: 1), NSRange(location: match.count - 1, length: 1)]
        return ranges.map { ReplacementRange(range: $0, replacementValue: NSAttributedString()) }
    }
}
