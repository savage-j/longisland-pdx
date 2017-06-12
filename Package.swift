import PackageDescription

let package = Package(
    name: "longisland-pdx",
    dependencies: [
    .Package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", majorVersion: 2, minor: 1),
    .Package(url: "https://github.com/SwiftORM/Postgres-StORM.git", majorVersion: 1),
    .Package(url: "https://github.com/PerfectlySoft/Perfect-Mustache.git", majorVersion: 2),
    .Package(url: "https://github.com/PerfectlySoft/Perfect-RequestLogger.git", majorVersion: 1, minor: 0),
    .Package(url: "https://github.com/PerfectlySoft/Perfect-Turnstile-PostgreSQL.git",majorVersion: 1, minor: 0)
        
    ]
)
