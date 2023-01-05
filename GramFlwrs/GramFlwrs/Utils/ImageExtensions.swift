//  Created by Aisultan Askarov on 26.11.2022.
//

import SwiftUI

extension Image {
    func profileImageModifier() -> some View {
        self
            .resizable()
            .scaledToFit()
            .clipShape(Circle())
    }
    
    func bugIconModifier() -> some View {
        self
            .resizable()
            .scaledToFit()
            .frame(maxWidth: 128)
            .foregroundColor(.red)
            .opacity(0.75)
    }
}
