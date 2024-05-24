//
//  UserDataResponse.swift
//  On the Map
//
//  Created by Youda Zhou on 24/5/24.
//

import Foundation
struct UserDataResponse: Codable {
    let lastName: String
    let firstName: String
    
    enum CodingKeys: String, CodingKey {
        case lastName = "last_name"
        case firstName = "first_name"
    }
}
