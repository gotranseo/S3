//
//  S3+Bucket.swift
//  S3
//
//  Created by Ondrej Rafaj on 11/05/2018.
//

import Foundation
import Vapor
import S3Signer


// Helper S3 extension for working with buckets
extension S3 {
    
    // MARK: Buckets
    
    /// Get bucket location
    public func location(bucket: String) throws -> EventLoopFuture<Region> {
        let builder = urlBuilder()
        let region = Region.euWest2
        let url = try builder.url(region: region, bucket: bucket, path: nil)
        
        let awsHeaders = try signer.headers(for: .GET, urlString: url, region: region, bucket: bucket, headers: [:], payload: .none)
        return try make(request: url, method: .GET, headers: awsHeaders, data: emptyData()).flatMapThrowing { response in
            if response.status == .notFound {
                throw Error.notFound
            }
            if response.status == .ok {
                return region
            } else {
                if let error = try? response.decode(to: ErrorMessage.self), error.code == "PermanentRedirect", let endpoint = error.endpoint {
                    if endpoint == "s3.amazonaws.com" {
                        return Region.usEast1
                    } else {
                        // Split bucket.s3.region.amazonaws.com into parts
                        // Drop .com and .amazonaws
                        // Get region (last part)
                        guard let regionString = endpoint.split(separator: ".").dropLast(2).last?.lowercased() else {
                            throw Error.badResponse(response)
                        }
                        return Region(name: .init(regionString))
                    }
                } else {
                    throw Error.badResponse(response)
                }
            }
        }
    }
    
    /// Delete bucket
    public func delete(bucket: String, region: Region? = nil) throws -> EventLoopFuture<Void> {
        let builder = urlBuilder()
        let url = try builder.url(region: region, bucket: bucket, path: nil)
        
        let awsHeaders = try signer.headers(for: .DELETE, urlString: url, region: region, bucket: bucket, headers: [:], payload: .none)
        return try make(request: url, method: .DELETE, headers: awsHeaders, data: emptyData()).flatMapThrowing { response in
            try self.check(response)
            return Void()
        }
    }
    
    /// Create a bucket
    public func create(bucket: String, region: Region? = nil) throws -> EventLoopFuture<Void> {
        let region = region ?? signer.config.region
        
        let builder = urlBuilder()
        let url = try builder.url(region: region, bucket: bucket, path: nil)
        
        let content = """
            <CreateBucketConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
                <LocationConstraint>\(region.name)</LocationConstraint>
            </CreateBucketConfiguration>
            """
        
        let data = Data(content.utf8)
        let awsHeaders = try signer.headers(for: .PUT, urlString: url, region: region, bucket: bucket, headers: [:], payload: .bytes(data))
        return try make(request: url, method: .PUT, headers: awsHeaders, data: data).flatMapThrowing { response in
            try self.check(response)
            return Void()
        }
    }
}
