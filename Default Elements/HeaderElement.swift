//
//  HeaderElement.swift
//  Markdowner
//
//  Created by Reynaldo Aguilar on 7/21/18.
//

import Foundation

public class HeaderElement: MarkdownElement {
    var foregroundColor = UIColor.red
    
    init() {
        guard let regex = try? NSRegularExpression(pattern: "^(#{1,6}) .+", options: .anchorsMatchLines) else {
            fatalError()
        }
        
        super.init(regex: regex)
    }
    
    public override func styles(forMatch match: String) -> [MarkdownElement.Style] {
        let fullRange = NSRange(location: 0, length: match.count)
        
        guard let regexMatch = regex.matches(in: match, options: [], range: fullRange).first else {
            print("ERROR: Unable to find match for the given input")
            return []
        }
        
        let hashtagCount = regexMatch.range(at: 1).length
        
        guard let level = Level(rawValue: hashtagCount) else {
            fatalError("Unable to retrive header level from match")
        }
        
        let fontStyle = Style(
            attributeKey: .font,
            value: UIFont.boldSystemFont(ofSize: level.fontSize),
            startIndex: 0,
            length: match.count
        )
        
        let foregroundStyle = Style(
            attributeKey: .foregroundColor,
            value: foregroundColor,
            startIndex: 0,
            length: hashtagCount
        )
        
        return [fontStyle, foregroundStyle]
    }
    
    enum Level: Int {
        case h1 = 1, h2, h3, h4, h5, h6
        
        var fontSize: CGFloat {
            return HeaderElement.defaultFontSize + 7 - CGFloat(self.rawValue)
        }
    }
}
