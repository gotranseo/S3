// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "S3",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        .library(name: "S3", targets: ["S3"]),
        .library(name: "S3Signer", targets: ["S3Signer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/gotranseo/XMLCoding.git", .branch("vapor4"))
    ],
    targets: [
        .target(name: "S3", dependencies: [
            .product(name: "Vapor", package: "vapor"),
            .target(name: "S3Signer"),
            .product(name: "XMLCoding", package: "XMLCoding"),
        ]),
        .target(name: "S3Signer", dependencies: [
            .product(name: "Vapor", package: "vapor")
        ])
    ]
)
