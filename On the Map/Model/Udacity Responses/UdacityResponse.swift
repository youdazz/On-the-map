//
//  UdacityResponse.swift
//  On the Map
//
//  Created by Youda Zhou on 20/5/24.
//

import Foundation
struct UdacityResponse: Codable {
    let status: Int
    let error: String
}

extension UdacityResponse: LocalizedError {
    var errorDescription: String? {
        return error
    }
}
