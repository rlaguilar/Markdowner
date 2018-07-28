//
//  MarkdownParser.swift
//  Markdowner
//
//  Created by Reynaldo Aguilar on 7/21/18.
//

import Foundation

/// Object used to identify markdown attributes inside a text.
struct MarkdownParser {
    
    /// Markdown elements that will be used to process text values.
    let markdownElements: [MarkdownElement]
    
    /// Creates a new instance of a `MarkdownParser` supplying the markdown elements to use when
    /// processing text.
    ///
    /// - Parameter markdownElements: Elements to use to identify markdown attributes.
    init(markdownElements: [MarkdownElement]) {
        self.markdownElements = markdownElements
    }
    
    /// Computes a list of ranges that should be replaced from the given markdown string in order
    /// to display a ready version of the markdown for preview.
    ///
    /// - Parameter string: Markdown string to process.
    /// - Returns: List of ranges to be replaced from the string to create the markdown preview.
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
    
    /// Computes the list of markdown styles that correspond to the given string.
    ///
    /// - Parameters:
    ///   - string: String value to compute its styles
    ///   - range: Only styles inside this range will be retrieved.
    /// - Returns: List of markdown styles for the given parameters.
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
