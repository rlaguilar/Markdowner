//
//  HeaderElement.swift
//  Markdowner
//
//  Created by Reynaldo Aguilar on 7/21/18.
//

import Foundation

public class HeaderElement: MarkdownElement {
    let symbolsColor: UIColor
    let fontProvider: HeaderElementFontProvider
    
    public init(symbolsColor: UIColor, fontProvider: HeaderElementFontProvider) {
        self.symbolsColor = symbolsColor
        self.fontProvider = fontProvider
        
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
            value: fontProvider.font(forLevel: level),
            startIndex: 0,
            length: match.count
        )
        
        let indicatorForegroundStyle = Style(
            attributeKey: .foregroundColor,
            value: symbolsColor,
            startIndex: 0,
            length: hashtagCount
        )
        
        return [fontStyle, indicatorForegroundStyle]
    }
    
    public override func applying(stylesConfiguration: StylesConfiguration) -> HeaderElement {
        let newFontProvider = fontProvider.applying(stylesConfiguration: stylesConfiguration)
        return HeaderElement(
            symbolsColor: stylesConfiguration.symbolsColor,
            fontProvider: newFontProvider
        )
    }
    
    public enum Level: Int {
        case h1 = 1, h2, h3, h4, h5, h6
        
        static let maxLevel = Level.h6
    }
}

public protocol HeaderElementFontProvider {
    func font(forLevel level: HeaderElement.Level) -> UIFont
    
    func applying(stylesConfiguration: StylesConfiguration) -> Self
}

final class DefaultHeaderElementFontProvider: HeaderElementFontProvider {
    let font: UIFont
    
    public init(font: UIFont) {
        self.font = font.adding(traits: .traitBold)
    }
    
    public func font(forLevel level: HeaderElement.Level) -> UIFont {
        let extraSize = CGFloat(HeaderElement.Level.maxLevel.rawValue - level.rawValue)
        let newFont = self.font.withSize(self.font.pointSize + extraSize)
        return newFont.dynamic()
    }
    
    public func applying(stylesConfiguration: StylesConfiguration) -> DefaultHeaderElementFontProvider {
        return DefaultHeaderElementFontProvider(font: stylesConfiguration.baseFont)
    }
}
