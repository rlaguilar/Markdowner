//
//  MarkdownTextView.swift
//  Markdowner
//
//  Created by Reynaldo Aguilar on 7/21/18.
//

import Foundation

public class MarkdownTextView: UITextView {
    
    public var stylesConfiguration: StylesConfiguration {
        get { return markdownStorage.stylesConfiguration }
        set { markdownStorage.stylesConfiguration = newValue }
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
        
        if #available(iOS 10.0, *) {
            adjustsFontForContentSizeCategory = true
        } else {
            // Fallback on earlier versions
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func attributedString(removingMarkdownSymbols: Bool = true) -> NSAttributedString {
        return markdownStorage.attributedString(removingMarkdownSymbols: removingMarkdownSymbols)
    }
}
