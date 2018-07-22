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
    let element = HeaderElement()
    
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
    
    // MARK: - Styles tests
    func testStyles_WhenCalled_ReturnsCorrectFontSize() {
        let samples = [
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
            XCTAssertNotNil(font, "Unable to retrieve font from style")
            XCTAssertEqual(font?.pointSize, level.fontSize, "Font size doesn't match")
        }
    }
    
    func testStyles_WhenCalled_ReturnsCorrectForegroundColor() {
        let samples = [
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
}
