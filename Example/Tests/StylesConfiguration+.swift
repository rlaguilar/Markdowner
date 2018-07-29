//
//  StylesConfiguration+.swift
//  Markdowner_Example
//
//  Created by Reynaldo Aguilar on 7/23/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
@testable import Markdowner

extension StylesConfiguration {
    static func mockConfigurations() -> [StylesConfiguration] {
        return [
            StylesConfiguration(
                baseFont: UIFont.systemFont(ofSize: 10),
                textColor: .black,
                symbolsColor: .red,
                useDynamicType: true
            ),
            StylesConfiguration(
                baseFont: UIFont.systemFont(ofSize: 12),
                textColor: .gray,
                symbolsColor: .blue,
                useDynamicType: false
            )
        ]
    }
}
