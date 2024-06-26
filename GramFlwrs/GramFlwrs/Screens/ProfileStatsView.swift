//  Created by Aisultan Askarov on 27.11.2022.
//

import SwiftUI
import CoreData
//import Charts

struct ProfileStatsView: View {
    
    //MARK: - PROPERTY
    @State private var showingAlertToLogOut = false
    
    @StateObject private var viewModel = ViewModel.shared
    @StateObject private var authorizationModel = AuthorizationAPI.shared
    @StateObject private var coreDataStack = CoreDataStack.shared
    
    //MARK: - BODY
    
    var body: some View {
        ZStack {
            VStack {
                
                //MARK: - HEADER
                HStack {
                    Text("Instagram Stats")
                        .font(.system(size: 30).bold())
                        .foregroundColor(.black.opacity(0.75))
                    
                    Spacer()
                    
                    Button {
                        viewModel.getUsersInstagramData()
                        viewModel.getBarGraphData()
                    } label: {
                        Image(systemName: "arrow.2.circlepath")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.black.opacity(0.75))
                            .frame(width: 27.5, height: 27.5, alignment: .trailing)
                            .font(.system(size: 20, weight: .semibold))
                    }
                    
                    Button {
                        //Log Out Action
                        showingAlertToLogOut = true
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.black.opacity(0.75))
                            .frame(width: 27.5, height: 27.5, alignment: .trailing)
                    }
                    .alert("Are you sure you want to logout?", isPresented: $showingAlertToLogOut) {
                        Button("Yes") {
                            authorizationModel.logOut()
                        }
                        Button("NO", role: .cancel) {
                        }
                    }
                    
                }//: HEADER
                .padding(25)
                .opacity(viewModel.isAnimating ? 1: 0)
                .offset(y: viewModel.isAnimating ? 0: -40)
                .animation(.easeOut(duration: 0.5), value: viewModel.isAnimating)
                
                //MARK: - CENTER
                
                ScrollView {
                    
                    VStack() {
                        //Profile name and picture
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.gray.opacity(0.15))
                            .frame(height: 200)
                            .overlay() {
                                HStack(spacing: 25) {
                                    ZStack() {
                                        
                                        AsyncImage(url: URL(string: viewModel.profileImageUrl)) { image in
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 135, height: 135, alignment: .center)
                                                .clipShape(Circle())
                                        } placeholder: {
                                            Image(systemName: "person.circle.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .aspectRatio(contentMode: .fit)
                                                .foregroundColor(.gray.opacity(0.35))
                                                .frame(width: 135, height: 135, alignment: .center)
                                        }
                                        
                                        VStack() {
                                            Spacer()
                                            Image("instagramLogo")
                                                .resizable()
                                                .frame(width: 40, height: 40, alignment: .center)
                                                .cornerRadius(5)
                                                .shadow(radius: 2)
                                        }
                                        .padding(.leading, 75)
                                        .padding(.bottom, 15)
                                    }
                                    .padding(.leading, -10)
                                    
                                    VStack(alignment: .leading, spacing: 7.5) {
                                        Text("Followers")
                                            .foregroundColor(.red.opacity(0.5))
                                            .font(.system(size: 18, weight: .bold, design: .rounded))
                                        Text("\(viewModel.userName)")
                                            .foregroundColor(.red.opacity(0.5))
                                            .font(.system(size: 25, weight: .black, design: .rounded))
                                            .padding(.top, -5)
                                        Text("\(viewModel.numberOfFollowers)")
                                            .foregroundColor(.red.opacity(0.65))
                                            .font(.system(size: 60, weight: .black, design: .rounded))
                                            .minimumScaleFactor(0.5)
                                        
                                        HStack() {
                                            Text("\(viewModel.text)")
                                                .foregroundColor(viewModel.color.opacity(viewModel.opacity))
                                                .font(.system(size: 17, weight: .black, design: .rounded))
                                            Text(viewModel.lastUpdateTime)
                                                .foregroundColor(.black.opacity(0.35))
                                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                                .padding(.leading, 30)
                                        }
                                    }
                                    
                                }//: HSTACK
                                .padding()
                            }
                    }//: VSTACK
                    .padding()
                    .opacity(viewModel.isAnimating ? 1: 0)
                    .animation(.easeOut(duration: 0.75), value: viewModel.isAnimating)
                    
                    //Profile Stats(Followers, Following, Posts)
                    VStack() {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.gray.opacity(0.15))
                            .frame(height: 75)
                            .overlay() {
                                
                                HStack() {
                                    Text("Following:")
                                        .padding()
                                        .foregroundColor(.black.opacity(0.5))
                                        .font(.system(size: 25, weight: .black, design: .rounded))
                                        .minimumScaleFactor(0.5)
                                    Spacer()
                                    Text("\(viewModel.numberOfFollowing)")
                                        .foregroundColor(.yellow.opacity(0.5))
                                        .font(.system(size: 30, weight: .black, design: .rounded))
                                        .minimumScaleFactor(0.5)
                                        .padding()
                                }
                                
                            }
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.gray.opacity(0.15))
                            .frame(height: 75)
                            .overlay() {
                                HStack() {
                                    Text("Posts:")
                                        .padding()
                                        .foregroundColor(.black.opacity(0.5))
                                        .font(.system(size: 25, weight: .black, design: .rounded))
                                        .minimumScaleFactor(0.5)
                                    Spacer()
                                    Text("\(viewModel.numberOfPosts)")
                                        .foregroundColor(.blue.opacity(0.5))
                                        .font(.system(size: 30, weight: .black, design: .rounded))
                                        .minimumScaleFactor(0.5)
                                        .padding()
                                }
                            }
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.gray.opacity(0.15))
                            .frame(height: 270)
                            .overlay() {
                                
                                VStack() {
                                    
                                    
                                    ZStack(alignment: .trailing) {
                                        VStack(alignment: .center) {
                                            
                                            HStack() {
                                                
                                                Text("Period:")
                                                    .foregroundColor(.black.opacity(0.5))
                                                    .font(.system(size: 25, weight: .black, design: .rounded))
                                                //.minimumScaleFactor(0.5)
                                                    .padding(.leading, 20)
                                                    .padding(.top, 25)
                                                
                                                Spacer()
                                                Button {
                                                    viewModel.isPeriodSelectorVisible.toggle()
                                                } label: {
                                                    
                                                    if viewModel.isPeriodSelectorVisible == true {
                                                        Text("\(viewModel.selectedPeriod)")
                                                            .foregroundColor(.black.opacity(1.0))
                                                            .font(.system(size: 25, weight: .black, design: .rounded))
                                                            .minimumScaleFactor(0.5)
                                                    } else {
                                                        Text("\(viewModel.selectedPeriod) ▼")
                                                            .foregroundColor(.black.opacity(1.0))
                                                            .font(.system(size: 25, weight: .black, design: .rounded))
                                                            .minimumScaleFactor(0.5)
                                                        
                                                    }
                                                    
                                                }
                                                .padding(.trailing, 20)
                                                .padding(.top, 25)
                                                
                                            }
                                            Spacer()
                                            HStack(alignment: .center) {

                                                if viewModel.selectedPeriod == "12 Days", viewModel.barChartUpdates.count != 0 {
                                                    BarChart(updates: viewModel.barChartUpdates.reversed())
                                                        .padding(.bottom, 5)
                                                        .animation(.easeInOut(duration: 0.75), value: viewModel.animateBarChart)
                                                        .onAppear {
                                                            viewModel.animateBarChart.toggle()
                                                        }
                                                } else if viewModel.selectedPeriod == "3 Months", viewModel.barChartUpdates.count != 0 {
                                                    BarChart(updates: viewModel.barChartUpdates.reversed())
                                                        .padding(.bottom, 5)
                                                        .animation(.easeInOut(duration: 0.75), value: viewModel.animateBarChart)
                                                        .onAppear {
                                                            viewModel.animateBarChart.toggle()
                                                        }
                                                } else if viewModel.selectedPeriod == "1 Year", viewModel.barChartUpdates.count != 0 {
                                                    BarChart(updates: viewModel.barChartUpdates.reversed())
                                                        //.padding(.bottom, 0)
                                                        .animation(.easeInOut(duration: 0.75), value: viewModel.animateBarChart)
                                                        .onAppear {
                                                            viewModel.animateBarChart.toggle()
                                                        }
                                                }

                                            }
                                            
                                        }
                                        
                                        if viewModel.isPeriodSelectorVisible == true {
                                            
                                            PeriodPopOver()
                                                .frame(width: 185, height: 195)
                                                .offset(x: -15, y: 30)
                                                .background(.white)
                                                .clipShape(
                                                    PopupArrow(cornerRadius: 10, arrowEdge: .top, arrowHeight: 15, arrowOffset: 57.5)
                                                        .offset(x: -15, y: 22.5)
                                                )
                                            
                                        } else {
                                            
                                        }
                                    }
                                }
                            }
                        
                    }//: VSTACK
                    .padding(.top, -5)
                    .padding(.leading)
                    .padding(.trailing)
                    .opacity(viewModel.isAnimating ? 1: 0)
                    .animation(.easeOut(duration: 0.75), value: viewModel.isAnimating)
                    
                    
                    
                    
                }//: SCROLLVIEW
                .opacity(viewModel.isAnimating ? 1: 0)
                .animation(.easeOut(duration: 0.75), value: viewModel.isAnimating)
                //: CENTER
                
            }//: VSTACK
        }//: ZSTACK
        .onChange(of: viewModel.selectedPeriod, perform: { newValue in
            //viewModel.getBarGraphData()
        })
        .onAppear {

            viewModel.getBarGraphData()
            viewModel.getUsersInstagramData()
            
//            let updatesToSave: [dummyDataToSave] = [.init(date: Date.from(year: 2023, month: 1, day: 5), gained_subscribers: "", number_of_followers: "8", number_of_followers_from_yesterday: "12"), .init(date: Date.from(year: 2023, month: 1, day: 4), gained_subscribers: "", number_of_followers: "9", number_of_followers_from_yesterday: "9"), .init(date: Date.from(year: 2023, month: 1, day: 3), gained_subscribers: "", number_of_followers: "9", number_of_followers_from_yesterday: "5"), .init(date: Date.from(year: 2023, month: 1, day: 2), gained_subscribers: "", number_of_followers: "5", number_of_followers_from_yesterday: "8"), .init(date: Date.from(year: 2023, month: 1, day: 1), gained_subscribers: "", number_of_followers: "8", number_of_followers_from_yesterday: "7"), .init(date: Date.from(year: 2022, month: 12, day: 31), gained_subscribers: "", number_of_followers: "7", number_of_followers_from_yesterday: "6"), .init(date: Date.from(year: 2022, month: 12, day: 30), gained_subscribers: "", number_of_followers: "7", number_of_followers_from_yesterday: "6"), .init(date: Date.from(year: 2022, month: 12, day: 29), gained_subscribers: "", number_of_followers: "5", number_of_followers_from_yesterday: "7"), .init(date: Date.from(year: 2022, month: 12, day: 28), gained_subscribers: "", number_of_followers: "6", number_of_followers_from_yesterday: "5"), .init(date: Date.from(year: 2022, month: 12, day: 27), gained_subscribers: "", number_of_followers: "3", number_of_followers_from_yesterday: "6"), .init(date: Date.from(year: 2022, month: 12, day: 26), gained_subscribers: "", number_of_followers: "6", number_of_followers_from_yesterday: "3"), .init(date: Date.from(year: 2022, month: 12, day: 25), gained_subscribers: "", number_of_followers: "8", number_of_followers_from_yesterday: "6"), .init(date: Date.from(year: 2022, month: 12, day: 24), gained_subscribers: "", number_of_followers: "5", number_of_followers_from_yesterday: "8"), .init(date: Date.from(year: 2022, month: 12, day: 23), gained_subscribers: "", number_of_followers: "6", number_of_followers_from_yesterday: "5"), .init(date: Date.from(year: 2022, month: 12, day: 22), gained_subscribers: "", number_of_followers: "7", number_of_followers_from_yesterday: "6"), .init(date: Date.from(year: 2022, month: 12, day: 21), gained_subscribers: "", number_of_followers: "6", number_of_followers_from_yesterday: "7"), .init(date: Date.from(year: 2022, month: 12, day: 20), gained_subscribers: "", number_of_followers: "4", number_of_followers_from_yesterday: "6"), .init(date: Date.from(year: 2022, month: 12, day: 19), gained_subscribers: "", number_of_followers: "5", number_of_followers_from_yesterday: "4"), .init(date: Date.from(year: 2022, month: 12, day: 5), gained_subscribers: "", number_of_followers: "8", number_of_followers_from_yesterday: "6"), .init(date: Date.from(year: 2022, month: 11, day: 5), gained_subscribers: "", number_of_followers: "8", number_of_followers_from_yesterday: "6"), .init(date: Date.from(year: 2022, month: 10, day: 5), gained_subscribers: "", number_of_followers: "9", number_of_followers_from_yesterday: "8"), .init(date: Date.from(year: 2022, month: 9, day: 5), gained_subscribers: "", number_of_followers: "7", number_of_followers_from_yesterday: "9"), .init(date: Date.from(year: 2022, month: 8, day: 5), gained_subscribers: "", number_of_followers: "4", number_of_followers_from_yesterday: "7"), .init(date: Date.from(year: 2022, month: 7, day: 5), gained_subscribers: "", number_of_followers: "8", number_of_followers_from_yesterday: "4"), .init(date: Date.from(year: 2022, month: 6, day: 5), gained_subscribers: "", number_of_followers: "6", number_of_followers_from_yesterday: "8"), .init(date: Date.from(year: 2022, month: 5, day: 5), gained_subscribers: "", number_of_followers: "5", number_of_followers_from_yesterday: "6"), .init(date: Date.from(year: 2022, month: 4, day: 5), gained_subscribers: "", number_of_followers: "5", number_of_followers_from_yesterday: "5"), .init(date: Date.from(year: 2022, month: 3, day: 5), gained_subscribers: "", number_of_followers: "8", number_of_followers_from_yesterday: "5"), .init(date: Date.from(year: 2022, month: 2, day: 5), gained_subscribers: "", number_of_followers: "6", number_of_followers_from_yesterday: "8"), .init(date: Date.from(year: 2022, month: 1, day: 5), gained_subscribers: "", number_of_followers: "5", number_of_followers_from_yesterday: "6"), .init(date: Date.from(year: 2022, month: 1, day: 5), gained_subscribers: "", number_of_followers: "5", number_of_followers_from_yesterday: "6"), .init(date: Date.from(year: 2022, month: 12, day: 26), gained_subscribers: "", number_of_followers: "4", number_of_followers_from_yesterday: "6"), .init(date: Date.from(year: 2022, month: 12, day: 19), gained_subscribers: "", number_of_followers: "5", number_of_followers_from_yesterday: "6"), .init(date: Date.from(year: 2022, month: 12, day: 12), gained_subscribers: "", number_of_followers: "5", number_of_followers_from_yesterday: "8"), .init(date: Date.from(year: 2022, month: 12, day: 5), gained_subscribers: "", number_of_followers: "7", number_of_followers_from_yesterday: "9"), .init(date: Date.from(year: 2022, month: 11, day: 26), gained_subscribers: "", number_of_followers: "6", number_of_followers_from_yesterday: "7"), .init(date: Date.from(year: 2022, month: 11, day: 19), gained_subscribers: "", number_of_followers: "8", number_of_followers_from_yesterday: "4"), .init(date: Date.from(year: 2022, month: 11, day: 12), gained_subscribers: "", number_of_followers: "7", number_of_followers_from_yesterday: "8"), .init(date: Date.from(year: 2022, month: 11, day: 5), gained_subscribers: "", number_of_followers: "9", number_of_followers_from_yesterday: "6"), .init(date: Date.from(year: 2022, month: 10, day: 26), gained_subscribers: "", number_of_followers: "5", number_of_followers_from_yesterday: "5"), .init(date: Date.from(year: 2022, month: 10, day: 19), gained_subscribers: "", number_of_followers: "6", number_of_followers_from_yesterday: "5"), .init(date: Date.from(year: 2022, month: 10, day: 12), gained_subscribers: "", number_of_followers: "3", number_of_followers_from_yesterday: "8"), .init(date: Date.from(year: 2022, month: 10, day: 5), gained_subscribers: "", number_of_followers: "6", number_of_followers_from_yesterday: "6")]
//
//            for save in updatesToSave {
//
//                coreDataStack.addUpdate(number_of_followers: save.number_of_followers, gained_subscribers: save.gained_subscribers, number_of_followers_from_yesterday: save.number_of_followers_from_yesterday, date_of_last_update: save.date, date_of_last_saved_update: save.date)
//
//            }
            
        }
        .overlay() {
            ProgressView()
                .progressViewStyle(.circular)
                .foregroundColor(.black.opacity(0.15))
                .scaleEffect(2.0)
                .ignoresSafeArea(.all)
                .padding(0)
                .opacity(viewModel.isFetching ? 1: 0)
                .animation(.easeOut(duration: 0.5), value: viewModel.isFetching)
        }
        .alert("Failed To Save Fetched Data", isPresented: $coreDataStack.failedToSave) {
            Button("OK", role: .cancel) {
            }
        } message: {
            Text("Please try again!")
        }
        .alert("Failed To Schedule Background Task", isPresented: $viewModel.failedToScheduleBGTask) {
            Button("OK", role: .cancel) {
            }
        } message: {
            Text("Your widget won't be updated. Please, try refreshing data!")
        }
        
    }
}

struct ProfileStatsView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileStatsView()
    }
}

struct dummyDataToSave {
    
    var date: Date
    var gained_subscribers: String
    var number_of_followers: String
    var number_of_followers_from_yesterday: String
    
}

extension Date {
    static func from(year: Int, month: Int, day: Int) -> Date {
        let components = DateComponents(year: year, month: month, day: day)
        return Calendar.current.date(from: components)!
    }
    
}
