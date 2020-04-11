//
//  S3.swift
//  S3
//
//  Created by Ondrej Rafaj on 01/12/2016.
//  Copyright © 2016 manGoweb UK Ltd. All rights reserved.
//

import Foundation
import Vapor
@_exported import S3Signer


/// Main S3 class
public class S3 {
    
    /// Error messages
    public enum Error: Swift.Error {
        case invalidUrl
        case errorResponse(HTTPResponseStatus, ErrorMessage)
        case badResponse(ClientResponse)
        case badStringData
        case missingData
        case notFound
        case s3NotRegistered
    }
    
    /// If set, this bucket name value will be used globally unless overriden by a specific call
    public internal(set) var defaultBucket: String
    
    /// Signer instance
    public let signer: S3Signer
    
    let client: Client
    
    // MARK: Initialization
    
    /// Basic initialization method, also registers S3Signer and self with services
    @discardableResult public convenience init(defaultBucket: String, config: S3Signer.Config, client: Client) throws {
        let signer = try S3Signer(config)
        try self.init(defaultBucket: defaultBucket, signer: signer, client: client)
    }
    
    /// Basic initialization method
    public init(defaultBucket: String, signer: S3Signer, client: Client) throws {
        self.defaultBucket = defaultBucket
        self.signer = signer
        self.client = client
    }
}

// MARK: - Helper methods

extension S3 {
    
    // QUESTION: Can we replace this with just Data()?
    /// Serve empty data
    func emptyData() -> Data {
        return Data("".utf8)
    }
    
    /// Check response for error
    @discardableResult func check(_ response: ClientResponse) throws -> ClientResponse {
        guard response.status == .ok || response.status == .noContent else {
            if let error = try? response.content.decode(ErrorMessage.self) {
                throw Error.errorResponse(response.status, error)
            } else {
                throw Error.badResponse(response)
            }
        }
        return response
    }
    
    /// Get mime type for file
    static func mimeType(forFileAtUrl url: URL) -> String {
        guard let mediaType = HTTPMediaType.fileExtension(url.pathExtension) else {
            return HTTPMediaType(type: "application", subType: "octet-stream").description
        }
        return mediaType.description
    }
    
    /// Get mime type for file
    func mimeType(forFileAtUrl url: URL) -> String {
        return S3.mimeType(forFileAtUrl: url)
    }
    
    /// Create URL builder
    func urlBuilder() -> URLBuilder {
        return S3URLBuilder(defaultBucket: defaultBucket, config: signer.config)
    }    
}

// Provider
extension Application {
    struct S3StorageKey: StorageKey {
        typealias Value = S3
    }
    
    var s3: S3 {
        get {
            guard let val = self.storage[S3StorageKey.self] else { fatalError("Register S3 in your configuration file") }
            return val
        }
        set {
            self.storage[S3StorageKey.self] = newValue
        }
    }
}

extension Request {
    var s3: S3 { self.application.s3 }
}
