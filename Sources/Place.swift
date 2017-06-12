//
//  Place.swift
//  longisland-pdx
//
//  Created by Jordan Carlson on 6/8/17.
//
//

import Foundation
import StORM
import PostgresStORM
import PerfectLib

class Place: PostgresStORM {
    
    var id: Int = 0
    var name: String = ""
    var longisland: Bool = false
    var rating: Int = 0
    
    override open func table() -> String { return "places" }
    
    override func to(_ this: StORMRow) {
        id = this.data["id"] as? Int ?? 0
        name = this.data["name"] as? String ?? ""
        longisland = this.data["longisland"] as? Bool ?? false
        rating = this.data["rating"] as? Int ?? 0
    }
    
    func rows() -> [Place] {
        var rows = [Place]()
        for i in 0..<self.results.rows.count {
            let row = Place()
            row.to(results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func asDictionary() -> [String: Any] {
        return [
            "id": self.id,
            "name": self.name,
            "longisland": self.longisland,
            "rating": self.rating
        ]
    }
    
    static func all() throws -> [Place] {
        let getObj = Place()
        try getObj.findAll()
        return getObj.rows()
    }
    
    static func getPlace(matchingId id: Int) throws -> Place {
        let getObj = Place()
        var findObj = [String: Any]()
        findObj["id"] = "\(id)"
        try getObj.find(findObj)
        return getObj
    }
}

extension Place: JSONConvertible {
    func jsonEncodedString() throws -> String {
        return try asDictionary().jsonEncodedString()
    }
}
