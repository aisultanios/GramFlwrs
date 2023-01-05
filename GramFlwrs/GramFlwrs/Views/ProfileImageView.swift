//  Created by Aisultan Askarov on 26.11.2022.
//

import SwiftUI

struct ProfileImageView: View {
    
    let url: String
    let placeholder: String
    
    @ObservedObject var imageLoader = ImageLoader()
    
    init(url: String, placeholder: String = "placeholder") {
        self.url = url
        self.placeholder = placeholder
        self.imageLoader.downloadImage(url: url)
    }
    
    var body: some View {
        
        if let data = self.imageLoader.downloadedData {
            return AnyView(Image(uiImage: UIImage(data: data)!).profileImageModifier())
        } else {
            return AnyView(Image(systemName: "person.circle.fill").bugIconModifier())
        }
        
    }
}

struct ProfileImageView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileImageView(url: "https://www.vimpay.de/wp-content/uploads/images/vimpay-logo.png")
    }
}
