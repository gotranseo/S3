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
    public func list(bucket: String,
                     region: Region? = nil,
                     prefix: String? = nil,
                     headers: HTTPHeaders,
                     continuationToken: String? = nil,
                     delimiter: String? = nil
    ) throws -> EventLoopFuture<BucketResults> {
        let region = region ?? signer.config.region
        guard let baseUrl = URL(string: region.hostUrlString(bucket: bucket)), let host = baseUrl.host,
            var components = URLComponents(string: baseUrl.absoluteString) else {
            throw S3.Error.invalidUrl
        }
        components.queryItems = [
            URLQueryItem(name: "list-type", value: "2")
        ]
        if let continuationToken = continuationToken {
            components.queryItems?.append(URLQueryItem(name: "continuation-token", value: continuationToken))
        }
        if let prefix = prefix {
            components.queryItems?.append(URLQueryItem(name: "prefix", value: prefix))
        }
        if let delimiter = delimiter {
            components.queryItems?.append(URLQueryItem(name: "delimiter", value: delimiter))
        }
        guard let url = components.url else {
            throw S3.Error.invalidUrl
        }
        var headers = headers
        headers.replaceOrAdd(name: "host", value: host)
        let awsHeaders = try signer.headers(for: .GET, urlString: url, region: region, bucket: bucket, headers: headers, payload: .none)
        return try make(request: url, method: .GET, headers: awsHeaders, data: emptyData()).flatMapThrowing { response in
            try self.check(response)
            return try response.decode(to: BucketResults.self)
        }
    }
}
