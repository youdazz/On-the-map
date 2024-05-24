//
//  StudentInformation.swift
//  On the Map
//
//  Created by Youda Zhou on 20/5/24.
//

import Foundation
struct StudentInformation: Codable {
    var locations: [StudentLocation]
    
    init(locations: [StudentLocation]) {
        self.locations = locations
    }
}
