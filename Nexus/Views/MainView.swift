//
//  MainView.swift
//  NexusApp
//

import SwiftUI

struct MainView: View {
    
    @State private var streak: Int = 5
    @State private var isPremium: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Верхняя панель
                HStack(spacing: 16) {
                    HStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.black)
                        Text("\(streak)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color.lightGray)
                    }
                    
                    Capsule()
                        .fill(isPremium ? Color.mediumGray : Color.lightGray)
                        .frame(width: 80, height: 24)
                        .overlay(
                            Text(isPremium ? "PRO" : "FREE")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        )
                    
                    Spacer()
                    
                    // Профиль с иконкой
                    Menu {
                        Button("Настройки") {}
                        Button("Поделиться") {}
                    } label: {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.black)
                            .background(
                                Circle()
                                    .fill(Color.lightGray)
                                    .frame(width: 44, height: 44)
                            )
                            .offset(y: 4)
                    }
                }
                .padding()
                
                Spacer()
                
                // Кнопка "Начать урок"
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 6)
                        .frame(width: 140, height: 140)
                    
                    Circle()
                        .trim(from: 0, to: 0.75)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [.black, .black]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 140, height: 140)
                        .rotationEffect(.degrees(-90))
                    
                    NavigationLink(destination: LessonView()) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [Color.mediumGray, Color.darkGray]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing)
                                )
                                .frame(width: 120, height: 120)
                                .shadow(color: .blue.opacity(0.4), radius: 16, x: 0, y: 4)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                            
                            VStack(spacing: 4) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 24))
                                    .offset(y: 2)
                                
                                Text("Начать урок")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(.white)
                        }
                    }
                }
                
                Spacer()
            }
            .background(Color.darkGray) // <-- исправленный код, фон добавляется здесь
            .tint(.black)
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    MainView()
}
