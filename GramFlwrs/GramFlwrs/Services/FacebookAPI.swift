//
//  FacebookAPI.swift
//  VimPay Instagram Followers
//
//  Created by Aisultan Askarov on 27.11.2022.
//

import SwiftUI
import FBSDKCoreKit
import FacebookLogin
import KeychainAccess

protocol GetInstagramData {
    func getUsersInstagramDataAndGenerateNewLongLivedToken(completion: @escaping (ViewModelOutput?, GraphRequestResult) -> Void)
}

public class FacebookAPI: GetInstagramData {
    
    static let shared = FacebookAPI()
    private let authorizationAPI = AuthorizationAPI.shared
    private let coreDataStack = CoreDataStack.shared
    
    private let keychain = Keychain(service: "com.aisultan.GramFlwrs", accessGroup: "group.aisultan.GramFlwrs")
    
    let exchangeForLongLastingTokenParameters = exchangeForLongLastingTokenStruct()
    let getFacebookProfileInfoParameters = getFacebookProfileInfoStruct()
    let getInstagramAccountsConnectedToFBPageParameters = getInstagramAccountsConnectedToFBPageStruct()
    let getInstagramAccountsDataParameters = getInstagramAccountsDataStruct()
    
    var requestOutput = ViewModelOutput()
    
    private init () {}
    
    //MARK: -METHODS
    
    func getUsersInstagramDataAndGenerateNewLongLivedToken(completion: @escaping (ViewModelOutput?, GraphRequestResult) -> Void) {
        
        let access_token = keychain["long_lasting_access_token"]
        let inst_id = keychain["inst_id"]
        
        if access_token == nil || inst_id == nil {
            
            if let token = (AccessToken.current) {
                if !token.isExpired {
                    
                    getFacebookProfileInfo(graphPath: getFacebookProfileInfoParameters.graphPath, parameters: getFacebookProfileInfoParameters.parameters, method: getFacebookProfileInfoParameters.method, access_token: token.tokenString) { [self] result, responce in
                        switch result {
                        case .SUCCESSFULL:
                            //Successfully fetched users Facbook Account Data and got an access token
                            //Now gettings connected instagram business pages id
                            let access_token = (responce?.access_token)!
                            
                            //Exhanging short lived token for long lived and saving it in Keychain
                            exchangeForLongLastingToken(graphPath: exchangeForLongLastingTokenParameters.graphPath, parameters: exchangeForLongLastingTokenParameters.parameters, method: exchangeForLongLastingTokenParameters.method, access_token: access_token) { [self] result, responce in
                                
                                if responce != nil {
                                    keychain["long_lasting_access_token"] = responce?.access_token
                                }
                                
                            }
                            
                            //We can force unwrap responces properties since we are using result cases (.SUCCESSFULL/.FAILED)
                            getInstagramAccountsConnectedToFBPage(graphPath: getInstagramAccountsConnectedToFBPageParameters.graphPath, parameters: getInstagramAccountsConnectedToFBPageParameters.parameters, method: getInstagramAccountsConnectedToFBPageParameters.method, fb_id: (responce?.fb_id)!, access_token: access_token) { [self] result, responce in
                                switch result {
                                case .SUCCESSFULL:
                                    //Successfully fetched the instagram business pages id
                                    //Now requesting the data of inst account
                                    
                                    if responce != nil {
                                        keychain["inst_id"] = responce?.inst_business_id
                                    }
                                    
                                    //MARK: - Getting Data
                                    getInstagramData { result, responce in
                                        
                                        switch result {
                                            
                                        case .SUCCESSFULL:
                                            completion(responce, .SUCCESSFULL)
                                        case.FAILED:
                                            completion(nil, .FAILED)
                                        }
                                        
                                    }
                                    
                                case .FAILED:
                                    //Failed to get instagram pages id
                                    //isFetching = false
                                    keychain["long_lasting_access_token"] = nil
                                    keychain["inst_id"] = nil
                                    completion(nil, .FAILED)
                                    return
                                }
                                
                            }//: GETTING INSTAGRAM PAGES ID
                        case .FAILED:
                            //Failed to get facebook profile info
                            //isFetching = false
                            keychain["long_lasting_access_token"] = nil
                            keychain["inst_id"] = nil
                            completion(nil, .FAILED)
                            return
                        }//: GETTING FACEBOOK PROFILE INFO
                        
                    }
                } else { //: CHECKING IF ACCESS TOKEN IS EXPIRED
                    authorizationAPI.logOut()
                }
            } else { //: CHECKING IF ACCESS TOKEN EXISTS
                authorizationAPI.logOut()
            }
            
        } else if access_token != nil, inst_id != nil {
            
            //MARK: - Getting Data
            getInstagramData { result, responce in
                
                switch result {
                    
                case .SUCCESSFULL:
                    completion(responce, .SUCCESSFULL)
                case.FAILED:
                    completion(nil, .FAILED)
                    
                }
                
            }
            
        }
        
    }
    
