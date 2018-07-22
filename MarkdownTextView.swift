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
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
