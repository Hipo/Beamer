//
//  AWSCredential.swift
//  Beamer
//
//  Created by Omer Emre Aslan on 12.09.2018.
//

import AWSS3

public struct AWSCredential: Codable {
    var regionType: AWSRegionType
    var permission: AWSCredentialPermission
    var identityPoolID: String
    var token: String
    var identityID: String
    var providerName: String
    
    enum CodingKeys: CodingKey {
        case regionType
        case permission
        case identityPoolID
        case token
        case identityID
        case providerName
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(regionType.rawValue, forKey: .regionType)
        try container.encode(permission, forKey: .permission)
        try container.encode(identityPoolID, forKey: .identityPoolID)
        try container.encode(token, forKey: .token)
        try container.encode(identityID, forKey: .identityID)
        try container.encode(providerName, forKey: .providerName)
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        let regionTypeRawValue = try values.decode(Int.self, forKey: .regionType)
        if let regionType = AWSRegionType(rawValue: regionTypeRawValue) {
            self.regionType = regionType
        } else {
            self.regionType = .Unknown
        }
        
        permission = try values.decode(AWSCredentialPermission.self, forKey: .permission)
        identityPoolID = try values.decode(String.self, forKey: .identityPoolID)
        token = try values.decode(String.self, forKey: .token)
        identityID = try values.decode(String.self, forKey: .identityID)
        providerName = try values.decode(String.self, forKey: .providerName)
    }
}
