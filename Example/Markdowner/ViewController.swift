//
//  ViewController.swift
//  Markdowner
//
//  Created by rlaguilar on 07/21/2018.
//  Copyright (c) 2018 rlaguilar. All rights reserved.
//

import UIKit
import Markdowner

class ViewController: UIViewController {
    @IBOutlet weak var wrapperView: UIView!
    
    lazy var textView = MarkdownTextView(frame: wrapperView.bounds)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wrapperView.addSubview(textView)
        textView.frame = wrapperView.bounds
        textView.backgroundColor = .clear
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        textView.keyboardDismissMode = .onDrag
        
        guard let contentURL = Bundle.main.url(forResource: "sample", withExtension: "md") else {
            fatalError()
        }
        
        let content = try! String(contentsOf: contentURL)
        
        textView.text = content
        self.textView.elementsConfig = MarkdownElementsConfig.defaultConfig().overriding(
            style: StylesConfiguration(
                baseFont: UIFont.systemFont(ofSize: 18),
                textColor: UIColor.darkGray,
                symbolsColor: UIColor.red,
                useDynamicType: true
            )
        )
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let previewVC = segue.destination as? PreviewViewController {
            previewVC.markdownContent = textView.attributedString()
        }
    }
}
