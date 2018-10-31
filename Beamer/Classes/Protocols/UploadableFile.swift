//
//  UploadableFile.swift
//  Beamer
//
//  Created by Omer Emre Aslan on 6.09.2018.
//

public enum ContentType: Codable {
    enum Key: CodingKey {
        case rawValue
        case associatedValue
    }
    
    enum CodingError: Error {
        case unknownValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        let rawValue = try container.decode(Int.self, forKey: .rawValue)
        switch rawValue {
        case 0:
            let type = try container.decode(String.self, forKey: .associatedValue)
            self = .image(type: type)
        case 1:
            let type = try container.decode(String.self, forKey: .associatedValue)
            self = .video(type: type)
        case 2:
            let contentType = try container.decode(String.self, forKey: .associatedValue)
            self = .custom(contentType: contentType)
        default:
            throw CodingError.unknownValue
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        switch self {
        case .image(let type):
            try container.encode(0, forKey: .rawValue)
            try container.encode(type, forKey: .associatedValue)
        case .video(let type):
            try container.encode(1, forKey: .rawValue)
            try container.encode(type, forKey: .associatedValue)
        case .custom(let contentType):
            try container.encode(2, forKey: .rawValue)
            try container.encode(contentType, forKey: .associatedValue)
        }
    }
    
    case image(type: String)
    case video(type: String)
    case custom(contentType: String)
}

public struct UploadableFile: Codable {
    let identifier: String
    let data: Data
    let contentType: ContentType
    var credential: AWSCredential?
    
    public init(identifier: String,
                data: Data,
                contentType: ContentType) {
        self.identifier = identifier
        self.data = data
        self.contentType = contentType
    }
    
    public func contentTypeStringRepresentation() -> String {
        switch contentType {
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
extension UploadableFile: Equatable {
    public static func == (lhs: UploadableFile, rhs: UploadableFile) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
