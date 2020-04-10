//
//  S3+Copy.swift
//  S3
//
//  Created by Topic, Zdenek on 17/10/2018.
//

import Foundation
import Vapor


extension S3 {
    
    // MARK: Copy
    
    /// Copy file on S3
    public func copy(file: LocationConvertible, to: LocationConvertible, headers: HTTPHeaders) throws -> EventLoopFuture<File.CopyResponse> {
        let builder = urlBuilder()
        let originPath = "\(file.bucket ?? defaultBucket)/\(file.path)"
        let destinationUrl = try builder.url(file: to)
        
        var awsheaders: HTTPHeaders = headers
        awsheaders.replaceOrAdd(name: "x-amz-copy-source", value: originPath)
        let headers = try signer.headers(
            for: .PUT,
            urlString: destinationUrl,
            headers: awsheaders,
            payload: .none
        )

        return self.client.put(URI(string: destinationUrl.absoluteString), headers: headers) { req in
            var buffer = ByteBufferAllocator().buffer(capacity: Data().count)
            buffer.writeBytes(Data())
            
            req.body = buffer
        }.flatMapThrowing { response in
            try self.check(response)
            return try response.content.decode(File.CopyResponse.self)
        }
    }
}
