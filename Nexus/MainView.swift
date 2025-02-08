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
                HStack {
                    VStack(alignment: .leading) {
                        Text("Streak: \(streak)")
                        Text(isPremium ? "Premium" : "Free")
                            .foregroundColor(isPremium ? .yellow : .gray)
                    }
                    Spacer()
                    
                    // Кнопка с аватаркой
                    Button(action: {
                        // Открыть настройки или поделиться
                    }) {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text("Me")
                                    .foregroundColor(.white)
                                    .font(.system(size: 10))
                            )
                    }
                }
                .padding()
                
                Spacer()
                
                // Кнопка "Начать урок"
                NavigationLink(destination: LessonView()) {
                    ZStack {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 120, height: 120)
                        Text("Начать урок")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
                
                Spacer()
            }
            .navigationBarHidden(true) // Скрываем NavigationBar для минималистичного вида
        }
    }
}
