//
//  ContentView.swift
//  SPMInXcodeProject
//
//  Created by Anthony Miller on 9/26/22.
//

import SwiftUI
import ApolloWrapper
import AnimalKingdomAPI

struct ContentView: View {
//  let dogData = try! ApolloWrapper.buildDogQuery()

  var body: some View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundColor(.accentColor)
      Text("Hello")
    }
    .padding()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
