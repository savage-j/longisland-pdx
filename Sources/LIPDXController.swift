//
//  LIPDXController.swift
//  longisland-pdx
//
//  Created by Jordan Carlson on 6/8/17.
//
//

import Foundation
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectMustache
import TurnstilePerfect
import PerfectTurnstilePostgreSQL

final class LIPController {

    var routes: [Route] {
        return [
            // Web page routes
            Route(method: .get, uri: "/", handler: indexView),
            Route(method: .post, uri: "/", handler: addPlace),
            Route(method: .post, uri: "/{id}/delete", handler: deletePlace),
            
            // iOS routes
            Route(method: .get, uri: "/api/v1/places", handler: getPlaces),
            Route(method: .get, uri: "/api/v1/places/{id}", handler: getPlacesMinID)
        ]
    }

    //MARK: - Web page handlers
    func indexView(request: HTTPRequest, response: HTTPResponse) {
        do {
            var values = MustacheEvaluationContext.MapType()
            values["places"] = try PlaceAPI.allAsDictionary()
            values["accountID"] = request.user.authDetails?.account.uniqueID ?? ""
            values["authenticated"] = request.user.authenticated
            values["username"] = try getUser(matchingId: request.user.authDetails?.account.uniqueID ?? "").username
            values["delete"] = try getUser(matchingId: request.user.authDetails?.account.uniqueID ?? "").username == "savagej" ? true : false

            mustacheRequest(request: request, response: response, handler: MustacheHelper(values: values), templatePath: request.documentRoot + "/views/index.mustache")
        } catch {
            response.setBody(string: "Error handling request: \(error)")
                .completed(status: .internalServerError)
        }
    }
    
    func addPlace(request: HTTPRequest, response: HTTPResponse) {
        do {
            guard let name = request.param(name: "name"), let longisland = request.param(name: "longisland") else {
                response.completed(status: .badRequest)
                return
            }
            var rating = 0

            if let ratingString = request.param(name: "rating") {
                rating = Int(ratingString)!
            }
            
            let hasLongIsland = longisland == "true" ? true : false

            _ = try PlaceAPI.newPlace(withName: name, longisland: hasLongIsland, rating: rating)
            response.setHeader(.location, value: "/")
                .completed(status: .movedPermanently)
        } catch {
            response.setBody(string: "Error handling request: \(error)")
                .completed(status: .internalServerError)
        }
    }

    func deletePlace(request: HTTPRequest, response: HTTPResponse) {
        do {
            guard let idString = request.urlVariables["id"],
                let id = Int(idString) else {
                    response.completed(status: .badRequest)
                    return
            }

            try PlaceAPI.delete(id: id)
            response.setHeader(.location, value: "/")
                .completed(status: .movedPermanently)
        } catch {
            response.setBody(string: "Error handling request: \(error)")
                .completed(status: .internalServerError)
        }
    }
    
    // retrieve current user 
    func getUser(matchingId id: String) throws -> AuthAccount {
        let getObj = AuthAccount()
        var findObj = [String: Any]()
        findObj["uniqueID"] = "\(id)"
        try getObj.find(findObj)
        return getObj
    }
    
    //MARK: - iOS handlers
    
    func getPlaces(request: HTTPRequest, response: HTTPResponse) {
        response.setHeader(.contentType, value: "application/json")
        
        var resp = [String: Any]()
        
        do {
            resp["places"] = try PlaceAPI.allAsDictionary()
            try response.setBody(json: resp)
        } catch {
            print(error)
        }
        response.completed()
    }
    
    func getPlacesMinID(request: HTTPRequest, response: HTTPResponse) {
        response.setHeader(.contentType, value: "application/json")
        
        var resp = [String: Any]()
        do {
            guard let idString = request.urlVariables["id"],
                let id = Int(idString) else {
                    response.completed(status: .badRequest)
                    return
            }
            resp["places"] = try PlaceAPI.allAsDictionaryFromMinimum(number: id)
            try response.setBody(json: resp)
            
        } catch {
            print(error)
        }
        response.completed()
        
    }
}
