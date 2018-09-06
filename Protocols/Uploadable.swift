//
//  Uploadable.swift
//  Beamer
//
//  Created by Omer Emre Aslan on 6.09.2018.
//

public protocol Uploadable {
    var identifier: String { get }
    var fileExtension: String { get }
}
