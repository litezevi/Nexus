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
                // Верхняя панель
                HStack(spacing: 16) {
                    HStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("\(streak)")
                            .font(.system(size: 18, weight: .bold))
                    }
                    
                    Capsule()
                        .fill(isPremium ? LinearGradient(gradient: Gradient(colors: [.yellow, .orange]), startPoint: .leading, endPoint: .trailing) : LinearGradient(gradient: Gradient(colors: [.gray, .black]), startPoint: .leading, endPoint: .trailing))
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
                            .frame(width: 32, height: 32)
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                
                Spacer()
                
                // Кнопка "Начать урок"
                ZStack {
                    // Progress ring background
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 6)
                        .frame(width: 140, height: 140)
                    
                    // Progress ring
                    Circle()
                        .trim(from: 0, to: 0.75)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(
                                lineWidth: 6,
                                lineCap: .round
                            )
                        )
                        .frame(width: 140, height: 140)
                        .rotationEffect(.degrees(-90))
                    
                    // Main button
                    NavigationLink(destination: LessonView()) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [.blue, .purple]),
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
                        .scaleEffect(1.0)
                        .animation(
                            Animation.easeInOut(duration: 1.2)
                                .repeatForever(autoreverses: true),
                            value: 1.0
                        )
                    }
                }
                
                Spacer()
            }
            .navigationBarHidden(true) // Скрываем NavigationBar для минималистичного вида
        }
    }
}
