import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectMustache
import PostgresStORM
import PerfectTurnstilePostgreSQL
import PerfectRequestLogger
import TurnstilePerfect
import Foundation

let pturnstile = TurnstilePerfectRealm()

let server = HTTPServer()
server.serverPort = 8080
server.documentRoot = "webroot"

let env = ProcessInfo.processInfo.environment
PostgresConnector.host = env["POSTGRES_HOST"] ?? ""
PostgresConnector.username = env["POSTGRES_USER"] ?? ""
PostgresConnector.password = env["POSTGRES_PASSWORD"] ?? ""
PostgresConnector.database = env["POSTGRES_DB"] ?? ""

RequestLogFile.location = "./http_log.txt"

// Set up the Authentication table
let auth = AuthAccount()
try? auth.setup()

// Connect the AccessTokenStore
tokenStore = AccessTokenStore()
try? tokenStore?.setup()

// Register routes and handlers
let authWebRoutes = makeWebAuthRoutes()
let authJSONRoutes = makeJSONAuthRoutes("/api/v1")

// Add the routes to the server.
server.addRoutes(authWebRoutes)
server.addRoutes(authJSONRoutes)

// Adding a test route
var routes = Routes()
routes.add(method: .get, uri: "/api/v1/test", handler: AuthHandlersJSON.testHandler)
routes.add(method: .get, uri: "/logout", handler: AuthHandlersWeb.logoutHandler)

func getUser(matchingId id: String) throws -> AuthAccount {
    let getObj = AuthAccount()
    var findObj = [String: Any]()
    findObj["uniqueID"] = "\(id)"
    try getObj.find(findObj)
    return getObj
}

// An example route where authentication will be enforced
routes.add(method: .get, uri: "/api/v1/check", handler: {
    request, response in
    response.setHeader(.contentType, value: "application/json")
    
    var resp = [String: String]()
    resp["authenticated"] = "AUTHED: \(request.user.authenticated)"
    resp["authDetails"] = "DETAILS: \(request.user.authDetails)"
    
    do {
        try response.setBody(json: resp)
    } catch {
        print(error)
    }
    response.completed()
})



// An example route where auth will not be enforced
routes.add(method: .get, uri: "/api/v1/nocheck", handler: {
    request, response in
    response.setHeader(.contentType, value: "application/json")
    
    var resp = [String: String]()
    resp["authenticated"] = "AUTHED: \(request.user.authenticated)"
    resp["authDetails"] = "DETAILS: \(request.user.authDetails)"
    
    do {
        try response.setBody(json: resp)
    } catch {
        print(error)
    }
    response.completed()
})

// Add the routes to the server.
server.addRoutes(routes)

// Setup logging
let myLogger = RequestLogger()

// add routes to be checked for auth
var authenticationConfig = AuthenticationConfig()
authenticationConfig.include("/api/v1/check")
authenticationConfig.exclude("/api/v1/login")
authenticationConfig.exclude("/api/v1/register")

let authFilter = AuthFilter(authenticationConfig)

// Note that order matters when the filters are of the same priority level
server.setRequestFilters([pturnstile.requestFilter])
server.setResponseFilters([pturnstile.responseFilter])

server.setRequestFilters([(authFilter, .high)])

server.setRequestFilters([(myLogger, .high)])
server.setResponseFilters([(myLogger, .low)])


let setupObj = Place()
try? setupObj.setup()

let lip = LIPController()
server.addRoutes(Routes(lip.routes))

do {
    try server.start()
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}
