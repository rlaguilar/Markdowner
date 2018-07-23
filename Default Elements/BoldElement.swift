//
//  BoldElement.swift
//  Markdowner
//
//  Created by Reynaldo Aguilar on 7/21/18.
//

import Foundation

public class BoldElement: SimpleMarkdownElement {
    public init() {
        let pattern = "(?<!\\*)\\*\\*(?![ \\*]).*?(?<![ \\*])\\*\\*(?!\\*)"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            fatalError()
        }
    
        super.init(
            regex: regex,
            attrs: [.fontTraits: UIFontDescriptorSymbolicTraits.traitBold]
        )
    }
    
    public override func replacementRanges(forMatch match: String) -> [ReplacementRange] {
        let ranges = [NSRange(location: 0, length: 2), NSRange(location: match.count - 2, length: 2)]
        return ranges.map { ReplacementRange(range: $0, replacementValue: NSAttributedString()) }
    }
}
