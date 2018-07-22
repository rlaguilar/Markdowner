//
//  ItalicElement.swift
//  Markdowner
//
//  Created by Reynaldo Aguilar on 7/21/18.
//

import Foundation

public class ItalicElement: SimpleMarkdownElement {
    public init() {
        let asteriskPattern = "\\*.*?\\*"
        let underscorePattern = "_.*?_"
        let pattern = "\(asteriskPattern)|\(underscorePattern)"
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            fatalError()
        }
        
        super.init(
            regex: regex,
            attrs: [.font: UIFont.italicSystemFont(ofSize: ItalicElement.defaultFontSize)]
        )
    }
}
