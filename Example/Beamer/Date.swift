//
//  Date.swift
//  Beamer_Example
//
//  Created by Omer Emre Aslan on 3.12.2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation

extension Date {
    func prettyDescription() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        return dateFormatter.string(from: self)
    }
}
