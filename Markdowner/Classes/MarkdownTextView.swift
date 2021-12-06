//
//  MarkdownTextView.swift
//  Markdowner
//
//  Created by Reynaldo Aguilar on 7/21/18.
//

import Foundation

/// Custom text view class to display text as formatted markdown
open class MarkdownTextView: UITextView {
    public var elementsConfig: MarkdownElementsConfig {
        get { return markdownStorage.elementsConfig }
        set { markdownStorage.elementsConfig = newValue }
    }
    
    private let markdownStorage: MarkdownTextStorage
    
    public init(frame: CGRect) {
        let storage = MarkdownTextStorage()
        let layoutManager = NSLayoutManager()
        storage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer()
        layoutManager.addTextContainer(textContainer)
        self.markdownStorage = storage
        super.init(frame: frame, textContainer: textContainer)
        
        adjustsFontForContentSizeCategory = true
    }
    
    public required init?(coder aDecoder: NSCoder) {
        // This initializer isn't implemented because replacing the text storage of a text view
        // isn't working, even when the Apple docs state that it should be as simple as calling:
        // `markdownStorage.addLayoutManager(self.layoutManager)`
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Retrieves an attributted string containing a preview of the content displayed in the text view
    ///
    /// - Parameter removingMarkdownSymbols: If equal to `true`, markdown symbols will be removed
    ///   from the resultant preview.
    /// - Returns: Preview of the markdown rendered in the text view
    public func attributedString(removingMarkdownSymbols: Bool = true) -> NSAttributedString {
        return markdownStorage.attributedString(removingMarkdownSymbols: removingMarkdownSymbols)
    }
}
