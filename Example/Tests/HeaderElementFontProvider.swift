//
//  HeaderElementFontProvider.swift
//  Markdowner_Tests
//
//  Created by Reynaldo Aguilar on 7/22/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
@testable import Markdowner

final class MockHeaderElementFontProvider: HeaderElementFontProvider {
    var defaultFont = UIFont.systemFont(ofSize: 10)
    
    func font(forLevel level: HeaderElement.Level) -> UIFont {
        return defaultFont.withSize(CGFloat(level.rawValue))
    }
    
    func applying(stylesConfiguration: StylesConfiguration) -> MockHeaderElementFontProvider {
        return MockHeaderElementFontProvider()
    }
}
