//
//  HTTPHeaders+Tools.swift
//  S3
//
//  Created by Ondrej Rafaj on 12/05/2018.
//

import Foundation
import Vapor
import NIO

extension HTTPHeaders {
    
    func string(_ name: String) -> String? {
        let header = HTTPHeaders.Name(name)
        return self[header].first
    }
    
    func int(_ name: String) -> Int? {
        guard let headerValue = string(name) else {
            return nil
        }
        return Int(headerValue)
    }
    
    func date(_ name: String) -> Date? {
        guard let headerValue = string(name) else {
            return nil
        }
        return ClientResponse.headerDateFormatter.date(from: headerValue)
    }
}
