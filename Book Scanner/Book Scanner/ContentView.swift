//
//  ContentView.swift
//  Book Scanner
//
//  Created by Israel Manzo on 12/2/23.
//

import SwiftUI

struct ContentView: View {
    
    @State var isPresented = false
    @State var isbn: String?
    @State var foundBooks: Books?
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text("\(foundBooks?.items.first?.volumeInfo.title ?? "Book Title")")
                        .font(.title2)
                    Text("\(foundBooks?.items.first?.volumeInfo.subtitle ?? "Subtitle")")
                    Text("by \(foundBooks?.items.first?.volumeInfo.authors?.first ?? "Author")")
                        .font(.callout)
                } header: {
                    Text("Books")
                }
                Section {
                    Text("\(foundBooks?.items.first?.volumeInfo.publishedDate ?? "Published date")")
                    Text("\(foundBooks?.items.first?.volumeInfo.pageCount ?? 0)")
                    Text("Lang: \(foundBooks?.items.first?.volumeInfo.language ?? "Language")")
                    Text("ISBN: \(isbn ?? "ISBN")")
                } header: {
                    Text("Info")
                }
            }
            .navigationTitle("Books")
            .toolbar {
                Button {
                    self.isPresented.toggle()
                } label: {
                    Image(systemName: "barcode")
                }
                .sheet(isPresented: $isPresented, content: {
                    BarCodeScanner(isbn: $isbn, foundBooks: $foundBooks)
                })
            }
        }
    }
}

#Preview {
    HomeScannerView()
}



