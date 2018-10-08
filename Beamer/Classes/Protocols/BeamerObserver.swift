//
//  BeamerObserver.swift
//  Beamer
//
//  Created by Omer Emre Aslan on 12.09.2018.
//

import Foundation

public protocol BeamerObserver: class {
    func beamer(_ beamer: Beamer,
                didStart uploadFile: UploadableFile)
    func beamer(_ beamer: Beamer,
                didUpdate progress: Float,
                uploadFile: UploadableFile)
    func beamer(_ beamer: Beamer,
                didFinish uploadFile: UploadableFile)
    func beamer(_ beamer: Beamer,
                didFail uploadFile: UploadableFile,
                error: Error)
}
