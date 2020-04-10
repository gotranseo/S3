//
//  S3+Delete.swift
//  S3
//
//  Created by Ondrej Rafaj on 11/05/2018.
//

import Foundation
import Vapor


// Helper S3 extension for deleting files by their URL/path
extension S3 {
    
    // MARK: Delete
    
    /// Delete file from S3
    public func delete(file: LocationConvertible, headers: HTTPHeaders) throws -> EventLoopFuture<Void> {
        let builder = urlBuilder()
        let url = try builder.url(file: file)
        
        let headers = try signer.headers(for: .DELETE, urlString: url, headers: headers, payload: .none)
        return try make(request: url, method: .DELETE, headers: headers, data: emptyData()).flatMapThrowing { response -> Void in
            try self.check(response)
            return Void()
        }
    }
    
    /// Delete file from S3
    public func delete(file: LocationConvertible) throws -> EventLoopFuture<Void> {
        return try delete(file: file, headers: [:])
    }
    
}