    func getInstagramData(completion: @escaping (GraphRequestResult, ViewModelOutput?) -> Void) {
        
        //We already have long lived token that should be valid for 60 days. It also is a good practice if you have a limited amount of requests available.
        let access_token = keychain["long_lasting_access_token"]
        let inst_id = keychain["inst_id"]
        
        checkIfLongLivedAccessTokenIsExpired(graphPath: "me", parameters: ["fields": ""], method: "GET", access_token: access_token!) { [self] result in
            if result == .SUCCESSFULL {
                getInstagramAccountsData(parameters: getInstagramAccountsDataParameters.parameters, method: getInstagramAccountsDataParameters.method, inst_business_id: inst_id!, access_token: access_token!) { [self] result, responce in
                    
                    switch result {
                    case .SUCCESSFULL:
                        //isFetching = false
                        requestOutput.profileImageUrl = responce?.profile_pic_url ?? ""
                        requestOutput.userName = responce?.username ?? "@username"
                        requestOutput.numberOfFollowers = String(responce?.followers_count ?? 0)
                        requestOutput.numberOfFollowing = String(responce?.following_count ?? 0)
                        requestOutput.numberOfPosts = String(responce?.posts_count ?? 0)
                        
                        coreDataStack.getStoredDataFromCoreData { [self] lastUpdates in
                            
                            requestOutput.updates = lastUpdates
                            
                            print(lastUpdates)
                            
                            calculateTheDifference(number_of_followers_from_last_update: lastUpdates.last?.number_of_followers_from_yesterday ?? "0") { [self] in
                                
                                if lastUpdates.count == 0 {
                                    print("First Save")
                                    //Users first launch
                                    coreDataStack.addUpdate(number_of_followers: String((responce?.followers_count)!), gained_subscribers: requestOutput.text, number_of_followers_from_yesterday: "0", date_of_last_update: Date(), date_of_last_saved_update: Date())
                                } else if lastUpdates.count > 0 {
                                    print("Saved")
                                    if let diff = Calendar.current.dateComponents([.hour], from: lastUpdates.last?.date_of_last_saved_update ?? Date(), to: Date()).hour, diff >= 23 {
                                        //Checking if 24 hours have passed since last saved update
                                        coreDataStack.addUpdate(number_of_followers: String((responce?.followers_count)!), gained_subscribers: requestOutput.text, number_of_followers_from_yesterday: String((responce?.followers_count)!), date_of_last_update: Date(), date_of_last_saved_update: Date())
                                    } else {
                                        coreDataStack.editLastUpdate(update: (lastUpdates.last)!, number_of_followers: String((responce?.followers_count)!), gained_subscribers: requestOutput.text, number_of_followers_from_yesterday: lastUpdates.last!.number_of_followers_from_yesterday!, date_of_last_update: Date(), date_of_last_saved_update: (lastUpdates.last?.date_of_last_saved_update)!)
                                    }
                                }
                                
                            }
                            
                            requestOutput.lastUpdateTime = formatLastUpdatesTime(date: lastUpdates.last?.date_of_last_update ?? Date()) ?? "↻ --:--"
                            
                            completion(.SUCCESSFULL, requestOutput)
                            
                        }
                    case .FAILED:
                        //Failed to get instagram data
                        //isFetching = false
                        completion(.FAILED, nil)
                        return
                    }
                    
                }//: GETTING INSTAGRAM ACCOUNT DATA
            } else if result == .FAILED {
                //Access token is expired
                keychain["long_lasting_access_token"] = nil
                keychain["inst_id"] = nil
                completion(.FAILED, nil)
            }
        }
    }
}
    
    ///
    
    func checkIfLongLivedAccessTokenIsExpired(graphPath: String, parameters: [String: String], method: String, access_token: String, completion: @escaping (GraphRequestResult) -> Void) {
        //let parameters = ["fields": ""] "me" "GET"
        GraphRequest(graphPath: graphPath, parameters: parameters, tokenString: access_token, version: "v15.0", httpMethod: HTTPMethod(rawValue: method)).start { connection, result, error in
            if error == nil {
                completion(.SUCCESSFULL)
            } else {
                completion(.FAILED)
            }
        }
        
    }
    
    func exchangeForLongLastingToken(graphPath: String, parameters: [String: String], method: String, access_token: String, completion: @escaping (GraphRequestResult, LongLastingTokenResponce?) -> Void) {
        //let parameters = ["fields": ""]
        //oauth/access_token?grant_type=fb_exchange_token&client_id=513602937381781&client_secret=b97900b5b754aee2277249ae24b44644&fb_exchange_token=
        //"GET"
        
        GraphRequest(graphPath: graphPath+access_token, parameters: parameters, tokenString: access_token, version: "v15.0", httpMethod: HTTPMethod(rawValue: method)).start { connection, result, error in
            if let result = result, error == nil {
                //print("Fetched Result: \(result)")
                let decodedResult = LongLastingTokenResponce(rawResponse: result)
                //print(decodedResult.access_token!)
                completion(.SUCCESSFULL, decodedResult)
            } else {
                completion(.FAILED, nil)
            }
        }
        
    }
    
    func getFacebookProfileInfo(graphPath: String, parameters: [String: String], method: String, access_token: String, completion: @escaping (GraphRequestResult, FacebookAccountResponce?) -> Void) {
        //let parameters = ["fields": "access_token, id, name"]
        //"me/accounts" "GET"
        GraphRequest(graphPath: graphPath, parameters: parameters, tokenString: access_token, version: "v15.0", httpMethod: HTTPMethod(rawValue: method)).start { connection, result, error in
            if let result = result, error == nil {
                print("Fetched Result: \(result)")
                let decodedResult = FacebookAccountResponce.init(rawResponse: result)
                //print("ACCESS TOKEN: \(decodedResult.access_token!)")
                completion(.SUCCESSFULL, decodedResult)
            } else {
                completion(.FAILED, nil)
            }
        }
        
    }
    
    func getInstagramAccountsConnectedToFBPage(graphPath: String, parameters: [String: String], method: String, fb_id: String, access_token: String, completion: @escaping (GraphRequestResult, UsersInstagramAccountsResponce?) -> Void) {
        //let parameters = ["fields": "instagram_business_account"]
        //"fb_id/instagram_accounts"
        //"GET"
        GraphRequest(graphPath: "\(fb_id)\(graphPath)", parameters: parameters, tokenString: "\(access_token)", version: "v15.0", httpMethod: HTTPMethod(rawValue: method)).start { connection, result, error in
            if let result = result, error == nil {
                print("Fetched Instagram Results: \(result)")
                let decodedResult = UsersInstagramAccountsResponce(rawResponse: result)
                completion(.SUCCESSFULL, decodedResult)
            } else {
                completion(.FAILED, nil)
            }
        }
    }
    
