//
//  DressTimeClient.swift
//  DressTime
//
//  Created by Fab on 10/8/16.
//  Copyright © 2016 Fab. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreLocation
import FBSDKCoreKit
import FBSDKLoginKit

enum DressTimeError: Error {
    case authenticationError
    case unauthorizedError
    case jsonContentError(String)
    case accountVerificationError
    case validationDataError(String)
    case duplicateAccountError(String)
}

enum DressTimeResult<T> {
    case success(T)
    case failure(DressTimeError)
}

struct OutfitOfTheDayResult {
    var outfits: [Outfit]!
    var weather: Weather!
}

struct DressTimeURLS {
    static let uploadImageURL                   = URL(string:"\(DressTimeClient.baseURL)dressing/clothes/image/")!
    static let clotheURL                        = URL(string: "\(DressTimeClient.baseURL)dressing/clothes/")!
    static let clotheIdsURL                     = URL(string: "\(DressTimeClient.baseURL)dressing/clothesIds/")!
    static let outfitURL                        = URL(string: "\(DressTimeClient.baseURL)outfits/")!
    static let outfitOfTheDayURL                = URL(string: "\(DressTimeClient.baseURL)outfits/OOTD")!
    static let outfitPutOnURL                   = URL(string: "\(DressTimeClient.baseURL)outfits/outfitsPutOn")!
    static let oAuthURL                         = URL(string: "\(DressTimeClient.baseURL)oauth/")!
    static let tokenURL                         = URL(string: "\(DressTimeClient.baseURL)oauth/token")!
    static let logoutURL                        = URL(string: "\(DressTimeClient.baseURL)oauth/logout")!
    static let verificationEmailURL             = URL(string: "\(DressTimeClient.baseURL)oauth/email/")!
    static let authorizationURL                 = URL(string: "\(DressTimeClient.baseURL)auth/")!
    static let userURL                          = URL(string: "\(DressTimeClient.baseURL)users/")!
    static let registrationURL                  = URL(string: "\(DressTimeClient.baseURL)auth/registration")!
}

class DressTimeClient: NSObject {
    static let clientId = "android"
    static let grantTypePassword = "password"
    static let grantTypeRefresh = "refresh_token"
    static let clientSecret = "SomeRandomCharsAndNumbers"
    
    #if (arch(i386) || arch(x86_64)) && os(iOS)
    static let baseURL = PListReader.getStringProperty("serverURLDebug")
    #else
    static let baseURL = PListReader.getStringProperty("serverURL")
    #endif
    
    
    // MARK: - Public Methods Authentication
    func fetchLoginWithCompletion(with login: String, password: String, withCompletion completion: @escaping(DressTimeResult<JSON>) -> Void){
        let parameters = [
            "grant_type" : DressTimeClient.grantTypePassword,
            "client_id" : DressTimeClient.clientId,
            "client_secret" : DressTimeClient.clientSecret,
            "username" : login,
            "password" : password
        ]
        
        unsecureFetchWithURL(DressTimeURLS.tokenURL, method: .post, parameters: parameters, withCompletion: completion)
    }
    
    func fetchLogoutWithCompletion(withCompletion completion: @escaping(DressTimeResult<JSON>) -> Void){
        secureFetchWithURL(DressTimeURLS.logoutURL, method: .get, parameters: nil, withCompletion: completion)
    }
    
    func sendVerificationEmailWithCompletion(email: String, withCompletion completion: @escaping(DressTimeResult<JSON>) -> Void) {
        let url = URL(string: "\(DressTimeURLS.verificationEmailURL)send/?email=\(email))")!

        unsecureFetchWithURL(url, method: .get, parameters: nil, withCompletion: completion)
    }
    
