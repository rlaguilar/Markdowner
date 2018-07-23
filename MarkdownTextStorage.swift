//
//  MarkdownTextStorage.swift
//  Markdowner
//
//  Created by Reynaldo Aguilar on 7/21/18.
//

import Foundation

public class MarkdownTextStorage: NSTextStorage {
    var stylesConfiguration: StylesConfiguration {
        didSet {
            self.refreshContent()
        }
    }
    
    private var markdownParser: MarkdownParser
    
    private let backingString = NSMutableAttributedString()
    
    private var defaultAttributes: [NSAttributedStringKey: Any] {
        return [
            .font: stylesConfiguration.baseFont,
            .foregroundColor: stylesConfiguration.textColor
        ]
    }
    
    private var defaultElements: [MarkdownElement] {
        let boldElement = BoldElement(symbolsColor: stylesConfiguration.symbolsColor)
        let italicElement = ItalicElement(symbolsColor: stylesConfiguration.symbolsColor)
        let bulletElement = BulletElement(
            symbolsColor: stylesConfiguration.symbolsColor,
            textColor: stylesConfiguration.textColor,
            font: stylesConfiguration.baseFont
        )
        
        let headerElement = HeaderElement(
            symbolsColor: stylesConfiguration.symbolsColor,
            fontProvider: DefaultHeaderElementFontProvider(font: stylesConfiguration.baseFont)
        )

        return [boldElement, italicElement, bulletElement, headerElement]
    }
    
    public override init() {
        self.stylesConfiguration = StylesConfiguration(
            baseFont: UIFont.systemFont(ofSize: 14),
            textColor: .black,
            symbolsColor: .blue
        )
        
        markdownParser = MarkdownParser(markdownElements: [])

        super.init()
        
        self.use(elements: defaultElements)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func use(elements: [MarkdownElement]) {
        self.markdownParser = MarkdownParser(markdownElements: elements)
        self.refreshContent()
    }
    
    public func attributedString(removingMarkdownSymbols: Bool = true) -> NSAttributedString {
        guard removingMarkdownSymbols else { return self }
        
        let rangesToRemove = markdownParser.replacementRanges(forString: string)
        
        let originalString = NSMutableAttributedString(attributedString: self)
        
        for replacementRange in rangesToRemove.reversed() {
            if replacementRange.replacementValue.string.isEmpty {
                originalString.deleteCharacters(in: replacementRange.range)
            }
            else {
                originalString.replaceCharacters(
                    in: replacementRange.range,
                    with: replacementRange.replacementValue
                )
            }
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
    
    private func refreshContent() {
        let newMarkdowElements = markdownParser.markdownElements
            .map { $0.applying(stylesConfiguration: stylesConfiguration) }
        
        markdownParser = MarkdownParser(markdownElements: newMarkdowElements)
        
        let fullRange = NSRange(location: 0, length: string.count)
        
        self.edited(.editedAttributes, range: fullRange, changeInLength: 0)
    }
}
