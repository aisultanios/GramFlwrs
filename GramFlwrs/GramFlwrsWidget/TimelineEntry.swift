//  Created by Aisultan Askarov on 3.12.2022.
//

import Foundation
import WidgetKit
import SwiftUI

struct Model: TimelineEntry {
    var date = Date()
    var lastUpdateTime: String?
    var username: String?
    var profile_pic_url: String?
    var followers_count: String?
    var following_count: String?
    var posts_count: String?
    
    //Changes in Subs
    var gainedSubscribers: String?
    
}
