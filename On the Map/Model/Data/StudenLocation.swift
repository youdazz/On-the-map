//
//  StudenLocation.swift
//  On the Map
//
//  Created by Youda Zhou on 20/5/24.
//

import Foundation

struct StudentLocation: Codable {
    let objectId: String
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let latitude: Float
    let longitude: Float
    let createdAt: String
    let updatedAt: String
}
