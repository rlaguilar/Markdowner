//
//  BoldElementTests.swift
//  Markdowner_Example
//
//  Created by Reynaldo Aguilar on 7/21/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
@testable import Markdowner

class BoldElementTests: XCTestCase {
    var element = BoldElement()
    
    // MARK: - Regex tests
    func testRegex_WhenMathFullRange_ReturnsIt() {
        let markdown = "**This is a bold string**"
        
        let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
        
        XCTAssertEqual(matches.count, 1, "There should be only one match")
        XCTAssertEqual(matches.first?.range, markdown.range, "The match should be the full string")
    }
    
    func testRegex_WhenInvalidMatch_ReturnsNone() {
        let samples = [
            "**This isn't a bold string*",
            "*Nor is this**",
            "This is a plain text",
            "This *is* a random text"
        ]
        
        for markdown in samples {
            let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
            
            XCTAssert(matches.isEmpty, "There should be no valid matches for: \(markdown)")
        }
    }
    
    func testRegex_WhenLineBreak_ReturnsNone() {
        let markdown = "**a\nb**"
        
        let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
        
        XCTAssert(matches.isEmpty, "Bolds should't extend by more than one line")
    }
    
    func testRegex_WhenMultipleMatches_ReturnsAll() {
        let samples = [
            "**mm** **a**",
            "**o O * match** n*",
            "This time **one vale s** here ** here"
        ]
        
        let expectedRanges: [[NSRange]] = [
            [.init(location: 0, length: 6), .init(location: 7, length: 5)],
            [.init(location: 0, length: 15)],
            [.init(location: 10, length: 14)]
        ]
        
        zip(samples, expectedRanges).forEach { (markdown, ranges) in
            let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
            
            XCTAssertEqual(matches.map { $0.range }, ranges, "Invalid output for: \(markdown)")
        }
    }
    
    func testRegex_WhenSpaceBetweenIndicators_DoesNotMatch() {
        let samples = ["**Hello **", "** Hello**"]
        
        for markdown in samples {
            let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
            
            XCTAssert(matches.isEmpty, "\(markdown): Shouldn't match with space between the indicators and the content")
        }
    }
    
    func testRegex_WhenEmptyContent_DoesNotMatch() {
        let markdown = "****"
        
        let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
        
        XCTAssert(matches.isEmpty, "Shouldn't match empty values")
    }
    
    func testRegex_WhenConsecutiveSymbols_DoNotMatch() {
        let samples = ["***hello**", "**hello***"]
        
        for markdown in samples {
            let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
            
            XCTAssert(matches.isEmpty, "\(markdown): Shouldn't match with more than 2 symbols")
        }
    }
    
    func testRegex_IfMatchContainsNonValidBoundaries_ReturnsIt() {
        let samples = ["**a*b**", "**a***b**"]
        
        for markdown in samples {
            let expectedRanges = [markdown.range]
            
            let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
            let matchedRanges = matches.map { $0.range }
            
            XCTAssertEqual(matchedRanges, expectedRanges, "Should't match the whole string")
            
        }
    }
    
    // MARK: - Styles tests
    func testStyles_WhenCalled_ReturnValidRanges() {
        let markdown = "**Cool markdown**"
        
        let styles = element.styles(forMatch: markdown)
        let ranges = styles.map { s in NSRange(location: s.startIndex, length: s.length) }
        
        let expectedRanges = [NSRange](repeating: markdown.range, count: styles.count)
        XCTAssertEqual(ranges, expectedRanges, "All the styles should be applied to the full range")
    }
    
    func testStyles_WhenCalled_ReturnsBoldTrait() {
        let markdown = "**Hello**"
        
        let fontTraits = element.styles(forMatch: markdown).first { $0.attributeKey == .fontTraits }
        
        XCTAssertNotNil(fontTraits, "There should be a custom font trait")
        XCTAssertEqual(fontTraits?.value as? UIFontDescriptorSymbolicTraits, .traitBold)
    }
}
