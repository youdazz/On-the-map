//
//  UdacityClient.swift
//  On the Map
//
//  Created by Youda Zhou on 20/5/24.
//

import Foundation
class UdacityClient {
    
    struct Auth {
        static var accountId: String = ""
        static var sessionId: String = ""
        static var firstName: String = ""
        static var lastName: String = ""
    }
    
    enum Endpoints{
        static let base = "https://onthemap-api.udacity.com/v1"
        
        case login
        case studenLocations(String,String?)
        case logout
        case getUserPublicData
        case postUserInformation
        
        var stringValue: String {
            switch self {
            case .login: return Endpoints.base + "/session"
            case .studenLocations(let limit, let uniqueKey): return Endpoints.base + "/StudentLocation" + "?limit=\(limit)&order=-updatedAt&uniqueKey=\(uniqueKey ?? "")"
            case .logout: return Endpoints.base + "/session"
            case .getUserPublicData: return Endpoints.base + "/users/\(Auth.accountId)"
            case .postUserInformation: return Endpoints.base + "/StudentLocation"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    @discardableResult class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, hasControl: Bool = false, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask{
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            var newData: Data = data
            if hasControl {
                newData = data.subdata(in: 5..<(data.count))
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: newData)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(UdacityResponse.self, from: newData)
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
        
        return task
    }
    
    class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, body: RequestType, responseType: ResponseType.Type, hasControl: Bool = false, completion: @escaping (ResponseType?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-type")
        request.httpBody = try! JSONEncoder().encode(body)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            var newData: Data = data
            if hasControl {
                newData = data.subdata(in: 5..<(data.count))
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: newData)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(UdacityResponse.self, from: newData)
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
    }
    
    class func taskForDELETERequest(url: URL, body: Codable?, completion: @escaping() -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-type")
        if let body = body {
            request.httpBody = try! JSONEncoder().encode(body)
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                completion()
            }
        }
        task.resume()
    }
    
    class func login(username: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        let body = LoginRequest(udacity: UdacityLogin(username: username, password: password))
        taskForPOSTRequest(url: Endpoints.login.url, body: body, responseType: LoginResponse.self, hasControl: true) { response, error in
            if let response = response {
                Auth.sessionId = response.session.id
                Auth.accountId = response.account.key
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
    
    class func getStudenLocations(completion: @escaping ([StudentLocation], Error?) -> Void) {
        let limit = "100"
        taskForGETRequest(url: Endpoints.studenLocations(limit,nil).url, responseType: StudentLocationsResponse.self) { response, error in
            if let response = response {
                StudentInformationModel.studentInformation = .init(locations: response.results ?? [])
                completion(response.results ?? [], nil)
            } else {
                completion([], error)
            }
        }
    }
    
    class func getMyPinLocation(completion: @escaping (Bool, Error?) -> Void) {
        let limit = "1"
        taskForGETRequest(url: Endpoints.studenLocations(limit,Auth.accountId).url, responseType: StudentLocationsResponse.self) { response, error in
            if let response = response {
                StudentInformationModel.myPin = response.results?.first
                completion(true,nil)
            } else {
                completion(false, error)
            }
        }
    }
    
    class func logout(completion: @escaping () -> Void) {
        taskForDELETERequest(url: Endpoints.logout.url, body: nil) {
            completion()
        }
    }
    
    class func postUserInformation(mapString: String, mediaUrl: String, latitude: Float, longitude: Float, completion: @escaping (Bool, Error?) -> Void) {
        let body = PostStudentInformationRequest(uniqueKey: Auth.accountId, firstName: Auth.firstName, lastName: Auth.lastName, mapString: mapString, mediaURL: mediaUrl, latitude: latitude, longitude: longitude)
        taskForPOSTRequest(url: Endpoints.postUserInformation.url, body: body, responseType: PostStudentInformationResponse.self) { response, error in
            if response != nil {
                completion(true, nil)
            } else {
                completion(false,error)
            }
        }
    }
    
    class func getUserInformation(completion: @escaping (Bool, Error?) -> Void) {
        taskForGETRequest(url: Endpoints.getUserPublicData.url, responseType: UserDataResponse.self, hasControl: true) { response, error in
            if let response = response {
                Auth.firstName = response.firstName
                Auth.lastName = response.lastName
                completion(true, nil)
            } else {
                completion(false,error)
            }
        }
    }
}
