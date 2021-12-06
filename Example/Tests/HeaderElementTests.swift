//
//  HeaderElementTests.swift
//  Markdowner_Tests
//
//  Created by Reynaldo Aguilar on 7/21/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
@testable import Markdowner

class HeaderElementTests: XCTestCase {
    let fontProvider = MockHeaderElementFontProvider()
    
    lazy var element = HeaderElement(
        symbolsColor: .red,
        fontProvider: fontProvider
    )
    
    // MARK: - Regex tests
    func testRegex_WhenMatchFullRange_ReturnsIt() {
        let samples = [
            "# Hello",
            "## Hello",
            "### Hello",
            "#### Hello",
            "##### Hello",
            "###### Hello"
        ]
        
        for markdown in samples {
            let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
            
            XCTAssertEqual(matches.count, 1, "There should be exactly one match")
            XCTAssertEqual(matches.first?.range, markdown.range, "It should match the entire line")
        }
    }
    
    func testRegex_WhenMatchMultipleTimes_ReturnsAllOfThem() {
        let markdown = "## L1 \n#### L2\nL3\n# L4"
        let expectedRanges: [NSRange] = [
            .init(location: 0, length: 6), .init(location: 7, length: 7), .init(location: 18, length: 4)
        ]
        
        let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
        
        XCTAssertEqual(matches.map { $0.range }, expectedRanges, "Invalid output")
    }
    
    func testRegex_WhenNoSpaceAfterIndicator_DoNotRecognizeIt() {
        let samples = [
            "#A",
            "##A",
            "###A",
            "####A",
            "#####A",
            "######A"
        ]
        
        for markdown in samples {
            let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
            
            XCTAssert(matches.isEmpty, "There shouldn't be any match because of the spaces")
        }
    }
    
    func testRegex_WhenIndicatorIsNotAtTheLineStart_DoNotRecognizeIt() {
        let samples = [
            " # Hello",
            "Line ## Hello"
        ]
        
        for markdown in samples {
            let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
            
            XCTAssert(matches.isEmpty, "The headers aren't at the line start")
        }
    }
    
    func testRegex_WhenNoContentAfterIndicator_DoNotRecognizeIt() {
        let markdown = "# "
        
        let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
        
        XCTAssert(matches.isEmpty, "There is no content after the header indicator")
    }
    
    func testRegex_DoesNotRecognizeMoreThanMaxLevel() {
        let element = HeaderElement(symbolsColor: .red, fontProvider: fontProvider, maxLevel: .h1)
        
        let markdown = "## Hello"
        
        let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
        
        XCTAssert(matches.isEmpty)
    }
    
    // MARK: - Styles tests
    func testStyles_ReturnsCorrectFontSize() {
        let samples: [NSString] = [
            "# Hello",
            "## Hello",
            "### Hello",
            "#### Hello",
            "##### Hello",
            "###### Hello"
        ]
        
        let levels: [HeaderElement.Level] = [.h1, .h2, .h3, .h4, .h5, .h6]
        
        zip(samples, levels).forEach { (markdown, level) in
            let fontStyle = element.styles(forMatch: markdown).first { $0.attributeKey == .font }
            
            let font = fontStyle?.value as? UIFont
            XCTAssertEqual(font, fontProvider.font(forLevel: level), "Fonts don't match")
        }
    }
    
    func testStyles_ReturnsCorrectForegroundColor() {
        let samples: [NSString] = [
            "# Hello",
            "## Hello",
            "### Hello",
            "#### Hello",
            "##### Hello",
            "###### Hello"
        ]
        
        let levels: [HeaderElement.Level] = [.h1, .h2, .h3, .h4, .h5, .h6]
        
        zip(samples, levels).forEach { (markdown, level) in
            let expectedRange = NSRange(location: 0, length: level.rawValue)
            
            let style = element.styles(forMatch: markdown).first { $0.attributeKey == .foregroundColor }
            
            let styleRange = style.flatMap { NSRange(location: $0.startIndex, length: $0.length) }

            XCTAssertEqual(styleRange, expectedRange, "The style should  be applied only to the indicators ")
        }
    }
    
    // MARK: - Replacement ranges
    func testReplacementRanges_ReturnValidRanges() {
        let markdown: NSString = "## Hello"
        let expectedRanges = [
            ReplacementRange(
                range: NSRange(location: 0, length: 3),
                replacementValue: NSAttributedString()
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
    
    func testApplyStylesConfiguration_UpdateFontProvider() {
        let configurations = StylesConfiguration.mockConfigurations()
        let expectedProviders = configurations.map { fontProvider.applying(stylesConfiguration: $0) }
        
        let providers = configurations.map { element.applying(stylesConfiguration: $0).fontProvider }
        
        XCTAssertEqual(providers as? [MockHeaderElementFontProvider], expectedProviders)
    }
    
    func testApplyStylesConfiguration_UpdateMaxLevel() {
        let element = HeaderElement(symbolsColor: .red, fontProvider: fontProvider, maxLevel: .h3)
        let configurations = StylesConfiguration.mockConfigurations()
        
        let maxLevels = configurations.map { element.applying(stylesConfiguration: $0).maxLevel }
        
        XCTAssertEqual(maxLevels, configurations.map { _ in .h3 })
    }
}
