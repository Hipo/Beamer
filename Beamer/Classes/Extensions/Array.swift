//
//  Array.swift
//  Beamer
//
//  Created by Omer Emre Aslan on 19.10.2018.
//

import Foundation

extension Array where Element: Equatable {
    mutating func remove(_ element: Element){
        if let index = self.index(of: element) {
            self.remove(at: index)
        }
    }
    
    private func index(of object: Element) -> Int? {
        for (index, element) in enumerated() {
            if element == object {
                return index
            }
        }
        return nil
    }
}
