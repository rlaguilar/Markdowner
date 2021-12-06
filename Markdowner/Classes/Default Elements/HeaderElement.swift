//
//  HeaderElement.swift
//  Markdowner
//
//  Created by Reynaldo Aguilar on 7/21/18.
//

import Foundation

/// Type used to identify header elements.
/// - NOTE:
///     ## A header like this
open class HeaderElement: MarkdownElement {
    public let symbolsColor: UIColor
    public let fontProvider: HeaderElementFontProvider
    public let maxLevel: Level
    
    public init(symbolsColor: UIColor, fontProvider: HeaderElementFontProvider, maxLevel: Level = .max) {
        self.symbolsColor = symbolsColor
        self.fontProvider = fontProvider
        self.maxLevel = maxLevel
        
        guard let regex = try? NSRegularExpression(pattern: "^(#{1,\(maxLevel.rawValue)}) .+", options: .anchorsMatchLines) else {
            fatalError()
        }
        
        super.init(regex: regex)
    }
    
    open override func styles(forMatch match: NSString) -> [MarkdownElement.Style] {
        let level = self.level(forMatch: match)
        
        let fontStyle = Style(
            attributeKey: .font,
            value: fontProvider.font(forLevel: level),
            startIndex: 0,
            length: match.length
        )
        
        let indicatorForegroundStyle = Style(
            attributeKey: .foregroundColor,
            value: symbolsColor,
            startIndex: 0,
            length: level.rawValue
        )
        
        return [fontStyle, indicatorForegroundStyle]
    }
    
    open override func applying(stylesConfiguration: StylesConfiguration) -> HeaderElement {
        let newFontProvider = fontProvider.applying(stylesConfiguration: stylesConfiguration)
        return HeaderElement(
            symbolsColor: stylesConfiguration.symbolsColor,
            fontProvider: newFontProvider,
            maxLevel: maxLevel
        )
    }
    
    open override func replacementRanges(forMatch match: NSString) -> [ReplacementRange] {
        let matchLevel = self.level(forMatch: match)
        let range = NSRange(location: 0, length: matchLevel.rawValue + 1)
        let replacementRange = ReplacementRange(range: range, replacementValue: NSAttributedString())
        return [replacementRange]
    }
    
    private func level(forMatch match: NSString) -> Level {
        let fullRange = NSRange(location: 0, length: match.length)
        
        guard let regexMatch = regex.matches(in: match as String, options: [], range: fullRange).first else {
            fatalError("ERROR: Unable to find match for the given input")
        }
        
        let hashtagCount = regexMatch.range(at: 1).length
        
        guard let level = Level(rawValue: hashtagCount) else {
            fatalError("Unable to retrive header level from match")
        }
        
        return level
    }
    
    public enum Level: Int {
        case h1 = 1, h2, h3, h4, h5, h6
        
        public static let max = Level.h6
    }
}

public protocol HeaderElementFontProvider {
    func font(forLevel level: HeaderElement.Level) -> UIFont
    
    func applying(stylesConfiguration: StylesConfiguration) -> Self
}

final public class DefaultHeaderElementFontProvider: HeaderElementFontProvider {
    let font: UIFont
    let useDynamicType: Bool
    
    public init(font: UIFont, useDynamicType: Bool) {
        self.font = font.adding(traits: .traitBold)
        self.useDynamicType = useDynamicType
    }
    
    public func font(forLevel level: HeaderElement.Level) -> UIFont {
        let extraSize = CGFloat(HeaderElement.Level.max.rawValue - level.rawValue)
        let newFont = self.font.withSize(self.font.pointSize + extraSize)
        return useDynamicType ? newFont.dynamic() : newFont
    }
    
    public func applying(stylesConfiguration: StylesConfiguration) -> DefaultHeaderElementFontProvider {
        return DefaultHeaderElementFontProvider(
            font: stylesConfiguration.baseFont,
            useDynamicType: stylesConfiguration.useDynamicType
        )
    }
}
