//
//  ContentView.swift
//  Nexus
//
//  Created by Litezevin on 9/2/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.black)
            Text("Hello, world!")
                .foregroundColor(.black)
        }
        .padding()
        .background(Color.white)
    }
}

#Preview {
    ContentView()
}
