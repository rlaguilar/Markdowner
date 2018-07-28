//
//  ReplacementRange.swift
//  Markdowner
//
//  Created by Reynaldo Aguilar on 7/22/18.
//

import Foundation

/// Type used to model the ranges from a string that should be replaced when preparing it for
/// displaying as a markdown preview (i.e., without displaying the markdown symbols)
public struct ReplacementRange: Equatable {
    /// Range which content should be replaced
    let range: NSRange
    
    /// Value that will replace the content that's currently in the string at range `range`.
    let replacementValue: NSAttributedString
}
