//
//  AuthorizationAPI.swift
//  VimPay Instagram Followers
//
//  Created by Aisultan Askarov on 30.11.2022.
//

import Foundation
import SwiftUI
import FacebookLogin
import KeychainAccess

public class AuthorizationAPI: ObservableObject {
    
    static let shared = AuthorizationAPI()

    //MARK: -PROPERTY
    
    private let loginManager = LoginManager()
    @AppStorage("isLoggedIn") private var isLoggedin = false

    @Published var logInFailed: Bool = false
    @Published var isLogingin: Bool = false
    
    private let permissions = ["instagram_basic", "pages_show_list", "pages_read_engagement", "public_profile", "email", "openid"]
    
    private let keychain = Keychain(service: "com.aisultan.GramFlwrs", accessGroup: "group.aisultan.GramFlwrs")
    
    private init() { }
    
    //MARK: -METHODS
    //MARK: - LogIn/LogOut
    
    func logIn() {
        
        withAnimation(.easeOut(duration: 0.5)) {
            isLogingin = true
        }
        
        loginManager.logIn(permissions: permissions, from: nil) { [self] (result, error) in
            
            // Check for error
            guard error == nil else {
                // Error occurred
                print(error!.localizedDescription)
                withAnimation(.easeOut(duration: 0.5)) {
                    //When login failed alert will be presented
                    logInFailed = true
                    isLogingin = false
                }
                logOut()
                return
            }
            
            // Check for cancel
            guard let result = result, !result.isCancelled else {
                print("User cancelled login")
                withAnimation(.easeOut(duration: 0.5)) {
                    //When login failed alert will be presented
                    logInFailed = true
                    isLogingin = false
                }
                logOut()
                return
            }
            
            // Successfully logged in
            withAnimation(.easeIn(duration: 0.3)) {
                logInFailed = false
                isLoggedin = true
                isLogingin = false
            }
            
        }
        
    }
    
    func logOut() {
        withAnimation(.easeOut(duration: 0.5)) {
            isLoggedin = false
        }
        loginManager.logOut()
        keychain["long_lasting_access_token"] = nil
        keychain["inst_id"] = nil
    }
    
    func checkIfLoggedIn() {
        if (AccessToken.current) != nil {
            if AccessToken.current?.isExpired == false {
                isLoggedin = true
            } else {
                isLoggedin = false
            }
        } else {
            isLoggedin = false
        }
        
        print(isLoggedin)
    }
    
    enum FBAuthorizationResponce: String, Codable {
        case ERROR
        case CANCELED
        case SUCCESSFULL
    }
    
}

