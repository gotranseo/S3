//
//  S3+Service.swift
//  S3
//
//  Created by Ondrej Rafaj on 11/05/2018.
//

import Foundation
import Vapor
import XMLCoding


// Helper S3 extension for working with services
extension S3 {
    
    // MARK: Buckets
    
    /// Get list of buckets
    public func buckets() throws -> EventLoopFuture<BucketsInfo> {
        let builder = urlBuilder()
        let url = try builder.plain(region: nil)
        let headers = try signer.headers(for: .GET, urlString: url, headers: [:], payload: .none)
        return try make(request: url, method: .GET, headers: headers, data: emptyData()).flatMapThrowing { response -> BucketsInfo in
            try self.check(response)
            return try response.content.decode(BucketsInfo.self)
        }
    }
    
}
