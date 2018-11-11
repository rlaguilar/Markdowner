//
//  LinkElementTests.swift
//  Markdowner_Example
//
//  Created by Reynaldo Aguilar on 7/27/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
@testable import Markdowner

class LinkElementTests: XCTestCase {
    lazy var baseFont = UIFont.systemFont(ofSize: 10)
    lazy var symbolsColor = UIColor.red
    lazy var linksColor = UIColor.blue
    
    lazy var element = LinkElement(
        symbolsColor: symbolsColor,
        font: baseFont,
        linksColor: linksColor
    )
    
    // MARK: - Regex tests
    func testRegex_WhenMathFullRange_ReturnsIt() {
        let markdown = "[Link](https://google.com)"
        
        let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
        
        XCTAssertEqual(matches.count, 1, "There should be only one match")
        XCTAssertEqual(matches.first?.range, markdown.range, "The match should be the full string")
    }
    
    func testRegex_MatchValidURLs() {
        let samples = [
            "[a](google.com)",
            "[a](www.google.com)",
            "[a](http://google.com)",
            "[a](https://google.com)",
            "[a](http://www.google.com)",
            "[a](mailto:email@domain.com)",
            "[a](http://google.com/user/123?q=search)"
        ]
        
        for markdown in samples {
            let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
            
            XCTAssertEqual(matches.count, 1)
            XCTAssertEqual(matches.first?.range, markdown.range)
        }
    }
    
    func testRegex_WhenInvalidMatch_ReturnsNone() {
        let samples = [
            "[This] isn't a link string*",
            "(Nor)[is this]",
            "This is a plain text",
            "This [is] (a random text)"
        ]
        
        for markdown in samples {
            let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
            
            XCTAssert(matches.isEmpty, "There should be no valid matches for: \(markdown)")
        }
    }
    
    func testRegex_WhenLineBreak_ReturnsNone() {
        let samples = ["[ab\n](http://example.com)", "[link](https://example.com\n)"]
        
        for markdown in samples {
            let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
            
            XCTAssert(matches.isEmpty, "Bolds should't extend by more than one line")
        }
    }
    
    func testRegex_WhenSpaceBetweenIndicators_DoesNotMatch() {
        let samples = ["[Link ](www.sample.com)", "[ Link](www.sample.com)", "[Link]( www.sample.com)", "[Link](www.sample.com )"]
        
        for markdown in samples {
            let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
            
            XCTAssert(matches.isEmpty, "\(markdown): Shouldn't match with space between the indicators and the content")
        }
    }
    
    func testRegex_WhenEmptyContent_DoesNotMatch() {
        let samples = ["[](www.sample.com)", "[Link]()"]
        
        for markdown in samples {
            let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
            
            XCTAssert(matches.isEmpty, "Shouldn't match empty values")
        }
    }
    
    func testRegex_WhenConsecutiveSymbols_DoNotMatch() {
        let samples = ["[[Link](www.sample.com)", "[Link]](www.sample.com)", "[Link](www.example.com))", "[Link]((sample.com)"]
        
        for markdown in samples {
            let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
            
            XCTAssert(matches.isEmpty, "\(markdown): Shouldn't match with more than 2 symbols")
        }
    }
    
    func testRegex_IfMatchContainsNonValidBoundaries_ReturnsIt() {
        let samples = ["[Link [] a](www.sample.com)", "[A]][ssd](www.sample.com)"]
        
        for markdown in samples {
            let expectedRanges = [markdown.range]
            
            let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
            let matchedRanges = matches.map { $0.range }
            
            XCTAssertEqual(matchedRanges, expectedRanges, "Should't match the whole string")
            
        }
    }
    
    // MARK: - Styles tests
    func testStyles_ReturnsValidStylesCount() {
        let markdown: NSString = "[a](sample.com)"
        
        let styles = element.styles(forMatch: markdown)
        
        // The expected styles are: 4 symbols colors, 1 link color and 1 link action
        XCTAssertEqual(styles.count, 6)
    }
    
    func testStyles_ReturnsLinkAction() {
        let markdown: NSString = "[A](sample.com)"
        
        let linkAction = element.styles(forMatch: markdown).first { $0.attributeKey == .link }
        
        XCTAssertEqual(linkAction?.range, NSRange(location: 1, length: 1))
        XCTAssertEqual(linkAction?.value as? String, "sample.com")
    }
    
    func testStyles_ReturnsLinkColor() {
        let markdown: NSString = "[A](www.sample.com)"
        
        let linkColor = element.styles(forMatch: markdown)
            .first { $0.attributeKey == .foregroundColor && $0.startIndex == 1 }

        XCTAssertEqual(linkColor?.value as? UIColor, self.linksColor)
        XCTAssertEqual(linkColor?.range, NSRange(location: 1, length: 1))
    }
    
    func testStyles_ReturnsIndicatorsColor() {
        let markdown: NSString = "[a](www.s.com)"
        
        let expectedRanges = [
            NSRange(location: 0, length: 1),
            NSRange(location: 2, length: 1),
            NSRange(location: 3, length: 1),
            NSRange(location: 13, length: 1)
        ]
        
        let expectedColors = expectedRanges.map { _ in self.symbolsColor }
        
        let styles = element.styles(forMatch: markdown)
            .filter { $0.attributeKey == .foregroundColor && $0.startIndex != 1 }
            .sorted(by: { $0.startIndex < $1.startIndex })
        
        XCTAssertEqual(styles.compactMap { $0.value as? UIColor }, expectedColors)
        XCTAssertEqual(styles.map { $0.range }, expectedRanges)
    }
    
    // MARK: - Replacement ranges
    func testReplacementRanges_ReturnValidRanges() {
        let markdown: NSString = "[a](sample.com)"
        let expectedRanges = [
            ReplacementRange(
                range: NSRange(location: 0, length: 1),
                replacementValue: NSAttributedString()
            ),
            ReplacementRange(
                range: NSRange(location: 2, length: 1),
                replacementValue: NSAttributedString()
            ),
            ReplacementRange(
                range: NSRange(location: 3, length: 12),
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
}
