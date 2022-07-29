// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RedFast",
    platforms: [
        .iOS(.v13),
        .tvOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "RedFast",
            targets: ["RedFast"]),
        .library(
            name: "RedFast_TV",
            targets: ["RedFast_TV"])
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.5.0")),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.1"),
        .package(url: "https://github.com/mxcl/PromiseKit", from: "6.8.0"),
        
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .binaryTarget(
            name: "RedFast",
            url: "https://github.com/redfast/redfast-sdk/releases/download/1.0.17/RedFast.xcframework.zip",
            checksum: "db4a630f70b43b97efb721ce88b13972e24ed5bbdae93f943347bde7f59e6f8b"),
        .binaryTarget(
            name: "RedFast_TV",
            url: "https://github.com/redfast/redfast-sdk/releases/download/1.0.17/RedFast_TV.xcframework.zip",
            checksum: "03cd54698e71da2969cf1294701d342f2d9943d90fa1bba8ff8160a150108916"),
    ]
)
