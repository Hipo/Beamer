//
//  Uploadable.swift
//  Beamer
//
//  Created by Omer Emre Aslan on 6.09.2018.
//

public struct Uploadable: Codable {
    var identifier: String
    var fileExtension: String
    var data: Data
}
