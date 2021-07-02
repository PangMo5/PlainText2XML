//
//  ContentView.swift
//  XMLConverter
//
//  Created by PangMo5 on 2021/07/02.
//

import SwiftUI

struct ContentView: View {
    @StateObject
    var viewModel = ContentViewModel()

    var body: some View {
        VStack {
            HStack {
                TextField("path...", text: $viewModel.currentPath)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button {
                    viewModel.selectDirectory()
                } label: {
                    Text("Open In...")
                }
            }
            Text(viewModel.xml.render())
                .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
