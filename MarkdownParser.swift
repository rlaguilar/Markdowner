//
//  MarkdownParser.swift
//  Markdowner
//
//  Created by Reynaldo Aguilar on 7/21/18.
//

import Foundation

struct MarkdownParser {
    let markdownElements: [MarkdownElement]
    
    init(markdownElements: [MarkdownElement]) {
        self.markdownElements = markdownElements
    }
    
    func replacementRanges(forString string: String) -> [ReplacementRange] {
        let fullRange = NSRange(location: 0, length: string.count)
        var ranges: [ReplacementRange] = []
        
        iterateMatches(forString: string, atRange: fullRange) { (element, range, match) in
            let elementRanges = element.replacementRanges(forMatch: match).map { replacement -> ReplacementRange in
                let newRange = NSRange(
                    location: replacement.range.location + range.location,
                    length: replacement.range.length
                )
                
                return ReplacementRange(
                    range: newRange,
                    replacementValue: replacement.replacementValue
                )
            }
            
            ranges.append(contentsOf: elementRanges)
        }

        return ranges.sorted(by: { $0.range.location < $1.range.location })
    }
    
    func styles(forString string: String, atRange range: NSRange) -> [MarkdownElement.Style] {
        var styles: [MarkdownElement.Style] = []
        
        iterateMatches(forString: string, atRange: range) { (element, matchedRange, match) in
            let elementStyles = element.styles(forMatch: match).map { style in
                MarkdownElement.Style(
                    attributeKey: style.attributeKey,
                    value: style.value,
                    startIndex: style.startIndex + matchedRange.location,
                    length: style.length
                )
            }
            
            styles.append(contentsOf: elementStyles)
        }
        
        return styles.sorted(by: { $0.startIndex < $1.startIndex })
    }
    
    private func iterateMatches(forString string: String, atRange range: NSRange, block: (MarkdownElement, NSRange, String) -> Void) {
        markdownElements.forEach { element in
            element.regex.matches(in: string, options: [], range: range).forEach { result in
                let matchedRange = result.range
                let startIndex = string.index(string.startIndex, offsetBy: matchedRange.location)
                let endIndex = string.index(startIndex, offsetBy: matchedRange.length)
                let matchedStr = string[startIndex ..< endIndex]
                let match = String(matchedStr)
                block(element, matchedRange, match)
            }
        }
    }
}
