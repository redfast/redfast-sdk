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
            url: "https://github.com/redfast/redfast-sdk/releases/download/ios-swift-package/RedFast.xcframework.zip",
            checksum: "87b13b27604f40c8068ca825c7cf00de7474205e80816ffa3db81e31d9648ea7"
        ),
        .binaryTarget(
            name: "RedFast_TV",
            url: "https://github.com/redfast/redfast-sdk/releases/download/ios-swift-package/RedFast.xcframework.zip",
            checksum: "87b13b27604f40c8068ca825c7cf00de7474205e80816ffa3db81e31d9648ea7"
        )
    ]
)
