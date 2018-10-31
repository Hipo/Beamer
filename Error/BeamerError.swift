//
//  BeamerError.swift
//  Beamer
//
//  Created by Omer Emre Aslan on 31.10.2018.
//

public enum BeamerError: Error {
    case cancelled
    case invalidAuthorization
    case userCancelled
    case unknown(message: String)
}