    // MARK: - Public Methods User Management
    func createUserWithCompletion(_ user: Profil, password: String?, withCompletion completion: @escaping(DressTimeResult<JSON>) -> Void) {
        let parameters : [String : Any]? = [
            "email" : user.email != nil ? user.email! : "",
            "password" : password != nil ? password! : "",
            "username" : user.email != nil ? user.email! : "",
            "displayName" : user.name != nil ? user.name! : "",
            "notification" : user.notification != nil ? user.notification! : "",
            "styles" : user.styles != nil ? user.styles! : "",
            "tempUnit" : user.temp_unit!,
            "gender" : user.gender!,
            "fb_id" : user.fb_id != nil ? user.fb_id! : "",
            "fb_token" : user.fb_token != nil ? user.fb_token! : "",
            "picture" : user.picture_url != nil ? user.picture_url! : "",
            "firstName" : user.firstName != nil ? user.firstName! : "",
            "lastName" : user.lastName != nil ? user.lastName! : ""
        ]
        
        unsecureFetchWithURL(DressTimeURLS.registrationURL, method: .post, parameters: parameters, withCompletion: completion)
    
    }
    
    
    func updateUserWithCompletion(_ user: Profil, withCompletion completion: @escaping(DressTimeResult<JSON>) -> Void) {
        let parameters = [
            "email" : user.email != nil ? user.email! : "",
            "displayName" : user.name != nil ? user.name! : "",
            "styles" : user.styles != nil ? user.styles! : "",
            "notification" : user.notification != nil ? user.notification! : "",
            "tempUnit" : user.temp_unit!,
            "gender" : user.gender!,
            "fb_id" : user.fb_id != nil ? user.fb_id! : "",
            "fb_token" : user.fb_token != nil ? user.fb_token! : "",
            "picture" : user.picture_url != nil ? user.picture_url! : "",
            "firstName" : user.firstName != nil ? user.firstName! : " ",
            "lastName" : user.lastName != nil ? user.lastName! : " "
        ]
        secureFetchWithURL(DressTimeURLS.userURL, method: .put, parameters: parameters, withCompletion: completion)
    }
    
    func fetchUserWithCompletion(withCompletion completion: @escaping(DressTimeResult<JSON>) -> Void){
        secureFetchWithURL(DressTimeURLS.userURL, method: .get, parameters: nil, withCompletion: completion)
    }
    
    // MARK: - Public Methods Clothe Management
    func fetchClotheWithCompletion(for clotheId: String, withCompletion completion: @escaping(DressTimeResult<JSON>) -> Void){
        var url = DressTimeURLS.clotheURL
        url.appendPathComponent(clotheId)
        secureFetchWithURL(url, method: .get, parameters: nil, withCompletion: completion)
    }
    
    func updateClotheWithCompletion(for clothe:Clothe, withCompletion completion: @escaping(DressTimeResult<JSON>) -> Void){
        let dict = NSMutableDictionary(dictionary: clothe.toDictionnary())
        dict.removeObject(forKey: "clothe_image")
        
        secureFetchWithURL(DressTimeURLS.clotheURL, method: .put, parameters: dict as? [String : AnyObject], withCompletion: completion)
    }
    
    func saveClotheWithCompletion(for clothe:Clothe, withCompletion completion: @escaping(DressTimeResult<JSON>) -> Void){
        var dressingSeriazible = [[String:AnyObject]]()
        let dict = NSMutableDictionary(dictionary: clothe.toDictionnary())
        dict["clothe_image"] = ""
        let d:[String:AnyObject] = dict as NSDictionary as! [String : AnyObject]
        dressingSeriazible.append(d)
        
        let parameters = [
            "dressing" : dressingSeriazible
        ]
        secureFetchWithURL(DressTimeURLS.clotheURL, method: .post, parameters: parameters, withCompletion: completion)
    }
    
    func deleteClotheWithCompletion(for clotheId: String, withCompletion completion: @escaping(DressTimeResult<JSON>) -> Void){
        var url = DressTimeURLS.clotheURL
        url.appendPathComponent(clotheId)
        secureFetchWithURL(url, method: .delete, parameters: nil, withCompletion: completion)
    }
    
    func fetchClotheImageWithCompletion(for clotheId: String, withCompletion completion: @escaping(DressTimeResult<JSON>) -> Void){
        var url = DressTimeURLS.uploadImageURL
        url.appendPathComponent(clotheId)
        secureFetchWithURL(url, method: .get, parameters: nil, withCompletion: completion)
    }
    
