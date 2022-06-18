//
//  ContentView.swift
//  VideoPlayerTools
//
//  Created by Eli Hartnett on 6/17/22.
//

import SwiftUI

struct ContentView: View {
    
    var now = Date()
    var future = Calendar.current.date(byAdding: .minute, value: 2, to: Date())
    
    var body: some View {
        
        Rectangle()
            .fill(.primary)
            .ignoresSafeArea()
            .overlay(alignment: .bottom) {
                CustomTimer(totalSeconds: (future?.timeIntervalSince(now))!)
                    .padding()
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
