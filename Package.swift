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
            dependencies: ["Alamofire", "PromiseKit", "SwiftyJSON"],
            resources: [
                .process("Resources")
            ],
            url: "https://github.com/redfast/redfast-sdk/releases/download/1.0.14/RedFast.xcframework.zip",
            checksum: "c448a9368c11daad56a4b75c3e01a145f5e8cafdb6ff73eb3f1cc15178f6639a"),
        .binaryTarget(
            name: "RedFast_TV",
            dependencies: ["Alamofire", "PromiseKit", "SwiftyJSON"],
            resources: [
                .process("Resources")
            ],
            url: "https://github.com/redfast/redfast-sdk/releases/download/1.0.14/RedFast.xcframework.zip",
            checksum: "c448a9368c11daad56a4b75c3e01a145f5e8cafdb6ff73eb3f1cc15178f6639a"),
    ]
)
