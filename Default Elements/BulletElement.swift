//
//  BulletElement.swift
//  Markdowner
//
//  Created by Reynaldo Aguilar on 7/21/18.
//

import Foundation

public class BulletElement: MarkdownElement {
    var indicatorColor: UIColor = .red
    
    public init() {
        let pattern = "^[-|*] .+"
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .anchorsMatchLines) else {
            fatalError()
        }
        
        super.init(regex: regex)
    }
    
    public override func styles(forMatch match: String) -> [MarkdownElement.Style] {
        let indicatorColorStyle = Style.init(
            attributeKey: .foregroundColor,
            value: indicatorColor,
            startIndex: 0,
            length: 1
        )
        
        return [indicatorColorStyle]
    }
}
