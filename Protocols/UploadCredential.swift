//
//  UploadCredential.swift
//  Beamer
//
//  Created by Omer Emre Aslan on 6.09.2018.
//

protocol UploadCredential {
    var url: URL { get }
    var httpHeaders: [String: String]? { get }
    var httpMethod: String { get }
    var timeInterval: TimeInterval { get }
}