func getInstagramAccountsData(parameters: [String: String], method: String, inst_business_id: String, access_token: String, completion: @escaping (GraphRequestResult, InstagramAccountResponce?) -> Void) {
    //let parameters = ["fields": "username, followed_by_count, follow_count, profile_pic, media_count"]
    //"\(inst_business_id)" "GET"
    GraphRequest(graphPath: "\(inst_business_id)", parameters: parameters, tokenString: "\(access_token)", version: "v15.0", httpMethod: HTTPMethod(rawValue: method)).start { connection, result, error in
        
        if let result = result, error == nil {
            print("Fetched Instagram Results: \(result)")
            let decodedResult = InstagramAccountResponce(rawResponse: result)
            completion(.SUCCESSFULL, decodedResult)
        } else {
            completion(.FAILED, nil)
        }
    }
}

enum GraphRequestResult: String, Codable {
    case FAILED
    case SUCCESSFULL
}

extension FacebookAPI {
    
    //MARK: - Calculating Last Updates Data
    
    func calculateTheDifference(number_of_followers_from_last_update: String, completion: @escaping () -> Void) {
        let numberOfFollowersOnLastUpdate = Int(number_of_followers_from_last_update)
        let numberOfFollowers = (Int(requestOutput.numberOfFollowers) ?? 0)
        let differenceInSubs = numberOfFollowers - (numberOfFollowersOnLastUpdate ?? 0)
        if differenceInSubs > 0 {
            //User has gained subs
            requestOutput.text = "Today: ▲\(differenceInSubs)"
            requestOutput.color = .green
            requestOutput.opacity = 0.75
        } else if differenceInSubs < 0 {
            //User has lost subs
            requestOutput.text = "Today: ▼\(differenceInSubs)"
            requestOutput.color = .red
            requestOutput.opacity = 0.75
        } else {
            //Number of subs hasn't changed
            requestOutput.text = "Today: ♦︎0"
            requestOutput.color = .black
            requestOutput.opacity = 0.35
        }
        completion()
    }
    
    func formatLastUpdatesTime(date: Date) -> String? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        return "↻ \(dateFormatter.string(from: (date)))"
    }
    
}

