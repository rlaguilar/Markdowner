//
//  InlineCodeElementTests.swift
//  Markdowner_Example
//
//  Created by Reynaldo Aguilar on 7/26/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
@testable import Markdowner

class InlineCodeElementTests: XCTestCase {
    let codeFont = UIFont(name: "Menlo-Regular", size: 10)!
    
    lazy var element = InlineCodeElement(symbolsColor: .red, font: codeFont, useDynamicType: true)
    
    // MARK: - Regex tests
    func testRegex_WhenMathFullRange_ReturnsIt() {
        let markdown = "`This is a code`"
        
        let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
        
        XCTAssertEqual(matches.count, 1, "There should be only one match")
        XCTAssertEqual(matches.first?.range, markdown.range, "The match should be the full string")
    }
    
    func testRegex_WhenInvalidMatch_ReturnsNone() {
        let samples = [
            "``This isn't a code string`",
            "`Nor is this``",
            "This is a plain text",
            "This `is' a random text"
        ]
        
        for markdown in samples {
            let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
            
            XCTAssert(matches.isEmpty, "There should be no valid matches for: \(markdown)")
        }
    }
    
    func testRegex_WhenLineBreak_ReturnsNone() {
        let markdown = "`a\nb`"
        
        let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
        
        XCTAssert(matches.isEmpty, "Inline code should't extend by more than one line")
    }
    
    func testRegex_WhenMultipleMatches_ReturnsAll() {
        let samples = [
            "`mm` `a`",
            "`o O ` match` n `",
            "This time `one vale s` here ` here"
        ]
        
        let expectedRanges: [[NSRange]] = [
            [.init(location: 0, length: 4), .init(location: 5, length: 3)],
            [.init(location: 0, length: 13)],
            [.init(location: 10, length: 12)]
        ]
        
        zip(samples, expectedRanges).forEach { (markdown, ranges) in
            let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
            
            XCTAssertEqual(matches.map { $0.range }, ranges, "Invalid output for: \(markdown)")
        }
    }
    
    func testRegex_WhenSpaceBetweenIndicators_DoesNotMatch() {
        let samples = ["`Hello `", "` Hello`"]
        
        for markdown in samples {
            let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
            
            XCTAssert(matches.isEmpty, "\(markdown): Shouldn't match with space between the indicators and the content")
        }
    }
    
    func testRegex_WhenEmptyContent_DoesNotMatch() {
        let markdown = "``"
        
        let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
        
        XCTAssert(matches.isEmpty, "Shouldn't match empty values")
    }
    
    func testRegex_WhenConsecutiveSymbols_DoNotMatch() {
        let samples = ["``hello`", "`hello``"]
        
        for markdown in samples {
            let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
            
            XCTAssert(matches.isEmpty, "\(markdown): Shouldn't match with more than 1 symbols")
        }
    }
    
    func testRegex_IfMatchContainsNonValidBoundaries_ReturnsIt() {
        let samples = ["`a `b`", "`a ` b`"]
        
        for markdown in samples {
            let expectedRanges = [markdown.range]
            
            let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
            let matchedRanges = matches.map { $0.range }
            
            XCTAssertEqual(matchedRanges, expectedRanges, "Should't match the whole string")
            
        }
    }
    
    // MARK: - Styles tests
    func testStyles_ReturnsCodeFont() {
        let markdown = "`Hello`"
        
        let fontStyle = element.styles(forMatch: markdown).first { $0.attributeKey == .font }
        
        XCTAssertEqual(fontStyle?.value as? UIFont, codeFont.dynamic())
        XCTAssertEqual(fontStyle?.range, markdown.range, "The font should be applied the whole string")
    }
    
    func testStyles_ReturnsIndicatorsColor() {
        let markdown = "`Hello`"
        let expectedColors = [element.symbolsColor, element.symbolsColor]
        let expectedRanges = [
            NSRange(location: 0, length: 1),
            NSRange(location: markdown.count - 1, length: 1)
        ]
        
        let styles = element.styles(forMatch: markdown)
            .filter { $0.attributeKey == .foregroundColor }
            .sorted(by: { $0.startIndex < $1.startIndex })
        
        XCTAssertEqual(styles.compactMap { $0.value as? UIColor }, expectedColors)
        XCTAssertEqual(styles.map { $0.range }, expectedRanges)
    }
    
    // MARK: - Replacement ranges
    func testReplacementRanges_ReturnValidRanges() {
        let markdown = "`Hello`"
        let expectedRanges = [
            ReplacementRange(
                range: NSRange(location: 0, length: 1),
                replacementValue: NSAttributedString()
            ),
            ReplacementRange(
                range: NSRange(location: markdown.count - 1, length: 1),
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
    
    func testApplyStylesConfiguration_UpdateUseDynamicType() {
        let configurations = StylesConfiguration.mockConfigurations()
        
        let dynamicTypes = configurations.map { element.applying(stylesConfiguration: $0).useDynamicType }
        
        XCTAssertEqual(dynamicTypes, configurations.map { $0.useDynamicType })
    }
}
