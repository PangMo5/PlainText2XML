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
            TextField("Regex", text: $viewModel.regex)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding([.top, .horizontal])
            HStack {
                TextField("Path...", text: $viewModel.currentPath)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button {
                    viewModel.selectDirectory()
                } label: {
                    Text("Open In...")
                }
            }
            .padding(.horizontal)
            List(viewModel.visibleItemList, id: \.self) { item in
                VStack(alignment: .leading) {
                    Text(item)
                    Divider()
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
