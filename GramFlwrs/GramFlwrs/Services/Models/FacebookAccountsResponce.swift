//  Created by Aisultan Askarov on 30.11.2022.
//

import Foundation

//Responce on Graph Request /me/accounts
struct FacebookAccountResponce: Codable {

    var fb_id: String?
    var access_token: String?
    var name: String?
    
    init(rawResponse: Any?) {
        // Decoding JSON from rawResponse
        guard let response = rawResponse as? Dictionary<String, Any> else {
            return
        }
        
        if let data = response["data"] as? [[String: String]] {
            
            if let fb_id = data.first!["id"] {
                self.fb_id = fb_id
            }
            
            if let access_token = data.first!["access_token"] {
                self.access_token = access_token
            }
            
            if let name = data.first!["name"] {
                self.name = name
            }
            
        }
    }
}

//Responce on Graph Request /{FacebookAccountId}/instagram_accounts
struct UsersInstagramAccountsResponce: Codable {

    var inst_business_id: String?
    
    init(rawResponse: Any?) {
        // Decoding JSON from rawResponse
        guard let response = rawResponse as? Dictionary<String, Any> else {
            return
        }

        if let data = response["data"] as? [[String: String]] {
            
            if let inst_business_id = data.first!["id"] {
                self.inst_business_id = inst_business_id
            }
            
        }

    }
}

//Responce on Graph Request /{InstagramID}

struct InstagramAccountResponce: Codable {
    
    var page_id: String?
    var username: String?
    var profile_pic_url: String?
    var followers_count: Int32?
    var following_count: Int32?
    var posts_count: Int32?
    
    init(rawResponse: Any?) {
        // Decoding JSON from rawResponse
        guard let response = rawResponse as? Dictionary<String, Any> else {
            return
        }

        if let page_id = response["id"] as? String {
            self.page_id = page_id
        }
        
        if let username = response["username"] as? String {
            self.username = username
        }
        
        if let profile_pic_url = response["profile_pic"] as? String {
            self.profile_pic_url = profile_pic_url
        }
        
        if let followers_count = response["followed_by_count"] as? Int32 {
            self.followers_count = followers_count
        }
        
        if let following_count = response["follow_count"] as? Int32 {
            self.following_count = following_count
        }
        
        if let posts_count = response["media_count"] as? Int32 {
            self.posts_count = posts_count
        }

    }
    
}

struct LongLastingTokenResponce: Codable {
    
    var access_token: String?
    
    init(rawResponse: Any?) {
        // Decoding JSON from rawResponse
        guard let response = rawResponse as? Dictionary<String, Any> else {
            return
        }

        if let access_token = response["access_token"] as? String {
            self.access_token = access_token
        }

    }
    
}

struct exchangeForLongLastingTokenStruct {
    
    let graphPath = "oauth/access_token?grant_type=fb_exchange_token&client_id=513602937381781&client_secret=b97900b5b754aee2277249ae24b44644&fb_exchange_token="
    let parameters = ["fields": ""]
    let method = "GET"
    
}

struct getFacebookProfileInfoStruct {
    
    let graphPath = "me/accounts"
    let parameters = ["fields": "access_token, id, name"]
    let method = "GET"
    
}

struct getInstagramAccountsConnectedToFBPageStruct {
    
    let graphPath = "/instagram_accounts"
    let parameters = ["fields": "instagram_business_account"]
    let method = "GET"
    
}

struct getInstagramAccountsDataStruct {
    
    let parameters = ["fields": "username, followed_by_count, follow_count, profile_pic, media_count"]
    let method = "GET"
    
}
