//
//  BulletElement.swift
//  Markdowner
//
//  Created by Reynaldo Aguilar on 7/21/18.
//

import Foundation

public class BulletElement: MarkdownElement {
    let symbolsColor: UIColor
    
    public init(symbolsColor: UIColor) {
        self.symbolsColor = symbolsColor
        
        let pattern = "^[-|*] .+"
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .anchorsMatchLines) else {
            fatalError()
        }
        
        super.init(regex: regex)
    }
    
    public override func styles(forMatch match: String) -> [MarkdownElement.Style] {
        let indicatorColorStyle = Style.init(
            attributeKey: .foregroundColor,
            value: symbolsColor,
            startIndex: 0,
            length: 1
        )
        
        return [indicatorColorStyle]
    }
    
    public override func applying(stylesConfiguration: StylesConfiguration) -> BulletElement {
        return BulletElement(symbolsColor: stylesConfiguration.symbolsColor)
    }
}
