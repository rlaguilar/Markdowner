//
//  MarkdownTextStorage.swift
//  Markdowner
//
//  Created by Reynaldo Aguilar on 7/21/18.
//

import Foundation

/// Custom `NSTextStorage` subclass that will render text as markdown.
public class MarkdownTextStorage: NSTextStorage {
    public var elementsConfig: MarkdownElementsConfig {
        didSet {
            // refresh rendered content after elements config changes
            markdownParser = MarkdownParser(markdownElements: elementsConfig.enabledElements())

            let fullRange = NSRange(location: 0, length: string.utf16.count)
            self.edited(.editedAttributes, range: fullRange, changeInLength: 0)
        }
    }
    
    private var markdownParser: MarkdownParser
    
    private let backingString = NSMutableAttributedString()

    public init(elementsConfig: MarkdownElementsConfig = .init()) {
        self.elementsConfig = elementsConfig
        markdownParser = MarkdownParser(markdownElements: elementsConfig.enabledElements())
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Retrieves an attributted string containing a preview of the content inside this storage.
    ///
    /// - Parameter removingMarkdownSymbols: If equal to `true`, markdown symbols will be removed
    ///   from the resultant preview.
    /// - Returns: Preview of the markdown content in the storage.
    public func attributedString(removingMarkdownSymbols: Bool = true) -> NSAttributedString {
        guard removingMarkdownSymbols else { return self }
        
        let rangesToRemove = markdownParser.replacementRanges(forString: string as NSString)
        
        let originalString = NSMutableAttributedString(attributedString: self)
        
        for replacementRange in rangesToRemove.reversed() {
            originalString.replaceCharacters(
                in: replacementRange.range,
                with: replacementRange.replacementValue
            )
        }
        
        return originalString
    }
    
    // MARK: NSTextStorage subclass
    
    override public var string: String {
        return backingString.string
    }
    
    override public func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedStringKey : Any] {
        return backingString.attributes(at: location, effectiveRange: range)
    }
    
    override public func replaceCharacters(in range: NSRange, with str: String) {
        backingString.replaceCharacters(in: range, with: str)
        
        self.edited(.editedCharacters, range: range, changeInLength: str.utf16.count - range.length)
    }
    
    override public func setAttributes(_ attrs: [NSAttributedStringKey : Any]?, range: NSRange) {
        backingString.setAttributes(attrs, range: range)
        self.edited(.editedAttributes, range: range, changeInLength: 0)
    }
    
    override public func processEditing() {
        let string = self.string as NSString
        var paragraphRange = string.paragraphRange(for: editedRange)
        
        let lastParagraphIndex = paragraphRange.location + paragraphRange.length - 1
        let lastEditedIndex = max(
            editedRange.location,
            editedRange.location + editedRange.length - 1
        )
        
        let changedParagraphTrailingBorder = lastParagraphIndex <= lastEditedIndex
        let nextParagraphExists = lastParagraphIndex < string.length - 1
        let nextParagraphShouldBeProcessed = changedParagraphTrailingBorder && nextParagraphExists
        
        if nextParagraphShouldBeProcessed {
            // We need to process the next paragraph when the user press the enter key at the middle
            // of a line. Since the paragraph for the edit is the one corresponding to the first
            // half of the line, we also need to re-compute the styles for the second half to fix
            // its styles. For instance, if the line is a header, we need to remove the header
            // styles from the second line.
            paragraphRange = string.paragraphRange(
                for: NSRange(location: paragraphRange.location, length: paragraphRange.length + 1)
            )
        }

        var defaultAttributes: [NSAttributedStringKey: Any] {
            let baseFont = elementsConfig.style.baseFont
            let font = elementsConfig.style.useDynamicType ? baseFont.dynamic() : baseFont

            return [
                .font: font,
                .foregroundColor: elementsConfig.style.textColor
            ]
        }
        
        self.setAttributes(defaultAttributes, range: paragraphRange)
        
        let styles = markdownParser.styles(forString: string, atRange: paragraphRange)
        
        for style in styles {
            if style.attributeKey == .fontTraits {
                guard let fontTraits = style.value as? UIFontDescriptorSymbolicTraits else {
                    fatalError("Attribute `fontTraints` should have a value of type `UIFontDescriptorSymbolicTraits`")
                }
                
                let currentAttrs = self.attributes(at: style.startIndex, effectiveRange: nil)
                
                guard let currentFont = currentAttrs[.font] as? UIFont else {
                    fatalError("Unable to retrieve font for position \(style.startIndex)")
                }
                
                let newFont = currentFont.adding(traits: fontTraits)
                
                self.addAttribute(.font, value: newFont, range: style.range)
            }
            else {
                self.addAttribute(style.attributeKey, value: style.value, range: style.range)
            }
        }
        
        super.processEditing()
    }
}
