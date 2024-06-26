//  Created by Aisultan Askarov on 27.11.2022.
//

import SwiftUI
import FBSDKCoreKit

struct WidgetPreviewView: View {
    
    //MARK: - PROPERTY
    @State var ShapeColor: Color
    @State var ShapeOpacity: Double
    @State private var isAnimating: Bool = false
    
    //MARK: - BODY
    
    var body: some View {
        ZStack {
            
            RoundedRectangle(cornerRadius: 30)
                .fill(ShapeColor.opacity(ShapeOpacity))
                .frame(width: 200, height: 200, alignment: .center)

            VStack(alignment: .leading, spacing: 25) {
                Text("FOLLOWERS")
                    .foregroundColor(.red.opacity(0.65))
                    .font(.system(size: 20, weight: .semibold))
                    .padding(.trailing)
                Text("3597")
                    .foregroundColor(.red.opacity(0.65))
                    .font(.system(size: 40, weight: .black))
                    .minimumScaleFactor(0.6)
                    .padding(.top, -17.5)
                Text("Today: ▲54")
                    .foregroundColor(.green.opacity(0.85))
                    .font(.footnote)
                    .padding(.top, -15)
                
                HStack(alignment: .top) {
                    Text("↻ 21:57")
                        .foregroundColor(.gray.opacity(0.8))
                        .font(.caption2)
                        .multilineTextAlignment(.leading)
                    HStack(spacing: 0) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 22.5, height: 22.5)
                            .cornerRadius(12.5)
                            .shadow(radius: 2)
                            .padding(.leading)
                        Image("instagramLogo")
                            .resizable()
                            .frame(width: 22.5, height: 22.5)
                            .cornerRadius(5)
                            .shadow(radius: 2)
                            .padding(.leading, 10)
                    }
                    .padding(.leading)
                    
                }
            }//: VSTACK
        } //: ZSTACK
        .blur(radius: isAnimating ? 0: 10)
        .opacity(isAnimating ? 1: 0)
        .scaleEffect(isAnimating ? 1: 0.5)
        .animation(.easeOut(duration: 1), value: isAnimating)
        .onAppear {
            isAnimating = true
        }
    }
}

