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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

