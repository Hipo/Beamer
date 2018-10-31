//
//  BeamerDatasource.swift
//  Beamer
//
//  Created by Omer Emre Aslan on 8.10.2018.
//

import Foundation

public protocol BeamerDatasource: class {
    func beamerRegistrationKey(_ beamer: Beamer) -> String
    func beamer(_ beamer: Beamer,
                handleWithInvalidCredential completion: ((AWSCredential)->Void)?)
}
