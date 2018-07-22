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
}
