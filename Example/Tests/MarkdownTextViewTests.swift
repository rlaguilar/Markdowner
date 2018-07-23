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
    var textView: MarkdownTextView = MarkdownTextView(frame: .zero)
    
    lazy var content: String = {
        let bundle = Bundle(for: type(of: self))
        let fileURL = bundle.url(forResource: "big-file", withExtension: "md")!
        return try! String(contentsOf: fileURL)
    }()
    
    override func setUp() {
        super.setUp()

        textView = MarkdownTextView(frame: .zero)
        _ = content
    }
    
    func testMarkdownRenderingPerformance() throws {
        self.measure {
            textView.text = content
        }
    }
    
    func testMarkdownFullPreviewPerformance() throws {
        textView.text = content
        
        self.measure {
            _ = textView.attributedString()
        }
    }
    
    func testMarkdownPartialPreviewPerformance() throws {
        textView.text = content
        
        self.measure {
            _ = textView.attributedString(removingMarkdownSymbols: false)
        }
    }
}
