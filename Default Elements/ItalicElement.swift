//
//  ItalicElement.swift
//  Markdowner
//
//  Created by Reynaldo Aguilar on 7/21/18.
//

import Foundation

public class ItalicElement: SimpleMarkdownElement {
    public init() {
        let asteriskPattern = "(?<!\\*)\\*(?![ \\*]).*?(?<![ \\*])\\*(?!\\*)"
        let underscorePattern = "(?<!_)_(?![ _]).*?(?<![ _])_(?!_)"
        let pattern = "\(asteriskPattern)|\(underscorePattern)"
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            fatalError()
        }
        
        super.init(
            regex: regex,
            attrs: [.fontTraits: UIFontDescriptorSymbolicTraits.traitItalic]
        )
    }
    
    public override func replacementRanges(forMatch match: String) -> [ReplacementRange] {
        let ranges = [NSRange(location: 0, length: 1), NSRange(location: match.count - 1, length: 1)]
        return ranges.map { ReplacementRange(range: $0, replacementValue: NSAttributedString()) }
    }
}
