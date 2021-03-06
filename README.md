[![Build Status](https://travis-ci.com/lluuaapp/S3.svg?branch=tests)](https://travis-ci.com/lluuaapp/S3)

# S3 client for Vapor 3

## Functionality

- [x] Signing headers for any region
- [x] Listing buckets
- [x] Create bucket
- [x] Delete bucket
- [x] Locate bucket region
- [x] List objects
- [x] Upload file
- [x] Get file
- [x] Delete file
- [x] Copy file
- [x] Move file (copy then delete old one)
- [x] Object info (HEAD)
- [ ] Object info (ACL)
- [x] Parsing error responses

## Usage

Update dependencies and targets in Package.swift

```swift
dependencies: [
    ...
    .package(url: "https://github.com/LiveUI/S3.git", from: "3.0.0-RC3.2"),
],
targets: [
        .target(name: "App", dependencies: ["Vapor", "S3"]),
        ...
]
```

Run ```vapor update```

Register S3Client as a service in your configure method

```swift
try services.register(s3: S3Signer.Config(...), defaultBucket: "my-bucket")
```

to use a custom Minio server, use this Config/Region:

```
S3Signer.Config(accessKey: accessKey,
                secretKey: secretKey,
                region: Region(name: RegionName.usEast1,
                               hostName: "127.0.0.1:9000",
                               useTLS: false)
```

use S3Client

```swift
import S3

let s3 = try req.makeS3Client() // or req.make(S3Client.self) as? S3
s3.put(...)
s3.get(...)
s3.delete(...)
```

if you only want to use the signer

```swift
import S3Signer

let s3 = try req.makeS3Signer() // or req.make(S3Signer.self)
s3.headers(...)
```

### Available methods

```swift
/// S3 client Protocol
public protocol S3Client: Service {
    
    /// Get list of objects
    func buckets() throws -> EventLoopFuture<BucketsInfo>
    
    /// Create a bucket
    func create(bucket: String, region: Region?) throws -> EventLoopFuture<Void>
    
    /// Delete a bucket
    func delete(bucket: String, region: Region?) throws -> EventLoopFuture<Void>
    
    /// Get bucket location
    func location(bucket: String) throws -> EventLoopFuture<Region>
    
    /// Get list of objects
    func list(bucket: String, region: Region?) throws -> EventLoopFuture<BucketResults>
    
    /// Get list of objects
    func list(bucket: String, region: Region?, headers: HTTPHeaders) throws -> EventLoopFuture<BucketResults>
    
    /// Upload file to S3
    func put(file: File.Upload, headers: HTTPHeaders) throws -> EventLoopFuture<File.Response>
    
    /// Upload file to S3
    func put(file url: URL, destination: String, access: AccessControlList) throws -> EventLoopFuture<File.Response>
    
    /// Upload file to S3
    func put(file url: URL, destination: String, bucket: String?, access: AccessControlList) throws -> EventLoopFuture<File.Response>
    
    /// Upload file to S3
    func put(file path: String, destination: String, access: AccessControlList) throws -> EventLoopFuture<File.Response>
    
    /// Upload file to S3
    func put(file path: String, destination: String, bucket: String?, access: AccessControlList) throws -> EventLoopFuture<File.Response>
    
    /// Upload file to S3
    func put(string: String, destination: String) throws -> EventLoopFuture<File.Response>
    
    /// Upload file to S3
    func put(string: String, destination: String, access: AccessControlList) throws -> EventLoopFuture<File.Response>
    
    /// Upload file to S3
    func put(string: String, mime: HTTPMediaType, destination: String) throws -> EventLoopFuture<File.Response>
    
    /// Upload file to S3
    func put(string: String, mime: HTTPMediaType, destination: String, access: AccessControlList) throws -> EventLoopFuture<File.Response>
    
    /// Upload file to S3
    func put(string: String, mime: HTTPMediaType, destination: String, bucket: String?, access: AccessControlList) throws -> EventLoopFuture<File.Response>
    
    /// Retrieve file data from S3
    func get(fileInfo file: LocationConvertible) throws -> EventLoopFuture<File.Info>
    
    /// Retrieve file data from S3
    func get(fileInfo file: LocationConvertible, headers: HTTPHeaders) throws -> EventLoopFuture<File.Info>
    
    /// Retrieve file data from S3
    func get(file: LocationConvertible) throws -> EventLoopFuture<File.Response>
    
    /// Retrieve file data from S3
    func get(file: LocationConvertible, headers: HTTPHeaders) throws -> EventLoopFuture<File.Response>
    
    /// Delete file from S3
    func delete(file: LocationConvertible) throws -> EventLoopFuture<Void>
    
    /// Delete file from S3
    func delete(file: LocationConvertible, headers: HTTPHeaders) throws -> EventLoopFuture<Void>
}
```

### Example usage

```swift
public func routes(_ router: Router) throws {
    
    // Get all available buckets
    router.get("buckets")  { req -> EventLoopFuture<BucketsInfo> in
        let s3 = try req.makeS3Client()
        return try s3.buckets(on: req)
    }
    
    // Create new bucket
    router.put("bucket")  { req -> EventLoopFuture<String> in
        let s3 = try req.makeS3Client()
        return try s3.create(bucket: "api-created-bucket", region: .euCentral1, on: req).map(to: String.self) {
            return ":)"
            }.catchMap({ (error) -> (String) in
                if let error = error.s3ErrorMessage() {
                    return error.message
                }
                return ":("
            }
        )
    }
    
    // Locate bucket (get region)
    router.get("bucket/location")  { req -> EventLoopFuture<String> in
        let s3 = try req.makeS3Client()
        return try s3.location(bucket: "bucket-name", on: req).map(to: String.self) { region in
            return region.hostUrlString()
        }.catchMap({ (error) -> (String) in
                if let error = error as? S3.Error {
                    switch error {
                    case .errorResponse(_, let error):
                        return error.message
                    default:
                        return "S3 :("
                    }
                }
                return ":("
            }
        )
    }
    // Delete bucket
    router.delete("bucket")  { req -> EventLoopFuture<String> in
        let s3 = try req.makeS3Client()
        return try s3.delete(bucket: "api-created-bucket", region: .euCentral1, on: req).map(to: String.self) {
            return ":)"
            }.catchMap({ (error) -> (String) in
                if let error = error.s3ErrorMessage() {
                    return error.message
                }
                return ":("
                }
        )
    }
    
    // Get list of objects
    router.get("files")  { req -> EventLoopFuture<BucketResults> in
        let s3 = try req.makeS3Client()
        return try s3.list(bucket: "booststore", region: .usEast1, headers: [:], on: req).catchMap({ (error) -> (BucketResults) in
            if let error = error.s3ErrorMessage() {
                print(error.message)
            }
            throw error
        })
    }
    
    // Demonstrate work with files
    router.get("files/test") { req -> EventLoopFuture<String> in
        let string = "Content of my example file"
        
        let fileName = "file-hu.txt"
        
        let s3 = try req.makeS3Client()
        do {
            // Upload a file from string
            return try s3.put(string: string, destination: fileName, access: .publicRead, on: req).flatMap(to: String.self) { putResponse in
                print("PUT response:")
                print(putResponse)
                // Get the content of the newly uploaded file
                return try s3.get(file: fileName, on: req).flatMap(to: String.self) { getResponse in
                    print("GET response:")
                    print(getResponse)
                    print(String(data: getResponse.data, encoding: .utf8) ?? "Unknown content!")
                    // Get info about the file (HEAD)
                    return try s3.get(fileInfo: fileName, on: req).flatMap(to: String.self) { infoResponse in
                        print("HEAD/Info response:")
                        print(infoResponse)
                        // Delete the file
                        return try s3.delete(file: fileName, on: req).map() { response in
                            print("DELETE response:")
                            print(response)
                            let json = try JSONEncoder().encode(infoResponse)
                            return String(data: json, encoding: .utf8) ?? "Unknown content!"
                            }.catchMap({ error -> (String) in
                                if let error = error.s3ErrorMessage() {
                                    return error.message
                                }
                                return ":("
                            }
                        )
                    }
                }
            }
        } catch {
            print(error)
            fatalError()
        }
    }
}
```

## Support

Join our [Slack](http://bit.ly/2B0dEyt), channel <b>#help-boost</b> to ... well, get help :) 

## Einstore AppStore

Core package for <b>[Einstore](http://www.einstore.io)</b>, a completely open source enterprise AppStore written in Swift!
- Website: http://www.einstore.io
- Github: https://github.com/Einstore/Einstore

## Other core packages

* [EinstoreCore](https://github.com/Einstore/EinstoreCore/) - AppStore core module
* [ApiCore](https://github.com/LiveUI/ApiCore/) - API core module with users and team management
* [MailCore](https://github.com/LiveUI/MailCore/) - Mailing wrapper for multiple mailing services like MailGun, SendGrig or SMTP (coming)
* [DBCore](https://github.com/LiveUI/DbCore/) - Set of tools for work with PostgreSQL database
* [VaporTestTools](https://github.com/LiveUI/VaporTestTools) - Test tools and helpers for Vapor 3

## Code contributions

We love PR’s, we can’t get enough of them ... so if you have an interesting improvement, bug-fix or a new feature please don’t hesitate to get in touch. If you are not sure about something before you start the development you can always contact our dev and product team through our Slack.

## Credits

#### Author
Ondrej Rafaj (@rafiki270 on [Github](https://github.com/rafiki270), [Twitter](https://twitter.com/rafiki270), [LiveUI Slack](http://bit.ly/2B0dEyt) and [Vapor Slack](https://vapor.team/))

#### Thanks
Anthoni Castelli (@anthonycastelli on [Github](https://github.com/anthonycastelli), @anthony on [Vapor Slack](https://vapor.team/)) for his help on updating S3Signer for Vapor3

JustinM1 (@JustinM1 on [Github](https://github.com/JustinM1)) for his amazing original signer package

## License

See the LICENSE file for more info.
