//
//  LinkElement.swift
//  Markdowner
//
//  Created by Reynaldo Aguilar on 7/24/18.
//

import Foundation

open class LinkElement: MarkdownElement {
    let symbolsColor: UIColor
    let textFont: UIFont
    let linksColor: UIColor

    init(symbolsColor: UIColor, font: UIFont, linksColor: UIColor) {
        self.symbolsColor = symbolsColor
        self.textFont = font
        self.linksColor = linksColor
        
        // the url regex was taken from: https://stackoverflow.com/a/3809435/3385517
        // specifically from the link http://regexr.com/3e6m0 inside that question
        let urlRegexPattern = "(http(s)?:\\/\\/.)?(www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{2,256}\\.[a-z]{2,6}\\b([-a-zA-Z0-9@:%_\\+.~#?&//=]*)"
        
        let linkPattern = "(?<!\\[)(\\[)(?![ \\[]).+(?<![ \\]])(\\])(\\()\(urlRegexPattern)(\\))(?!\\))"
        
        guard let regex = try? NSRegularExpression(pattern: linkPattern, options: []) else {
            fatalError()
        }
        
        super.init(regex: regex)
    }
    
    open override func styles(forMatch match: String) -> [MarkdownElement.Style] {
        let ranges = symbolRanges(forMatch: match)
        
        let symbolsColor = ranges.map { range in
            Style(
                attributeKey: .foregroundColor,
                value: self.symbolsColor,
                startIndex: range.location,
                length: range.length
            )
        }
        
        let textRange = NSRange(
            location: ranges[0].location + 1,
            length: ranges[1].location - ranges[0].location - 1
        )
        
        let urlRange = NSRange(
            location: ranges[2].location + 1,
            length: ranges[3].location - ranges[2].location - 1
        )
        
        let textStyles = [
            MarkdownElement.Style(
                attributeKey: .link,
                value: (match as NSString).substring(with: urlRange),
                startIndex: textRange.location,
                length: textRange.length
            ),
            MarkdownElement.Style(
                attributeKey: .foregroundColor,
                value: linksColor,
                startIndex: textRange.location,
                length: textRange.length
            )
        ]
        
        return symbolsColor + textStyles
    }
    
    open override func replacementRanges(forMatch match: String) -> [ReplacementRange] {
        let symbolRanges = self.symbolRanges(forMatch: match)
        
        let urlPortionRange = NSRange(
            location: symbolRanges[2].location,
            length: match.count - symbolRanges[2].location
        )
        
        return [symbolRanges[0], symbolRanges[1], urlPortionRange].map {
            ReplacementRange(range: $0, replacementValue: NSAttributedString())
        }
    }
    
    open override func applying(stylesConfiguration: StylesConfiguration) -> LinkElement {
        return LinkElement(
            symbolsColor: stylesConfiguration.symbolsColor,
            font: stylesConfiguration.baseFont,
            linksColor: linksColor
        )
    }
    
    private func symbolRanges(forMatch match: String) -> [NSRange] {
        let fullRange = NSRange(location: 0, length: match.count)
        
        guard let regexMatch = regex.matches(in: match, options: [], range: fullRange).first else {
            fatalError("ERROR: Unable to find a match for the given ouput")
        }
        
        let lastRange = regexMatch.range(at: regexMatch.numberOfRanges - 1)
        let ranges = (1...3).map { regexMatch.range(at: $0) } + [lastRange]
        return ranges
    }
}
