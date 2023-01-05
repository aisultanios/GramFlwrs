//  Created by Aisultan Askarov on 2.12.2022.
//

import Foundation
import FacebookLogin
import SwiftUI
import KeychainAccess
import BackgroundTasks

public class ViewModel: ObservableObject {
    
    static let shared = ViewModel()
    
    //MARK: -PROPERTY
    
    private let authorizationAPI = AuthorizationAPI.shared
    private let facebookAPI = FacebookAPI.shared
    private let coreDataStack = CoreDataStack.shared
    @Published var isAnimating: Bool = false
    @Published var isFetching: Bool = true
    
    @Published var profileImageUrl: String = ""
    @Published var userName: String = "@username"
    @Published var numberOfFollowers: String = "---"
    @Published var numberOfFollowing: String = "---"
    @Published var numberOfPosts: String = "---"
    @Published var lastUpdateTime: String = "↻ --:--"
    
    @Published var color: Color = .white
    @Published var opacity: CGFloat = 0.0
    @Published var text: String = "Today: ♦︎0"
    let exchangeForLongLastingTokenParameters = exchangeForLongLastingTokenStruct()
    let getFacebookProfileInfoParameters = getFacebookProfileInfoStruct()
    let getInstagramAccountsConnectedToFBPageParameters = getInstagramAccountsConnectedToFBPageStruct()
    let getInstagramAccountsDataParameters = getInstagramAccountsDataStruct()
    
    private let keychain = Keychain(service: "com.aisultan.GramFlwrs", accessGroup: "group.aisultan.GramFlwrs")
    @Published var failedToScheduleBGTask: Bool = false
    
    @Published var updates = [LastUpdate]()
    @Published var barChartUpdates: [(dateText: String, update: LastUpdate?)] = []
    
    @Published var selectedPeriod: String = "12 Days"
    @Published var isPeriodSelectorVisible: Bool = false
    @Published var animateBarChart: Bool = false
        
    private init() {}
    
    //MARK: -METHODS
    
    func scheduleBGTask() {
        
        let request = BGAppRefreshTaskRequest(identifier: "com.aisultan.GramFlwrs.BackgroundFetch")
        request.earliestBeginDate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Background Task Scheduled!")
            failedToScheduleBGTask = false
        } catch(let error) {
            print("Scheduling Error \(error.localizedDescription)")
            failedToScheduleBGTask = true
        }
        
    }
    
    //MARK: -Bar Chart Data
    
    func getBarGraphData() {
        coreDataStack.getStoredDataFromCoreData { [self] lastUpdates in
            
            barChartUpdates.removeAll()

            if selectedPeriod == "12 Days" {
                
                var currentDate = Calendar.current.startOfDay(for: Date())
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM d"
                
                for _ in 0..<12 {
                    let date = Calendar.current.date(byAdding: DateComponents(day: -1), to: currentDate)!
                    let monthAbbreviation = dateFormatter.string(from: date).prefix(3).uppercased()
                    let day = Calendar.current.component(.day, from: date)
                    let update = lastUpdates.first(where: {$0.date_of_last_saved_update == date}) ?? nil
                    let dateText = """
\(monthAbbreviation)
\(day)
"""
                    
                    barChartUpdates.append((dateText: dateText, update: update))
                    
                    currentDate = date
                }
                
            } else if selectedPeriod == "3 Months" {

                var currentDate = Calendar.current.startOfDay(for: Date())

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM"

                for _ in 0..<12 {

                    let dateComponents = Calendar(identifier: .iso8601).dateComponents([.month, .weekOfMonth], from: currentDate)
                    print(dateComponents)
                    let monthName = dateFormatter.string(from: currentDate).uppercased()
                    let weekOfMonth = dateComponents.weekOfMonth! - 1
                    let weekOfMonthString = weekOfMonth == 0 ? "1" : "\(weekOfMonth)"
                    let update = lastUpdates.first(where: {$0.date_of_last_saved_update == currentDate}) ?? nil
                    let dateString =
"""
\(monthName)
W\(weekOfMonthString)
"""
                    barChartUpdates.append((dateText: dateString, update: update))
                    currentDate = Calendar.current.date(byAdding: DateComponents(weekOfYear: -1), to: currentDate)!

                }

            } else if selectedPeriod == "1 Year" {

                var currentDate = Calendar.current.startOfDay(for: Date())
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM d"
                
                for _ in 0..<12 {
                    
                    let date = Calendar.current.date(byAdding: DateComponents(month: -1), to: currentDate)!
                    print(date)
                    let monthAbbreviation = dateFormatter.string(from: date).prefix(3).uppercased()
                    let update = lastUpdates.first(where: {$0.date_of_last_saved_update == date}) ?? nil
                    
                    barChartUpdates.append((dateText: monthAbbreviation, update: update))
                    
                    currentDate = date
                }
                
            }
            
        }
    }
        
    //MARK: Fetching Instagram Accounts Data
    
    func getUsersInstagramData() {
        
        facebookAPI.getUsersInstagramDataAndGenerateNewLongLivedToken { [self] responce, result in
            
            switch result {
                
            case .SUCCESSFULL:
                
                isFetching = false
                profileImageUrl = responce?.profileImageUrl ?? ""
                userName = responce?.userName ?? "@username"
                numberOfFollowers = String(responce?.numberOfFollowers ?? "")
                numberOfFollowing = String(responce?.numberOfFollowing ?? "")
                numberOfPosts = String(responce?.numberOfPosts ?? "")
                lastUpdateTime = responce?.lastUpdateTime ?? "↻ --:--"
                
                color = responce?.color ?? .gray
                opacity = responce?.opacity ?? 0.5
                text = responce?.text ?? "Today: ♦︎0"
                
                updates = responce?.updates ?? []
                isAnimating = true
                
                scheduleBGTask()
            case .FAILED:
                
                isFetching = false
                isAnimating = true
                
            }
            
        }
        
    }
}

enum WidgetRequestResult: String, Codable {
    case FAILED
    case SUCCESSFULL
}
    
struct ViewModelOutput {
    
    var profileImageUrl: String = ""
    var userName: String = "@username"
    var numberOfFollowers: String = "---"
    var numberOfFollowing: String = "---"
    var numberOfPosts: String = "---"
    var lastUpdateTime: String = "↻ --:--"
    
    var color: Color = .white
    var opacity: CGFloat = 0.0
    var text: String = "Today: ♦︎0"
    
    var updates: [LastUpdate] = [LastUpdate]()
    
}

