//
//  S3+Private.swift
//  S3
//
//  Created by Ondrej Rafaj on 19/04/2018.
//

import Foundation
import Vapor

#if os(Linux)
    import FoundationNetworking
#endif

extension S3 {
    /// Make an S3 request
    func make(request url: URL, method: HTTPMethod, headers: HTTPHeaders, data: Data? = nil) throws -> EventLoopFuture<ClientResponse> {
        return self.client.send(method, headers: headers, to: URI(string: url.absoluteString)) { req in
            if let data = data {
                var buffer = ByteBufferAllocator().buffer(capacity: data.count)
                buffer.writeBytes(data)
                
                req.body = buffer
            }
        }
    }
}
