//
//  NetworkManager.swift
//  Beamer_Example
//
//  Created by Omer Emre Aslan on 4.10.2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import Alamofire
import Beamer
import SwiftyJSON
import AWSS3

class NetworkManager {
    typealias CompletionHandler = (((AWSCredential?, Error?) -> Void)?)
    
    func fetchAWSCredential(completionHandler: CompletionHandler) {
        
        let headers = [
            "Authorization": "***",
            "Cache-Control": "no-cache"
        ]
        
        Alamofire.request(
            "***",
            method: .get,
            headers: headers).responseJSON { response in
                guard let data = response.data else {
                    completionHandler?(nil, response.error)
                    return
                }
                
                do {
                    let jsonData = try JSON(data: data)
                    
                    let awsCredential = self.awsCredential(forJson: jsonData)
                    
                    completionHandler?(awsCredential, nil)
                } catch {
                    completionHandler?(nil, nil)
                }
        }
    }
    
    private func awsCredential(forJson json: JSON) -> AWSCredential? {
        let regionName = json["region_name"].stringValue
        let regionType = self.regionType(forName: regionName)
        let identityPoolId = json["identity_pool_id"].stringValue
        let identityId = json["identity_id"].stringValue
        let token = json["token"].stringValue
        let providerName = json["provider_name"].stringValue
        let bucketName = json["permission"]["s3"]["bucket_name"].stringValue
        let uploadPath = json["permission"]["s3"]["video_upload_path"].stringValue
        
        let awsCredentialPermission = AWSCredentialPermission(bucketName: bucketName,
                                                              uploadPath: uploadPath)
        
        let awsCredential = AWSCredential(
            regionType: regionType,
            permission: awsCredentialPermission,
            identityPoolID: identityPoolId,
            token: token,
            identityID: identityId,
            providerName: providerName)
        
        return awsCredential
    }
    
    private func regionType(forName regionName: String) -> AWSRegionType {
        var regionType: AWSRegionType = .Unknown
        switch regionName {
        case "us-east-1":
            regionType = .USEast1
            break
        case "us-east-2":
            regionType = .USEast2
            break
        case "us-west-1":
            regionType = .USWest1
            break
        case "us-west-2":
            regionType = .USWest2
            break
        case "ap-south-1":
            regionType = .APSouth1
            break
        case "ap-northeast-1":
            regionType = .APNortheast1
            break
        case "ap-northeast-2":
            regionType = .APNortheast2
            break
        case "ap-southeast-1":
            regionType = .APSoutheast1
            break
        case "ap-southeast-2":
            regionType = .APSoutheast2
            break
        case "ca-central-1":
            regionType = .CACentral1
            break
        case "cn-north-1":
            regionType = .CNNorth1
            break
        case "cn-northwest-1":
            regionType = .CNNorthWest1
            break
        case "eu-central-1":
            regionType = .EUCentral1
            break
        case "eu-west-1":
            regionType = .EUWest1
            break
        case "eu-west-2":
            regionType = .EUWest2
            break
        case "eu-west-3":
            regionType = .EUWest3
            break
        case "sa-east-1":
            regionType = .SAEast1
            break
        default:
            break
        }
        
        return regionType
    }
    
}
