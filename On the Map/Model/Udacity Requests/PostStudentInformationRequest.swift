//
//  PostStudentInformationRequest.swift
//  On the Map
//
//  Created by Youda Zhou on 24/5/24.
//

import Foundation
struct PostStudentInformationRequest: Codable {
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let latitude: Float
    let longitude: Float
}
