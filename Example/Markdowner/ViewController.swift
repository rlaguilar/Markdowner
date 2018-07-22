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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let textView = MarkdownTextView(frame: wrapperView.bounds)
        wrapperView.addSubview(textView)
        textView.frame = wrapperView.bounds
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        textView.keyboardDismissMode = .onDrag
        
        guard let contentURL = Bundle.main.url(forResource: "sample", withExtension: "md") else {
            fatalError()
        }
        
        let content = try! String(contentsOf: contentURL)
        textView.text = content
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

