//  Created by Aisultan Askarov on 26.11.2022.
//

import SwiftUI
import BackgroundTasks

@main 
struct GramFlwrsApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    let persistenceController = CoreDataStack.shared
    @StateObject var lastUpdateModel = LastUpdate()

    var body: some Scene {
        WindowGroup {
            AnyView(ContentView()
                .environment (\.managedObjectContext, persistenceController.persistentContainer.viewContext))
        }
        .backgroundTask(.appRefresh("com.aisultan.GramFlwrs.BackgroundFetch")) { _ in
            await scheduleGraphRequest()
        }
        
    }
    
    func scheduleGraphRequest() async {
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())
        
        let request = BGAppRefreshTaskRequest(identifier: "com.aisultan.GramFlwrs.BackgroundFetch")
        request.earliestBeginDate = nextUpdate
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
        
    }
}
