//
//  BodyView.swift
//  Barcode Scanner
//
//  Created by Israel Manzo on 4/25/24.
//

import SwiftUI

struct BodyView: View {
    
    @State var items: [String] = []
    
    var body: some View {
        List(0..<10) { item in
            Text("\(item)")
        }
    }
}

#Preview {
    BodyView()
}
