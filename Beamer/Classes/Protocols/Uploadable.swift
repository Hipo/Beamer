//
//  Uploadable.swift
//  Beamer
//
//  Created by Omer Emre Aslan on 6.09.2018.
//

public class Uploadable: Codable {
    public let identifier: String
    var credential: AWSCredential?
    public let file: File
    internal(set) public var progress: Float = 0.0
    
    public init(identifier: String,
                file: File) {
        self.identifier = identifier
        self.file = file
    }
    
    public func contentTypeStringRepresentation() -> String {
        switch file.contentType {
        case .image(let type):
            return "image/\(type)"
        case .video(let type):
            return "video/\(type)"
        case .custom(let contentType):
            return contentType
        }
    }
}

//MARK: - Equatable
extension Uploadable: Equatable {
    public static func == (lhs: Uploadable, rhs: Uploadable) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
