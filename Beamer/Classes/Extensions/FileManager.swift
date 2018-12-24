//
//  FileManager.swift
//  Beamer
//
//  Created by Omer Emre Aslan on 5.09.2018.
//

import Foundation

extension FileManager {
    func directoryUrl(with name: String) -> URL? {
        guard let url = userDocumentDirectory() else {
            return nil
        }
        
        return url.appendingPathComponent(name, isDirectory: true)
    }
    
    func fileUrl(with name: String) -> URL? {
        guard let url = userDocumentDirectory() else {
            return nil
        }
        
        return url.appendingPathComponent(name)
    }
    
    func fileUrl(with name: String, inDirectory dirName: String? = nil) -> URL? {
        if let directoryName = dirName, let directoryUrl = directoryUrl(with: directoryName) {
            return directoryUrl.appendingPathComponent(name)
        }
        
        guard let url = userDocumentDirectory() else {
            return nil
        }
        
        return url.appendingPathComponent(name)
    }
    
    private func userDocumentDirectory() -> URL? {
        return urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    func createSavedDirectoryIfNotExists(directoryName: String) -> Bool {
        guard let directoryUrl = directoryUrl(with: directoryName) else {
            return false
        }
        
        var isDirectory = ObjCBool(true)
        
        if fileExists(atPath: directoryUrl.path, isDirectory: &isDirectory) {
            return true
        }
        
        do {
            try createDirectory(at: directoryUrl, withIntermediateDirectories: true, attributes: nil)
        } catch {
            return false
        }
        
        return true
    }
}


