//
//  Data+Extensions.swift
//  
//
//  Created by Anderthan Hsieh on 3/3/24.
//

import Foundation

extension Data {
    public func base64URLEncode() -> String {
        let base64 = self.base64EncodedString()
        let base64URL = base64
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        return base64URL
    }
}
