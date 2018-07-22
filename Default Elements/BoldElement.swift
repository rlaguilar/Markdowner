//
//  BoldElement.swift
//  Markdowner
//
//  Created by Reynaldo Aguilar on 7/21/18.
//

import Foundation

public class BoldElement: SimpleMarkdownElement {
    public init() {
        guard let regex = try? NSRegularExpression(pattern: "\\*\\*.+?\\*\\*", options: []) else {
            fatalError()
        }
        
        super.init(
            regex: regex,
            attrs: [.font: UIFont.boldSystemFont(ofSize: BoldElement.defaultFontSize)]
        )
    }
}
