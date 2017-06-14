//
//  PlaceAPI.swift
//  longisland-pdx
//
//  Created by Jordan Carlson on 6/8/17.
//
//

import Foundation

class PlaceAPI {
    
    static func placesToDictionary(_ places: [Place]) -> [[String: Any]] {
        var placesJson: [[String: Any]] = []
        for row in places {
            placesJson.append(row.asDictionary())
        }
        return placesJson
    }
    
    static func allAsDictionary() throws -> [[String: Any]] {
        let places = try Place.all()
        return placesToDictionary(places)
    }
    
    static func allAsDictionaryMinimum(number: Int) throws -> [[String: Any]] {
        let places = try Place.getPlacesGreaterThan(minimumId: number)
        return placesToDictionary(places)
    }
    
    static func allMinimum(number: Int) throws -> String {
        return try allAsDictionaryMinimum(number: number).jsonEncodedString()
    }
    
    static func all() throws -> String {
        return try allAsDictionary().jsonEncodedString()
    }
    
    static func newPlace(withName name: String, longisland: Bool, rating: Int) throws -> [String: Any] {
        let place = Place()
        place.name = name
        place.longisland = longisland
        place.rating = rating
        try place.save { id in
            place.id = id as! Int
        }
        return place.asDictionary()
    }
    
    static func delete(id: Int) throws {
        let place = try Place.getPlace(matchingId: id)
        try place.delete()
    }
}
