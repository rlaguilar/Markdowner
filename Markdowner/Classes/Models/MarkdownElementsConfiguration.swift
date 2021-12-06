//
//  MarkdownElementsConfiguration.swift
//  Markdowner
//
//  Created by Reynaldo on 6/12/21.
//

import Foundation
import UIKit

public struct MarkdownElementsConfig {
    public let style: StylesConfiguration

    public let boldConfig: SimpleElementConfig
    public let italicConfig: SimpleElementConfig
    public let strikethroughConfig: SimpleElementConfig
    public let headerConfig: HeaderConfig
    public let bulletConfig: SimpleElementConfig
    public let linkConfig: LinkConfig
    public let inlineCodeConfig: InlineCodeConfig

    public let customElements: [MarkdownElement]

    public static func defaultConfig() -> MarkdownElementsConfig {
        func defaultCodeFont(style: StylesConfiguration) -> UIFont {
            guard let monospaceFont = UIFont(name: "Menlo-Regular", size: style.baseFont.pointSize) else {
                assertionFailure("Menlo font isn't available")
                return style.baseFont
            }

            return monospaceFont
        }

        let style = StylesConfiguration.default

        return MarkdownElementsConfig(
            style: style,
            boldConfig: .enabled,
            italicConfig: .enabled,
            strikethroughConfig: .enabled,
            headerConfig: .enabled(maxLevel: .max),
            bulletConfig: .enabled,
            linkConfig: .enabled(linkColor: UIColor.lightGray),
            inlineCodeConfig: .enabled(codeFont: defaultCodeFont(style: style)),
            customElements: []
        )
    }

    public func overriding(
        style: StylesConfiguration? = nil,
        boldConfig: SimpleElementConfig? = nil,
        italicConfig: SimpleElementConfig? = nil,
        strikethroughConfig: SimpleElementConfig? = nil,
        headerConfig: HeaderConfig? = nil,
        bulletConfig: SimpleElementConfig? = nil,
        linkConfig: LinkConfig? = nil,
        inlineCodeConfig: InlineCodeConfig? = nil,
        customElements: [MarkdownElement]? = nil
    ) -> MarkdownElementsConfig {
        return MarkdownElementsConfig(
            style: style ?? self.style,
            boldConfig: boldConfig ?? self.boldConfig,
            italicConfig: italicConfig ?? self.italicConfig,
            strikethroughConfig: strikethroughConfig ?? self.strikethroughConfig,
            headerConfig: headerConfig ?? self.headerConfig,
            bulletConfig: bulletConfig ?? self.bulletConfig,
            linkConfig: linkConfig ?? self.linkConfig,
            inlineCodeConfig: inlineCodeConfig ?? self.inlineCodeConfig,
            customElements: customElements ?? self.customElements
        )
    }

    public func enabledElements() -> [MarkdownElement] {
        let standardElements = [
            boldElement(),
            italicElement(),
            strikethroughElement(),
            headerElement(),
            bulletElement(),
            linkElement(),
            inlineElement()
        ].compactMap { $0 }

        return standardElements + customElements.map { $0.applying(stylesConfiguration: style) }
    }

    // MARK: - Instantiate standard elements
    private func boldElement() -> BoldElement? {
        guard case .enabled = boldConfig else {
            return nil
        }

        return BoldElement(symbolsColor: style.symbolsColor)
    }

    private func italicElement() -> ItalicElement? {
        guard case .enabled = italicConfig else {
            return nil
        }

        return ItalicElement(symbolsColor: style.symbolsColor)
    }

    private func strikethroughElement() -> StrikethroughElement? {
        guard case .enabled = strikethroughConfig else {
            return nil
        }

        return StrikethroughElement(symbolsColor: style.symbolsColor)
    }

    private func headerElement() -> HeaderElement? {
        guard case let .enabled(maxLevel) = headerConfig else {
            return nil
        }

        return HeaderElement(
            symbolsColor: style.symbolsColor,
            fontProvider: DefaultHeaderElementFontProvider(
                font: style.baseFont,
                useDynamicType: style.useDynamicType
            ),
            maxLevel: maxLevel
        )
    }

    private func bulletElement() -> BulletElement? {
        guard case .enabled = bulletConfig else {
            return nil
        }

        return BulletElement(
            symbolsColor: style.symbolsColor,
            textColor: style.textColor,
            font: style.baseFont,
            useDynamicType: style.useDynamicType
        )
    }

    private func linkElement() -> LinkElement? {
        guard case let .enabled(linkColor) = linkConfig else {
            return nil
        }

        return LinkElement(symbolsColor: style.symbolsColor, font: style.baseFont, linksColor: linkColor)
    }

    private func inlineElement() -> InlineCodeElement? {
        guard case let .enabled(codeFont) = inlineCodeConfig else {
            return nil
        }

        return InlineCodeElement(symbolsColor: style.symbolsColor, font: codeFont, useDynamicType: style.useDynamicType)
    }
}

public enum SimpleElementConfig {
    case enabled
    case disabled
}

public enum HeaderConfig {
    case enabled(maxLevel: HeaderElement.Level)
    case disabled
}

public enum LinkConfig {
    case enabled(linkColor: UIColor)
    case disabled
}

public enum InlineCodeConfig {
    case enabled(codeFont: UIFont)
    case disabled
}
