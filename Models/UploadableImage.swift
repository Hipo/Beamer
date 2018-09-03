//
//  UploadableImage.swift
//  Beamer
//
//  Created by Omer Emre Aslan on 3.09.2018.
//

import Foundation

class UploadableImage: Uploadable {
    let identifier: String
    let fileExtension: String
    
    init(identifier: String, fileExtension: String) {
        self.identifier = identifier
        self.fileExtension = fileExtension
    }
}
