//
//  BulletElementTests.swift
//  Markdowner_Tests
//
//  Created by Reynaldo Aguilar on 7/21/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
@testable import Markdowner

class BulletElementTests: XCTestCase {
    let element = BulletElement(
        symbolsColor: .red,
        textColor: .black,
        font: UIFont.systemFont(ofSize: 10),
        useDynamicType: true
    )
    
    // MARK: Regex tests
    func testRegex_WhenMatchFullRange_ReturnsIt() {
        let samples = [
            "* Hello",
            "- Hello"
        ]
        
        for markdown in samples {
            let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
            
            XCTAssertEqual(matches.count, 1, "There should be exactly one match")
            XCTAssertEqual(matches.first?.range, markdown.range, "It should match the whole string")
        }
    }
    
    func testRegex_WhenMatchMultipleTimes_ReturnsAllOfThem() {
        let markdown = "- Line 1\nLine2\n* Line3"
        let expectedRanges = [NSRange(location: 0, length: 8), NSRange(location: 15, length: 7)]
        let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
        
        let matchedRanges = matches.map { $0.range }
        XCTAssertEqual(matchedRanges, expectedRanges, "Invalid output")
    }
    
    func testRegex_WhenNoSpaceAfterIndicator_DoNotRecognizeIt() {
        let samples = [
            "-Hello",
            "*Hello"
        ]
        
        for markdown in samples {
            let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
            
            XCTAssert(matches.isEmpty, "There are no valid matches")
        }
    }
    
    func testRegex_WhenIndicatorIsNotAtTheLineStart_DoNotRecognizeIt() {
        let samples = [" - My nice line", " * My nice line"]
        
        for markdown in samples {
            let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
            
            XCTAssert(matches.isEmpty, "The indicator isn't at the start of the line")
        }
    }
    
    func testRegex_WhenNoContentAfterIndicator_DoNotRecognizeIt() {
        let markdown = "- "
        
        let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
        
        XCTAssert(matches.isEmpty, "There is no content after the bullet indicator")
    }
    
    // MARK: - Styles tests
    func testStyles_WhenCalled_ReturnsForegroundColorForIndicator() {
        let samples = [
            "- Hello",
            "* Hello"
        ]
        
        for markdown in samples {
            let style = element.styles(forMatch: markdown).first { $0.attributeKey == .foregroundColor }

            XCTAssertEqual(style?.startIndex, 0, "The indicator starts at the first position")
            XCTAssertEqual(style?.length, 1, "Should apply the style only to the indicator")
        }
    }
    
    // MARK: - Replacement ranges
    func testReplacementRanges_ReturnValidRanges() {
        let markdown = "- Hello"

        let expectedRanges = [
            ReplacementRange(
                range: NSRange(location: 0, length: 2),
                replacementValue: NSAttributedString(
                    string: "• ",
                    attributes: [.foregroundColor: element.textColor, .font: element.font.dynamic()]
                )
            )
        ]
        
        let replacementRanges = element.replacementRanges(forMatch: markdown)
            .sorted(by: { $0.range.location < $1.range.location })
        
        XCTAssertEqual(replacementRanges, expectedRanges)
    }
    
    // MARK: - Update from Style Configuration tests
    func testApplyStylesConfiguration_UpdateSymbolsColor() {
        let configurations = StylesConfiguration.mockConfigurations()
        
        let symbolsColors = configurations.map { element.applying(stylesConfiguration: $0).symbolsColor }
        
        XCTAssertEqual(symbolsColors, configurations.map { $0.symbolsColor })
    }
    
    func testApplyStylesConfiguration_UpdateTextColor() {
        let configurations = StylesConfiguration.mockConfigurations()
        
        let textColors = configurations.map { element.applying(stylesConfiguration: $0).textColor }
        
        XCTAssertEqual(textColors, configurations.map { $0.textColor })
    }
    
    func testApplyStylesConfiguration_UpdateFont() {
        let configurations = StylesConfiguration.mockConfigurations()
        
        let fonts = configurations.map { element.applying(stylesConfiguration: $0).font }
        
        XCTAssertEqual(fonts, configurations.map { $0.baseFont })
    }
    
    func testApplyStylesConfiguration_UpdateUseDynamicType() {
        let configurations = StylesConfiguration.mockConfigurations()
        
        let useDynamicType = configurations.map { element.applying(stylesConfiguration: $0).useDynamicType }
        
        XCTAssertEqual(useDynamicType, configurations.map { $0.useDynamicType })
    }
}
