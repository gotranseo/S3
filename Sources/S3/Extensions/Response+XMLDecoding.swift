//
//  Response+XMLDecoding.swift
//  S3
//
//  Created by Ondrej Rafaj on 11/05/2018.
//

import Foundation
import Vapor
import XMLCoding


extension ClientResponse {
    
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
    
    static var headerDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'"
        return formatter
    }()
    
    func decode<T>(to: T.Type) throws -> T where T: Decodable {
        guard let bod = self.body else {
            throw S3.Error.badResponse(self)
        }
        
        let data = Data(bod.readableBytesView)
        let decoder = XMLDecoder()
        decoder.dateDecodingStrategy = .formatted(ClientResponse.dateFormatter)
        return try decoder.decode(T.self, from: data)
    }
    
}
