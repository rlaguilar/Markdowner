//
//  MarkdownElement.swift
//  Markdowner
//
//  Created by Reynaldo Aguilar on 7/21/18.
//

import Foundation

/// Base class to describe markdown elements.
open class MarkdownElement {
    
    /// Regular expression used to match the markdown elements this object represents.
    public let regex: NSRegularExpression
    
    public init(regex: NSRegularExpression) {
        self.regex = regex
    }
    
    /// Compute the list of styles corresponding to a given match.
    ///
    /// - Parameter match: String value that represent a match of the regular expression corresponding to `self`.
    /// - Returns: The list of styles that correspond to the match.
    open func styles(forMatch match: String) -> [Style] {
        return []
    }
    
    /// Computes a new variation of `self` that will use the given `StylesConfiguration` as its base
    /// for syling purposes.
    ///
    /// - Parameter stylesConfiguration: Object that contains the base styles to use.
    /// - Returns: A variation of `self` that uses the given styles.
    open func applying(stylesConfiguration: StylesConfiguration) -> Self {
        return self
    }
    
    /// List of ranges that should be replaced from the match to prepare it for preview.
    ///
    /// - Parameter match: String value that represents a match of the regular expression corresponding to `self`.
    /// - Returns: The list of ranges that should be replaced from the match.
    open func replacementRanges(forMatch match: String) -> [ReplacementRange] {
        return []
    }
    
    /// Type used to model a single style to apply to a markdown element.
    public struct Style {
        
        /// Key corresponding to the property that the style modifies.
        public let attributeKey: NSAttributedStringKey
        
        /// Value to apply to the property to modify
        public let value: Any
        
        /// Index at which the style should start to be applied.
        public let startIndex: Int
        
        /// Number of characteres, starting at `startIndex`, on which the style should be applied.
        public let length: Int
        
        /// Range at which the style should be applied.
        public var range: NSRange {
            return NSRange(location: startIndex, length: length)
        }
        
        public init(attributeKey: NSAttributedStringKey, value: Any, startIndex: Int, length: Int) {
            self.attributeKey = attributeKey
            self.value = value
            self.startIndex = startIndex
            self.length = length
        }
    }
}
