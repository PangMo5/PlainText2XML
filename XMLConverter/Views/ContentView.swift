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
        ZStack {
            HStack {
                itemView
                Divider()
                parserView
            }
            Button {
                viewModel.convertToXML()
            } label: {
                VStack {
                    Text("Convert!")
                }
            }
        }
    }

    var itemView: some View {
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
            Divider()
            List(viewModel.visibleItemList, id: \.self) { item in
                VStack(alignment: .leading) {
                    Text(item)
                    Divider()
                }
            }
            Divider()
            Text("Filtered count: \(viewModel.visibleItemList.count)")
                .padding(.bottom, 4)
        }
    }

    var parserView: some View {
        VStack(alignment: .leading) {
            Group {
                Text(#"Element Separator (ex: ,)"#)
                    .padding(.top)
                TextEditor(text: $viewModel.elementSeperatorText)
                    .frame(height: 64)
//                Text(#"Array Separator (ex: ,)"#)
//                TextEditor(text: $viewModel.arraySeperatorText)
//                    .frame(height: 64)
                Text(#"Separator (ex: :)"#)
                TextEditor(text: $viewModel.seperatorText)
                    .frame(height: 64)
                TextField("Envelope Name",text: $viewModel.envelopeText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)
            Divider()
            Toggle("Use same field names", isOn: $viewModel.isSameField)
            HStack {
                VStack {
                    TextField("Before filed name", text: $viewModel.beforeFieldText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("XML filed name", text: $viewModel.xmlFieldText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                Button {
                    viewModel.addField()
                } label: {
                    Image(systemName: "plus")
                }
                .disabled(viewModel.isEmptyFieldTexts)
            }
            .padding()
            .disabled(viewModel.isSameField)
            HStack {
                Text("Before Fields")
                    .font(.title)
                    .frame(maxWidth: .infinity)
                Divider()
                Text("XML Fields")
                    .font(.title)
                    .frame(maxWidth: .infinity)
            }
            .frame(height: 20)
            Divider()
            List {
                ForEach(viewModel.fieldList, id: \.self) { field in
                    VStack {
                        HStack {
                            Text(field.before)
                                .frame(maxWidth: .infinity)
                            Divider()
                            Text(field.xml)
                                .frame(maxWidth: .infinity)
                            Button {
                                viewModel.removeField(with: field)
                            } label: {
                                Image(systemName: "minus")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        Divider()
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
