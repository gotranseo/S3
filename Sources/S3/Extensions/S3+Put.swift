//
//  S3+Put.swift
//  S3
//
//  Created by Ondrej Rafaj on 01/12/2016.
//  Copyright © 2016 manGoweb UK Ltd. All rights reserved.
//

import Foundation
import Vapor


// Helper S3 extension for uploading files by their URL/path
extension S3 {
    
    // MARK: Upload
    
    /// Upload file to S3
    public func put(file: File.Upload, headers: HTTPHeaders) throws -> EventLoopFuture<File.Response> {
        let builder = urlBuilder()
        let url = try builder.url(file: file)
        var awsheaders: HTTPHeaders = headers
        awsheaders.replaceOrAdd(name: "content-type", value: file.mime.description)
        awsheaders.replaceOrAdd(name: "x-amz-acl", value: file.access.rawValue)
        let headers = try signer.headers(for: .PUT, urlString: url, headers: awsheaders, payload: Payload.bytes(file.data))
        
        return self.client.put(URI(string: url.absoluteString), headers: headers) { req in
            var buffer = ByteBufferAllocator().buffer(capacity: file.data.count)
            buffer.writeBytes(file.data)
            
            req.body = buffer
        }.flatMapThrowing { response -> File.Response in
            try self.check(response)
            let res = File.Response(data: file.data, bucket: file.bucket ?? self.defaultBucket, path: file.path, access: file.access, mime: file.mime)
            return res
        }
    }
    
    /// Upload file to S3
    public func put(file: File.Upload) throws -> EventLoopFuture<File.Response> {
        return try put(file: file, headers: [:])
    }
    
    /// Upload file by it's URL to S3
    public func put(file url: URL, destination: String, access: AccessControlList = .privateAccess) throws -> EventLoopFuture<File.Response> {
        let data: Data = try Data(contentsOf: url)
        let file = File.Upload(data: data, bucket: nil, destination: destination, access: access, mime: mimeType(forFileAtUrl: url))
        return try put(file: file)
    }
    
    /// Upload file by it's path to S3
    public func put(file path: String, destination: String, access: AccessControlList = .privateAccess) throws -> EventLoopFuture<File.Response> {
        let url: URL = URL(fileURLWithPath: path)
        return try put(file: url, destination: destination, bucket: nil, access: access)
    }
    
    /// Upload file by it's URL to S3, full set
    public func put(file url: URL, destination: String, bucket: String?, access: AccessControlList = .privateAccess) throws -> EventLoopFuture<File.Response> {
        let data: Data = try Data(contentsOf: url)
        let file = File.Upload(data: data, bucket: bucket, destination: destination, access: access, mime: mimeType(forFileAtUrl: url))
        return try put(file: file)
    }
    
    /// Upload file by it's path to S3, full set
    public func put(file path: String, destination: String, bucket: String?, access: AccessControlList = .privateAccess) throws -> EventLoopFuture<File.Response> {
        let url: URL = URL(fileURLWithPath: path)
        return try put(file: url, destination: destination, bucket: bucket, access: access)
    }
}
