//  Created by Aisultan Askarov on 2.12.2022.
//

import WidgetKit
import SwiftUI
import Intents
import FBSDKCoreKit

struct Provider: TimelineProvider {
            
    private let viewModel = ViewModel.shared
    
    init() {
        
    }
    
    func placeholder(in context: Context) -> Model {
        
        let placeholderData = Model(lastUpdateTime: "↻ --:--", username: "@user", profile_pic_url: "", followers_count: "---", following_count: "---", posts_count: "---", gainedSubscribers: "Today: ♦︎0")
        
        return (placeholderData)
    }
        
    func getSnapshot(in context: Context, completion: @escaping (Model) -> Void) {
        
        //Initial Snapshot
        //Or when loading data
        let placeholderData = Model(lastUpdateTime: "↻ --:--", username: "@user", profile_pic_url: "", followers_count: "---", following_count: "---", posts_count: "---", gainedSubscribers: "Today: ♦︎0")
        
        completion(placeholderData)
        
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Model>) -> Void) {
        
        CoreDataStack.shared.getStoredDataFromCoreData { lastUpdate in
            
            print(lastUpdate)
            let data = Model(lastUpdateTime: formatLastUpdatesTime(date: lastUpdate.last!.date_of_last_update!), username: "@user", profile_pic_url: "", followers_count: lastUpdate.first!.number_of_followers!, following_count: "---", posts_count: "---", gainedSubscribers: lastUpdate.first!.gained_subscribers!)
            
            //Time line gets reloaded when we save something in Core Data
            let timeline = Timeline(entries: [data], policy: .never)

            completion(timeline)
            
        }

    }
    
    func formatLastUpdatesTime(date: Date) -> String? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        return "↻ \(dateFormatter.string(from: (date)))"
    }
        
}

//Creating View for Widget

struct WidgetView: View {
    
    var entry: Model
    
    var body: some View {
        VStack(alignment: .leading, spacing: 17.5) {
            Text("FOLLOWERS")
                .foregroundColor(.red.opacity(0.65))
                .font(.system(size: 20, weight: .semibold))
                .padding(.trailing)
            Text(entry.followers_count ?? "")
                .foregroundColor(.red.opacity(0.65))
                .font(.system(size: 40, weight: .black))
                .minimumScaleFactor(0.6)
                .padding(.top, -17.5)
            Text(entry.gainedSubscribers ?? "")
                .foregroundColor(.black.opacity(0.45))
                .font(.footnote)
                .padding(.top, -15)
            
            HStack(alignment: .top) {
                Text(entry.lastUpdateTime ?? "")
                    .foregroundColor(.gray.opacity(0.8))
                    .font(.system(size: 10.5, design: .rounded))
                    .multilineTextAlignment(.leading)
                
                HStack(spacing: 0) {
                    Image("vimPayLogo")
                        .resizable()
                        .frame(width: 22.5, height: 22.5)
                        .cornerRadius(12.5)
                        .shadow(radius: 2)
                        .padding(.leading)
                    Image("instagramLogoWidget")
                        .resizable()
                        .frame(width: 22.5, height: 22.5)
                        .cornerRadius(5)
                        .shadow(radius: 2)
                        .padding(.leading, 10)
                }//: HSTACK
                .padding(.leading)
                
            }//: HSTACK
        }//: VSTACK
        .widgetBackground(Color.gray.opacity(0.05))
        .widgetContentMargins(0.0)
    }//: VIEW
}


//Setting Widget Configuration

@main
struct GramFlwrsWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "GramFlwrsWidget", provider: Provider()) { data in
            WidgetView(entry: data)
        }
        .description(Text("Track your Instagram Business accounts followers"))
        .configurationDisplayName(Text("Instagram Business Stats"))
        .supportedFamilies([.systemSmall])
    }
}

