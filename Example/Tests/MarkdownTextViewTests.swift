//
//  MarkdownTextViewTests.swift
//  Markdowner_Tests
//
//  Created by Reynaldo Aguilar on 7/22/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
@testable import Markdowner

class MarkdownTextViewTests: XCTestCase {
    func testMarkdownRenderingPerformance() throws {
        let textView = MarkdownTextView(frame: .zero)
        let bundle = Bundle(for: type(of: self))
        let fileURL = bundle.url(forResource: "big-file", withExtension: "md")!
        let content = try String(contentsOf: fileURL)
        
        self.measure {
            textView.text = content
        }
    }
}
