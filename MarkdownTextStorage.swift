//
//  MarkdownTextStorage.swift
//  Markdowner
//
//  Created by Reynaldo Aguilar on 7/21/18.
//

import Foundation

public class MarkdownTextStorage: NSTextStorage {
    private let backingString = NSMutableAttributedString()
    
    private lazy var markdownParser: MarkdownParser = {
        let elements = [ItalicElement(), BoldElement(), BulletElement(), HeaderElement()]
        let parser = MarkdownParser(markdownElements: elements)
        return parser
    }()
    
    private let defaultAttributes: [NSAttributedStringKey: Any] = {
        return [
            .font: UIFont.systemFont(ofSize: MarkdownElement.defaultFontSize),
            .foregroundColor: UIColor.black
        ]
    }()
    
    override public var string: String {
        return backingString.string
    }
    
    override public func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedStringKey : Any] {
        return backingString.attributes(at: location, effectiveRange: range)
    }
    
    override public func replaceCharacters(in range: NSRange, with str: String) {
        backingString.replaceCharacters(in: range, with: str)
        self.edited(.editedCharacters, range: range, changeInLength: str.count - range.length)
    }
    
    override public func setAttributes(_ attrs: [NSAttributedStringKey : Any]?, range: NSRange) {
        backingString.setAttributes(attrs, range: range)
        self.edited(.editedAttributes, range: range, changeInLength: 0)
    }
    
    override public func processEditing() {
        let paragraphRange = (string as NSString).paragraphRange(for: editedRange)
        
        let styles = markdownParser.styles(forString: string, atRange: paragraphRange)
        
        self.setAttributes(defaultAttributes, range: paragraphRange)
        
        for style in styles {
            self.addAttribute(
                style.attributeKey,
                value: style.value,
                range: NSRange(location: style.startIndex, length: style.length)
            )
        }
        
        super.processEditing()
    }
}
