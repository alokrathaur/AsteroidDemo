//
//  Model.swift
//  AsteroidGraphApp
//
//  Created by ALOK on 24/11/22.
//


// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let socketMsg = try? newJSONDecoder().decode(SocketMsg.self, from: jsonData)

import Foundation

// MARK: - SocketMsg
struct SocketMsg: Codable {
    let links: SocketMsgLinks?
    let element_count: Int?
    let near_earth_objects: [String: [NearEarthObject]]?

    enum CodingKeys: String, CodingKey {
        case links
        case element_count
        case near_earth_objects
    }
}

// MARK: - SocketMsgLinks
struct SocketMsgLinks: Codable {
    let next, previous, linksSelf: String?

    enum CodingKeys: String, CodingKey {
        case next, previous
        case linksSelf
    }
}

// MARK: - NearEarthObject
struct NearEarthObject: Codable {
    let links: NearEarthObjectLinks?
    let id, neo_reference_id, name: String?
    let nasa_jpl_url: String?
    let absolute_magnitude_h: Double?
    let estimated_diameter: EstimatedDiameter?
    let is_potentially_hazardous_asteroid: Bool?
    let close_approach_data: [CloseApproachDatum]?
    let is_sentry_object: Bool?

    enum CodingKeys: String, CodingKey {
        case links, id
        case neo_reference_id
        case name
        case nasa_jpl_url
        case absolute_magnitude_h
        case estimated_diameter
        case is_potentially_hazardous_asteroid
        case close_approach_data
        case is_sentry_object
    }
}

// MARK: - CloseApproachDatum
struct CloseApproachDatum: Codable {
    let close_approach_date, close_approach_date_full: String?
    let epoch_date_close_approach: Int?
    let relative_velocity: RelativeVelocity?
    let miss_distance: MissDistance?
    let orbiting_body: OrbitingBody?

    enum CodingKeys: String, CodingKey {
        case close_approach_date
        case close_approach_date_full
        case epoch_date_close_approach
        case relative_velocity
        case miss_distance
        case orbiting_body
    }
}

// MARK: - MissDistance
struct MissDistance: Codable {
    let astronomical, lunar, kilometers, miles: String?
}

enum OrbitingBody: String, Codable {
    case earth = "Earth"
}

// MARK: - RelativeVelocity
struct RelativeVelocity: Codable {
    let kilometers_per_second, kilometers_per_hour, miles_per_hour: String?

    enum CodingKeys: String, CodingKey {
        case kilometers_per_second
        case kilometers_per_hour
        case miles_per_hour
    }
}

// MARK: - EstimatedDiameter
struct EstimatedDiameter: Codable {
    let kilometers, meters, miles, feet: Feet?
}

// MARK: - Feet
struct Feet: Codable {
    let estimated_diameter_min, estimated_diameter_max: Double?

    enum CodingKeys: String, CodingKey {
        case estimated_diameter_min
        case estimated_diameter_max
    }
}

// MARK: - NearEarthObjectLinks
struct NearEarthObjectLinks: Codable {
    let linksSelf: String?

    enum CodingKeys: String, CodingKey {
        case linksSelf
    }
}
