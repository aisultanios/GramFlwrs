//  Created by Aisultan Askarov on 26.11.2022.
//

import XCTest
@testable import GramFlwrs

final class GramFlwrsTests: XCTestCase {

    //Testing Parameters Passed To GraphRequests

    func test_view_model_exchange_token_parametes() {
        
        //given
        let parameters = exchangeForLongLastingTokenStruct()
        let graphPath = parameters.graphPath
        let httpParameters = parameters.parameters
        let method = parameters.method
        //then
        XCTAssertEqual(graphPath, "oauth/access_token?grant_type=fb_exchange_token&client_id=513602937381781&client_secret=b97900b5b754aee2277249ae24b44644&fb_exchange_token=")
        XCTAssertEqual(httpParameters, ["fields": ""])
        XCTAssertEqual(method, "GET")
        
    }
    
    func test_view_model_get_facebook_profile_info_parametes() {
        
        //given
        let parameters = getFacebookProfileInfoStruct()
        let graphPath = parameters.graphPath
        let httpParameters = parameters.parameters
        let method = parameters.method
        //then
        XCTAssertEqual(graphPath, "me/accounts")
        XCTAssertEqual(httpParameters, ["fields": "access_token, id, name"])
        XCTAssertEqual(method, "GET")
        
    }
    
    func test_view_model_get_instagram_account_connected_to_facebook_profile_info_parametes() {
        
        //given
        let parameters = getInstagramAccountsConnectedToFBPageStruct()
        let graphPath = parameters.graphPath
        let httpParameters = parameters.parameters
        let method = parameters.method
        //then
        XCTAssertEqual(graphPath, "/instagram_accounts")
        XCTAssertEqual(httpParameters, ["fields": "instagram_business_account"])
        XCTAssertEqual(method, "GET")
        
    }
    
    func test_view_model_get_instagram_accounts_info_parametes() {
        
        //given
        let parameters = getInstagramAccountsDataStruct()
        let httpParameters = parameters.parameters
        let method = parameters.method
        //then
        XCTAssertEqual(httpParameters, ["fields": "username, followed_by_count, follow_count, profile_pic, media_count"])
        XCTAssertEqual(method, "GET")
        
    }
    
}
