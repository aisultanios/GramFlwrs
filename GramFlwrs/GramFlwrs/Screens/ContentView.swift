//  Created by Aisultan Askarov on 26.11.2022.
//

import SwiftUI
import CoreData
import FacebookLogin

struct ContentView: View {
    
    @State private var authorizationModel = AuthorizationAPI.shared
    @AppStorage("isLoggedIn") private var isLoggedin = false
    
    var body: some View {
        
        ZStack {
            if isLoggedin == true {
                //User is Loged-in and the Access Token is Active
                ProfileStatsView()
                    .transition(.scale)
            } else if isLoggedin == false {
                //User is not Loged-in or the Access Token is Inactive
                SigninView()
                    .transition(.scale)
            }
            
        }//: ZSTACK
        .onAppear() {
            authorizationModel.checkIfLoggedIn()
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
