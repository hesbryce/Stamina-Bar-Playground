//
//  ContentView.swift
//  TabViewTest Watch App
//
//  Created by Bryce Ellis on 2/9/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                    NavigationLink(destination: DetailView()) {
                        Text("Go to Stress View")
                }
                NavigationLink(destination: DetailView2()) {
                    Text("Go to Exercise View")
            }
                NavigationLink(destination: DetailView3()) {
                    Text("Go to Rest View")
            }
            }
        }
    }
}

struct DetailView: View {
    var body: some View {
        Text("This is the Stress view")
    }
}

struct DetailView2: View {
    var body: some View {
        Text("This is the Exercise view")
    }
}

struct DetailView3: View {
    var body: some View {
        Text("This is the Rest view")
    }
}
