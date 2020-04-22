//
//  S3+Copy.swift
//  S3
//
//  Created by Ondrej Rafaj on 23/10/2018.
//

import Foundation
import Vapor


extension S3 {
    
    // MARK: Move
    
    /// Copy file on S3
    public func move(file: LocationConvertible, to destination: LocationConvertible, headers: HTTPHeaders) throws -> EventLoopFuture<File.CopyResponse> {
        return try copy(file: file, to: destination, headers: headers).flatMap { copyResult -> EventLoopFuture<File.CopyResponse> in
            do {
                return try self.delete(file: file).map { _ in
                    return copyResult
                }
            } catch {
                return self.client.eventLoop.future(error: error)
            }
        }
    }
}
