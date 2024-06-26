//  Created by Aisultan Askarov on 27.11.2022.
//

import SwiftUI
import FacebookLogin

struct SigninView: View {
    
    //MARK: - PROPERTY
    @AppStorage("showAuthPage") private var presentAuthorizationPage = false

    @StateObject private var authorizationModel = AuthorizationAPI.shared
    @State private var token = AccessToken.current
    
    @State private var buttonWidth: Double = UIScreen.main.bounds.width - 80
    @State private var buttonOffset: CGFloat = 0
    @State private var imageOffset: CGSize = .zero
    @State private var indicatorOpacity: Double = 1.0
    @State private var isAnimating: Bool = false

    let hapticFeedback = UINotificationFeedbackGenerator()
    
    //MARK: - BODY
    
    var body: some View {
        ZStack {
            Color("ColorGray")
                .ignoresSafeArea(.all, edges: .all)
            VStack(spacing: 80) {
                //MARK: - HEADER
                
                //Spacer()
                
                VStack(spacing: 0) {
                    Text("Track Your Instagram Followers")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(.secondary)
                        .transition(.opacity)
                        .multilineTextAlignment(.center)
                    Text("Sign-in with your Facebook Business account, and keep track of your instagram page followers.")
                    .font(.title3)
                    .fontWeight(.regular)
                    .foregroundColor(.gray.opacity(0.65))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32.5)
                    .padding(.top, 20)
                    
                } //: HEADER
                .opacity(isAnimating ? 1: 0)
                .offset(y: isAnimating ? 0: -40)
                .animation(.easeOut(duration: 1), value: isAnimating)
                .padding(.top, 50)
                
                //Spacer()
                
                //MARK: - CENTER
                ZStack {
                    WidgetPreviewView(ShapeColor: .gray, ShapeOpacity: 0.15)
                        .offset(x: imageOffset.width * -1)
                        .blur(radius: abs(imageOffset.width / 80))
                        .animation(.easeOut(duration: 1), value: imageOffset)
                        .opacity(isAnimating ? 1: 0)
                        .animation(.easeOut(duration: 0.75), value: isAnimating)
                        .offset(x: imageOffset.width * 1.2, y: 0)
                        .rotationEffect(.degrees(Double(imageOffset.width / 80)))
                        .gesture(
                            DragGesture()
                                .onChanged({ gesture in
                                    if abs(imageOffset.width) <= 250 {
                                        imageOffset = gesture.translation
                                    }
                                })
                                .onEnded({ _ in
                                    withAnimation(.linear(duration: 0.25)) {
                                        imageOffset = .zero
                                    }
                                })
                        )//: GESTURE
                        .animation(.easeOut(duration: 0.25), value: imageOffset)
                    
                } //: CENTER
                
                Spacer()
                
                //MARK: - FOOTER
                
                ZStack {
                    
                    //PARTS OF THE CUSTOM BUTTON
                    
                    //1. BACKGROUND (STATIC)
                    Capsule()
                        .fill(.white.opacity(1.0))
                    
                    Capsule()
                        .fill(.white.opacity(1.0))
                        .padding(8)
                    
                    //2. CALL-TO-ACTION (STATIC)
                    Text("Sign-in with Facebook")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(Color("ColorBlue"))
                        .offset(x: 20)
                    
                    //3. CAPSULE (DYNAMIC WIDTH)
                    HStack {
                        Capsule()
                            .fill(Color("ColorBlue"))
                            .frame(width: buttonOffset + 80)
                        
                        Spacer()
                        
                    }
                    
                    //4. CIRCLE (DRAGGABLE)
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color("ColorBlue"))
                            Circle()
                                .fill(.black.opacity(0.15))
                                .padding(8)
                            Image(systemName: "chevron.right.2")
                                .font(.system(size: 24, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80, alignment: .center)
                        .offset(x: buttonOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    if gesture.translation.width > 0 && buttonOffset <= buttonWidth - 80 {
                                        buttonOffset = gesture.translation.width
                                    }
                                }
                                .onEnded { _ in
                                    withAnimation() {
                                        if buttonOffset > buttonWidth / 2 {
                                            buttonOffset = buttonWidth - 80
                                            //MARK: -Log in using Facebook SDK
                                            //authorizationModel.isLogingin
                                            authorizationModel.logIn()
                                            //authorizationModel.isLoggedin
                                            //presentAuthorizationPage.toggle()
                                        } else {
                                            hapticFeedback.notificationOccurred(.warning)
                                            buttonOffset = 0
                                        }
                                    }
                                }
                        )//: GESTURE
                        .alert("Important message", isPresented: $authorizationModel.logInFailed) {
                            Button("OK", role: .cancel) { }
                        }
                        Spacer()
                    }//: HSTACK
                }//: FOOTER
                .frame(width: buttonWidth, height: 80, alignment: .center)
                .padding()
                .opacity(isAnimating ? 1: 0)
                .offset(y: isAnimating ? 0: 40)
                .animation(.easeOut(duration: 1), value: isAnimating)
                
            }//: VSTACK
        } //: ZSTACK
        .onAppear {
            isAnimating = true
        }
        .overlay() {
            ProgressView()
                .progressViewStyle(.circular)
                .foregroundColor(.black.opacity(0.15))
                .scaleEffect(2.0)
                .ignoresSafeArea(.all)
                .padding(0)
                .opacity(authorizationModel.isLogingin ? 1: 0)
                .animation(.easeOut(duration: 0.5), value: authorizationModel.isLogingin)
        }
        .preferredColorScheme(.light)
    }
}

struct SigninView_Previews: PreviewProvider {
    static var previews: some View {
        SigninView()
    }
}
