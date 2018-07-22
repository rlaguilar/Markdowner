//
//  StyleConfiguration.swift
//  Markdowner
//
//  Created by Reynaldo Aguilar on 7/22/18.
//

import Foundation

open class StylesConfiguration {
    public let baseFont: UIFont
    public let textColor: UIColor
    public let symbolsColor: UIColor
    
    public init(baseFont: UIFont, textColor: UIColor, symbolsColor: UIColor) {
        self.baseFont = baseFont
        self.textColor = textColor
        self.symbolsColor = symbolsColor
    }
}
