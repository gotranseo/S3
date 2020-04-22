//
//  S3+List.swift
//  S3
//
//  Created by Ondrej Rafaj on 12/05/2018.
//

import Foundation


// Helper S3 extension for getting file indexes
extension S3 {
    
    /// Get list of objects
    public func list(bucket: String, region: Region? = nil, headers: HTTPHeaders) throws -> EventLoopFuture<BucketResults> {
        let region = region ?? signer.config.region
        guard let baseUrl = URL(string: region.hostUrlString(bucket: bucket)), let host = baseUrl.host,
            var components = URLComponents(string: baseUrl.absoluteString) else {
            throw S3.Error.invalidUrl
        }
        components.queryItems = [
            URLQueryItem(name: "list-type", value: "2")
        ]
        guard let url = components.url else {
            throw S3.Error.invalidUrl
        }
        var headers = headers
        headers.replaceOrAdd(name: "host", value: host)
        let awsHeaders = try signer.headers(for: .GET, urlString: url, region: region, bucket: bucket, headers: headers, payload: .none)
        return try make(request: url, method: .GET, headers: awsHeaders, data: emptyData()).flatMapThrowing { response -> BucketResults in
            try self.check(response)
            return try response.decode(to: BucketResults.self)
        }
    }
    
    /// Get list of objects
    public func list(bucket: String, region: Region? = nil) throws -> EventLoopFuture<BucketResults> {
        return try list(bucket: bucket, region: region, headers: [:])
    }
    
}