    func uploadClotheImageWithCompletion(for clotheId: String, data: Data, withCompletion completion: @escaping(DressTimeResult<JSON>) -> Void){
        guard let userId = SharedData.sharedInstance.currentUserId,
            let profile = ProfilsDAL().fetch(userId) else {
                return completion(.failure(DressTimeError.authenticationError))
        }
        
        var headers :[String : String]?
        var newURL = DressTimeURLS.uploadImageURL
        if ((FBSDKAccessToken.current()) != nil && profile.fb_id != nil){
            newURL = URL(string: "\(newURL.absoluteString)?access_token=\(FBSDKAccessToken.current().tokenString)")!
        } else {
            headers = ["Authorization": "Bearer \(profile.access_token!)"]
        }
        
        let request = try! URLRequest(url: newURL.absoluteString, method: .post, headers: headers)
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(data, withName: "clothe_image", fileName: "\(clotheId).jpg", mimeType: "image/jpeg")
            }, with: request, encodingCompletion: { (result) in
                print(result)
        })
    }
    
    func fetchDressingWithCompletion(withCompletion completion: @escaping(DressTimeResult<JSON>) -> Void){
        secureFetchWithURL(DressTimeURLS.clotheURL, method: .get, parameters: nil, withCompletion: completion)
    }
    
    func fetchClothesIdWithCompletion(withCompletion completion: @escaping(DressTimeResult<JSON>) -> Void){
        secureFetchWithURL(DressTimeURLS.clotheIdsURL, method: .get, parameters: nil, withCompletion: completion)
    }
    
    // MARK: - Public Methods Outfits Management
    func fetchOutfitsOfTheDayWithCompletion(at location: CLLocation, withCompletion completion: @escaping(DressTimeResult<OutfitOfTheDayResult>) -> Void){
        let url = URL(string:"\(DressTimeURLS.outfitURL.absoluteString)v2.2/?lat=\(location.coordinate.latitude)&long=\(location.coordinate.longitude)&timezone=\(NSTimeZone.system.secondsFromGMT())")!
        
        secureFetchWithURL(url, method: .get, parameters: nil) { (result) in
            switch result {
            case .success(let json):
                guard let outfitsArray = json["outfits"].array else {
                    completion(.failure(DressTimeError.jsonContentError(json.debugDescription)))
                    return
                }
                var outfits = [Outfit]()
                for outfit in outfitsArray {
                   let outfitItem = Outfit(json: outfit)
                    outfitItem.orderOutfit()
                    outfits.append(outfitItem)
                }
                let weather = Weather(json: json["weather"])
                let result = OutfitOfTheDayResult(outfits: outfits, weather: weather)
                completion(.success(result))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchOutfitPutOnWithCompletion(withCompletion completion: @escaping(DressTimeResult<JSON>) -> Void){
        secureFetchWithURL(DressTimeURLS.outfitPutOnURL, method: .get, parameters: nil, withCompletion: completion)
    }
    
    func saveOutfitWithCompletion(for outfit: Outfit, withCompletion completion: @escaping(DressTimeResult<JSON>) -> Void){
        secureFetchWithURL(DressTimeURLS.outfitOfTheDayURL, method: .post, parameters: outfit.toDictionnary() as? [String : AnyObject], withCompletion: completion)
    }
    
    
    // MARK: - Private Methods
    
    fileprivate func unsecureFetchWithURL(_ url: URL, method: HTTPMethod, parameters: [String:Any]?, withCompletion completion: @escaping (DressTimeResult<JSON>) -> Void){
    
        Alamofire.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
            .validate()
            .responseJSON(completionHandler: { (response) in
    
            switch response.result {
            case .success(let json):
                completion(.success(JSON(json)))
            case .failure(let error):
                let dtError = self.checkError(response: response, error: error)
                completion(.failure(dtError))
            }
        })
    }
    
    fileprivate func secureFetchWithURL(_ url: URL, method: HTTPMethod, parameters: [String: Any]?, withCompletion completion: @escaping (DressTimeResult<JSON>) -> Void) {
        
        guard let userId = SharedData.sharedInstance.currentUserId,
            let profile = ProfilsDAL().fetch(userId) else {
                return completion(.failure(DressTimeError.authenticationError))
        }
        
        var headers :[String : String]?
        var newURL = url
        if ((FBSDKAccessToken.current()) != nil && profile.fb_id != nil){
            newURL = URL(string: "\(url.absoluteString)?access_token=\(FBSDKAccessToken.current().tokenString)")!
        } else {
            guard let token = profile.access_token else {
                NotificationCenter.default.post(name: Notifications.Error.NoAuthentication, object: self) // Go to Login Page   
                return
            }
            headers = ["Authorization": "Bearer \(token)"]
        }
        
        Alamofire.request(newURL, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseJSON(completionHandler: { (response) in
                
                switch response.result {
                case .success(let json):
                    completion(.success(JSON(json)))
                case .failure(let error):
                    let dtError = self.checkError(response: response, error: error)
                    completion(.failure(dtError))
                }
            })
    }
    
    fileprivate func checkError(response: DataResponse<Any>, error: Error) -> DressTimeError {
        guard let statusCode = response.response?.statusCode else {
           return DressTimeError.jsonContentError("Generic Error")
        }
        if statusCode == 401 {
            NotificationCenter.default.post(name: Notifications.Error.NoAuthentication, object: self) // Go to Login Page
            return DressTimeError.unauthorizedError

        }
        switch error {
        case AFError.responseValidationFailed(let reason):
            return DressTimeError.duplicateAccountError("\(reason)")
        default:
            return DressTimeError.jsonContentError("Generic Error")
        }
    }
}
