//
//  MarkdownParser.swift
//  Markdowner
//
//  Created by Reynaldo Aguilar on 7/21/18.
//

import Foundation

struct MarkdownParser {
    private let markdownElements: [MarkdownElement]
    
    init(markdownElements: [MarkdownElement]) {
        self.markdownElements = markdownElements
    }
    
    func styles(forString string: String, atRange range: NSRange) -> [MarkdownElement.Style] {
        let styles = markdownElements.flatMap { element -> [MarkdownElement.Style] in
            element.regex.matches(in: string, options: [], range: range).flatMap { result -> [MarkdownElement.Style] in
                let matchedRange = result.range
                let startIndex = string.index(string.startIndex, offsetBy: matchedRange.location)
                let endIndex = string.index(startIndex, offsetBy: matchedRange.length)
                let matchedStr = string[startIndex ..< endIndex]
                let stylesForMatch = element.styles(forMatch: String(matchedStr))
                
                return stylesForMatch.map { style in
                    MarkdownElement.Style(
                        attributeKey: style.attributeKey,
                        value: style.value,
                        startIndex: style.startIndex + matchedRange.location,
                        length: style.length
                    )
                }
            }
        }
        
        return styles
    }
}
