//
//  BeamerObserver.swift
//  Beamer
//
//  Created by Omer Emre Aslan on 12.09.2018.
//

import Foundation

public protocol BeamerObserver: class {
    func beamer(_ beamer: Beamer,
                didStart uploadTask: UploadTask)
    func beamer(_ beamer: Beamer,
                didUpdate progress: Float,
                uploadTask: UploadTask)
    func beamer(_ beamer: Beamer,
                didFinish uploadTask: UploadTask)
    func beamer(_ beamer: Beamer,
                didFail uploadTask: UploadTask,
                error: Error)
}
