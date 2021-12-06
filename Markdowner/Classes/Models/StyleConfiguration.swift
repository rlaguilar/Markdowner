//
//  StyleConfiguration.swift
//  Markdowner
//
//  Created by Reynaldo Aguilar on 7/22/18.
//

import Foundation

/// Object used to provide a common look and feel to the markdown text.
open class StylesConfiguration {
    public static let `default` = StylesConfiguration(
        baseFont: UIFont.systemFont(ofSize: 14),
        textColor: .black,
        symbolsColor: .blue,
        useDynamicType: true
    )

    /// Base font that will be used to display the markdown content.
    public let baseFont: UIFont
    
    /// Default color for the markdown text.
    public let textColor: UIColor
    
    /// Color that will be used to display the markdown symbols.
    public let symbolsColor: UIColor
    
    /// Indicates if should use fonts that support dynamic type.
    public let useDynamicType: Bool
    
    public init(baseFont: UIFont, textColor: UIColor, symbolsColor: UIColor, useDynamicType: Bool) {
        self.baseFont = baseFont
        self.textColor = textColor
        self.symbolsColor = symbolsColor
        self.useDynamicType = useDynamicType
    }
}
