//
//  BeamerObserver.swift
//  Beamer
//
//  Created by Omer Emre Aslan on 12.09.2018.
//

import Foundation

public protocol BeamerObserver: class {
    func beamer(_ beamer: Beamer,
                didStart uploadFile: Uploadable)
    func beamer(_ beamer: Beamer,
                didUpdate progress: Float,
                uploadFile: Uploadable)
    func beamer(_ beamer: Beamer,
                didFinish uploadFile: Uploadable,
                at index: Int)
    func beamer(_ beamer: Beamer,
                didFail uploadFile: Uploadable,
                at index: Int,
                error: BeamerError)
    func beamer(_ beamer: Beamer,
                didStop uploadFile: Uploadable,
                at index: Int)
}
