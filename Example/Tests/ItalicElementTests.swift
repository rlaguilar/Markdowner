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
    let element = ItalicElement()
    
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
            "*m * **",
            "*o O match*_ n_",
            "T *one _value_ __"
        ]
        
        let expectedRanges: [[NSRange]] = [
            [.init(location: 0, length: 5), .init(location: 6, length: 3)],
            [.init(location: 0, length: 4), .init(location: 5, length: 2)],
            [.init(location: 0, length: 11), .init(location: 11, length: 4)],
            [.init(location: 7, length: 7), .init(location: 15, length: 2)]
        ]
        
        zip(samples, expectedRanges).forEach { (markdown, ranges) in
            let matches = element.regex.matches(in: markdown, options: [], range: markdown.range)
            
            XCTAssertEqual(matches.map { $0.range }, ranges, "Invalid output for: \(markdown)")
        }
    }
    
    // MARK: - Styles tests
    func testStyles_WhenCalled_ReturnsCustomFont() {
        let markdown = "*Hello*"
        
        let fontStyle = element.styles(forMatch: markdown).first { $0.attributeKey == .font }
        
        XCTAssertNotNil(fontStyle, "There should be a custom font")
        XCTAssertNotNil(fontStyle?.value as? UIFont, "Value for font key should be a font object")
        let styleRange = fontStyle.flatMap { NSRange(location: $0.startIndex, length: $0.length) }
        XCTAssertEqual(styleRange, markdown.range, "The font should be applied to all the string")
    }
}
