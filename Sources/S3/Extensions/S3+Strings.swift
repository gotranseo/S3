//
//  S3+Strings.swift
//  S3
//
//  Created by Ondrej Rafaj on 01/12/2016.
//  Copyright © 2016 manGoweb UK Ltd. All rights reserved.
//

import Foundation
import Vapor


extension S3 {
    
    /// Upload file content to S3, full set
    public func put(string: String, mime: HTTPMediaType, destination: String, bucket: String?, access: AccessControlList) throws -> EventLoopFuture<File.Response> {
        guard let data: Data = string.data(using: String.Encoding.utf8) else {
            throw Error.badStringData
        }
        let file = File.Upload(data: data, bucket: bucket, destination: destination, access: access, mime: mime.description)
        return try put(file: file)
    }
    
    /// Upload file content to S3
    public func put(string: String, mime: HTTPMediaType, destination: String, access: AccessControlList) throws -> EventLoopFuture<File.Response> {
        return try put(string: string, mime: mime, destination: destination, bucket: nil, access: access)
    }
    
    /// Upload file content to S3
    public func put(string: String, destination: String, access: AccessControlList) throws -> EventLoopFuture<File.Response> {
        return try put(string: string, mime: .plainText, destination: destination, bucket: nil, access: access)
    }
    
    /// Upload file content to S3
    public func put(string: String, mime: HTTPMediaType, destination: String) throws -> EventLoopFuture<File.Response> {
        return try put(string: string, mime: mime, destination: destination, access: .privateAccess)
    }
    
    /// Upload file content to S3
    public func put(string: String, destination: String) throws -> EventLoopFuture<File.Response> {
        return try put(string: string, mime: .plainText, destination: destination, bucket: nil, access: .privateAccess)
    }
    
}
