//
//  MarkdownElement.swift
//  Markdowner
//
//  Created by Reynaldo Aguilar on 7/21/18.
//

import Foundation

public class MarkdownElement {
    public let regex: NSRegularExpression
    
    public init(regex: NSRegularExpression) {
        self.regex = regex
    }
    
    open func styles(forMatch match: String) -> [Style] {
        return []
    }
    
    open func applying(stylesConfiguration: StylesConfiguration) -> Self {
        return self
    }
    
    open func replacementRanges(forMatch match: String) -> [ReplacementRange] {
        return []
    }
    
    public struct Style {
        let attributeKey: NSAttributedStringKey
        let value: Any
        let startIndex: Int
        let length: Int
        
        var range: NSRange {
            return NSRange(location: startIndex, length: length)
        }
    }
}

public class SimpleMarkdownElement: MarkdownElement {
    private let attrs: [NSAttributedStringKey: Any]
    
    public init(regex: NSRegularExpression, attrs: [NSAttributedStringKey: Any]) {
        self.attrs = attrs
        super.init(regex: regex)
    }
    
    open override func styles(forMatch match: String) -> [MarkdownElement.Style] {
        return attrs.map { (key, value)  in
            Style(
                attributeKey: key,
                value: value,
                startIndex: 0,
                length: match.count
            )
        }
    }
}
