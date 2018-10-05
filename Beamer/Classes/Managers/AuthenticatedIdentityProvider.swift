//
//  AuthenticatedIdentityProvider.swift
//  Beamer
//
//  Created by Omer Emre Aslan on 19.09.2018.
//

import AWSS3

class AuthenticatedIdentityProvider: AWSCognitoCredentialsProviderHelper {
    let awsCredential: AWSCredential

    init(awsCredential: AWSCredential) {
        self.awsCredential = awsCredential
        super.init(regionType: awsCredential.regionType,
                   identityPoolId: awsCredential.identityPoolID,
                   useEnhancedFlow: true,
                   identityProviderManager: nil)
    }
    
    override func token() -> AWSTask<NSString> {
        self.identityId = awsCredential.identityID
        
        return AWSTask<NSString>(result: NSString(string: awsCredential.token))
    }
}
