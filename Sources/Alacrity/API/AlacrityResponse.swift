//
//  AlacrityResponse.swift
//  
//
//  Created by Anderthan Hsieh on 3/3/24.
//

import Foundation

public struct AlacrityResponse<T> {
    public let data: T?
    public let error: String?
    
    init(data: T, error: String?) {
      self.data = data
      self.error = nil
    }
    
    init(data: T) {
      self.data = data
      self.error = nil
    }
    
    init(error: String? = nil) {
      self.data = nil
      self.error = error
    }
}
