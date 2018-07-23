//
//  ItalicElementTests.swift
//  Markdowner_Tests
//
//  Created by Reynaldo Aguilar on 7/21/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
@testable import Markdowner

class ItalicElementTests: XCTestCase {
    let element = ItalicElement(symbolsColor: .red)
    
    // MARK: - Regex tests
    func testRegex_WhenMathFullRange_ReturnsIt() {
        let samples = [
            "*This is a italic string*",
            "_This is a italic string_"
        ]
        
        for markdown in samples {
            let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
            
            XCTAssertEqual(matches.count, 1, "There should be exactly one match for: \(markdown)")
            XCTAssertEqual(matches.first?.range, markdown.range, "The match in `\(markdown)` should be the full string")
        }
    }
    
    func testRegex_WhenInvalidMatch_ReturnsNone() {
        let samples = [
            "*This isn't a italic string_",
            "_Nor is this*",
            "This is a plain text",
            "This is* a random text",
            "This is_ another text"
        ]
        
        for markdown in samples {
            let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
            
            XCTAssert(matches.isEmpty, "There should be no valid matches for: \(markdown)")
        }
    }
    
    func testRegex_WhenLineBreak_ReturnsNone() {
        let samples = ["*a\nb*", "_a\nb_"]
        
        for markdown in samples {
            let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
            
            XCTAssert(matches.isEmpty, "Italics should't extend by more than one line")
        }
    }
    
    func testRegex_WhenMultipleMatches_ReturnsAll() {
        let samples = [
            "*a_b*c_d_e*",
            "*o O match*_nn_",
            "T *one _value_ _a_"
        ]
        
        let expectedRanges: [[NSRange]] = [
            [.init(location: 0, length: 5), .init(location: 6, length: 3)],
            [.init(location: 0, length: 11), .init(location: 11, length: 4)],
            [.init(location: 7, length: 7), .init(location: 15, length: 3)]
        ]
        
        zip(samples, expectedRanges).forEach { (markdown, ranges) in
            let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
            
            XCTAssertEqual(matches.map { $0.range }, ranges, "Invalid output for: \(markdown)")
        }
    }
    
    func testRegex_WhenSpaceBetweenIndicators_DoesNotMatch() {
        let samples = ["* Hello*", "_ Hello_", "*Hello *", "_Hello _"]
        
        for markdown in samples {
            let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
            
            XCTAssert(matches.isEmpty, "\(markdown): Should't match with space between the indicators and the content")
        }
    }
    
    func testRegex_WhenEmptyContent_DoesNotMatch() {
        let samples = ["**", "__"]
        
        for markdown in samples {
            let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
            
            XCTAssert(matches.isEmpty, "Shouldn't match empty values")
        }
    }
    
    func testRegex_ConsecutiveSymbols_DoNotMatch() {
        let samples = ["**hello*", "*hello**", "__hello_", "_hello__"]
        
        for markdown in samples {
            let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
            
            XCTAssert(matches.isEmpty, "\(markdown): Shouldn't match with more that once symbol")
        }
    }
    
    func testRegex_IfMatchContainsConsecutiveElements_ReturnsIt() {
        let samples = ["*a**b*", "_a__b_", "*a__b*", "_a**b_"]
        
        for markdown in samples {
            let expectedRanges = [markdown.range]
            let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
            let matchedRanges = matches.map { $0.range }
            
            XCTAssertEqual(matchedRanges, expectedRanges, "Invalid output")
        }
    }
    
    // MARK: - Styles tests
    func testStyles_ReturnsItalicFontTrait() {
        let markdown = "*Hello*"
        
        let fontTraits = element.styles(forMatch: markdown).first { $0.attributeKey == .fontTraits }
        
        XCTAssertEqual(fontTraits?.value as? UIFontDescriptorSymbolicTraits, .traitItalic)
        XCTAssertEqual(fontTraits?.range, markdown.range, "The traits should be applied the whole string")
    }
    
    func testStyles_ReturnsIndicatorsColor() {
        let markdown = "_Hello_"
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
        let markdown = "_Hello_"
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
        let configurations = [
            StylesConfiguration(
                baseFont: UIFont.systemFont(ofSize: 10),
                textColor: .black,
                symbolsColor: .red
            ),
            StylesConfiguration(
                baseFont: UIFont.systemFont(ofSize: 10),
                textColor: .black,
                symbolsColor: .blue
            )
        ]
        
        let symbolsColors = configurations.map { element.applying(stylesConfiguration: $0).symbolsColor }
        
        XCTAssertEqual(symbolsColors, configurations.map { $0.symbolsColor })
    }
}
