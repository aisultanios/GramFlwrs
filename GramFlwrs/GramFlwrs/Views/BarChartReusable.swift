//
//  BarChartReusable.swift
//  GramFlwrs
//
//  Created by Aisultan Askarov on 24.12.2022.
//

import SwiftUI

struct BarChart: View {
    
    var updates: [(dateText: String, update: LastUpdate?)] = []

    //Gesture Properties
    @GestureState var isDragging: Bool = false
    @State var offset: CGFloat = 0.0
    
    //Current Update
    @State private var currentUpdateID: String = ""
    @State private var maxFlwrs: CGFloat = 0.0
    
    var body: some View {
        
        VStack(alignment: .center) {
            GeometryReader { proxy in
                HStack(alignment: .bottom, spacing: 5) {
                    
                    ForEach(0..<updates.count, id: \.self) { i in
                        
                        VStack(alignment: .center) {
                            
                            if i > 0 {
                                self.displayBar(proxy: proxy, previousUpdate: updates[i - 1], update: updates[i])
                            } else {
                                self.displayBar(proxy: proxy, previousUpdate: nil, update: updates[i])
                            }
                            
                            Text(updates[i].dateText)
                                .foregroundColor(.black.opacity(0.75))
                                .font(.system(size: 9.0, weight: .regular, design: .rounded))
                                .multilineTextAlignment(.center)
                            
                        }
                    }
                }//: HSTACK
                .frame(width: proxy.size.width - 50, alignment: .center)
                .frame(maxWidth: proxy.size.width, alignment: .center)
                .animation(.easeOut, value: isDragging)
                .gesture(
                    DragGesture()
                        .updating($isDragging, body: { _, out, _ in
                            out = true
                        })
                        .onChanged({ value in
                            offset = isDragging ? value.location.x - 50 : 0
                            
                            //Dragging Space
                            
                            //Each bar
                            let eachBlock = CGFloat((proxy.size.width - 110) / Double(self.updates.count))
                            
                            //getting index
                            let temp = Int(offset / eachBlock)
                            
                            //safe wrapping index
                            let index = max(min(temp, updates.count - 1), 0)
                            
                            self.currentUpdateID = updates[index].update?.id ?? "0"
                            
                        })
                        .onEnded({ value in
                            withAnimation {
                                offset = .zero
                                currentUpdateID = ""
                            }
                        })
                )
                .onAppear {
                    maxFlwrs = getMaxFlwrs(updates: updates.compactMap({$0.update}))
                }
            }//: GEOMETRYREADER
        }//: VSTACK
    }
    
    func displayBar(proxy: GeometryProxy, previousUpdate: (dateText: String, update: LastUpdate?)?, update: (dateText: String, update: LastUpdate?)) -> some View {
        
        
        return VStack(alignment: .center) {
            //if update.update != nil {
            Text(update.update?.number_of_followers ?? "")
                    .foregroundColor(.white)
                    //.font(.system(size: 18.0, weight: .semibold, design: .rounded))
                    .font(isDragging ? (currentUpdateID == update.update?.id ? .system(size: 24.0, weight: .black, design: .rounded) : .system(size: 17.0, weight: .semibold, design: .rounded)) : .system(size: 17.0, weight: .semibold, design: .rounded))
                    .minimumScaleFactor(0.8)
                    .shadow(color: .white.opacity(0.5), radius: 2.5)
                    .multilineTextAlignment(.center)
                    .opacity(isDragging ? (currentUpdateID == update.update?.id ? 1 : 0.35) : 1)
                
                // Set a Bar if there is an update
                Rectangle()
                    .cornerRadius(3.5)
                    .foregroundColor(self.getColor(previousUpdate: previousUpdate?.update, update: update.update))
                    .frame(width: CGFloat((proxy.size.width - 110) / Double(self.updates.count)))
                    .frame(height: (CGFloat(Int(update.update?.number_of_followers ?? "1")!) / maxFlwrs) * (proxy.size.height - 75))
                    .opacity(isDragging ? (currentUpdateID == update.update?.id ? 1 : 0.35) : 1)
                
        }
    }
    
    func getMaxFlwrs(updates: [LastUpdate]) -> CGFloat {
        
        let highestFollowersUpdate = updates.max { update1, update2 in
            return update1.number_of_followers ?? "0" < update2.number_of_followers ?? "0"
        }
        
        return CGFloat(Int(highestFollowersUpdate?.number_of_followers ?? "0")!)
    }
    
    func getColor(previousUpdate: LastUpdate?, update: LastUpdate?) -> Color {
        
        let followers = update?.number_of_followers ?? "0"
        var color: Color = .clear
        if let prev = previousUpdate, update != nil {
            
            let followersInPreviousUpdate = prev.number_of_followers
            
            if followers > followersInPreviousUpdate! {
                color = Color.green
            } else if followers < followersInPreviousUpdate! {
                color = Color.red
            } else {
                color = Color.gray
            }
        } else if previousUpdate == nil, update != nil {
            // handle the case where previousUpdate is nil
            let followersInPreviousUpdate = previousUpdate?.number_of_followers ?? "0"
            
            if followers > followersInPreviousUpdate {
                color = Color.green
            } else if followers < followersInPreviousUpdate {
                color = Color.red
            } else {
                color = Color.gray
            }
        } else if update == nil {
            color = Color.clear
        }
        
        return color
    }
    
}//: BARCHART

