//
//  HomeView.swift
//  Barcode Scanner
//
//  Created by Israel Manzo on 4/23/24.
//

import SwiftUI
import VisionKit

struct HomeView: View {
    
    @Environment(\.verticalSizeClass) var verticalSize
    @EnvironmentObject var vm: ViewModel
    
    private let textContentType: [(title: String, textContentType: DataScannerViewController.TextContentType?)] = [
        ("All", .none), ("URL", .URL), ("Phone", .telephoneNumber), ("Email", .emailAddress), ("Address", .fullStreetAddress)
    ]
    
    var body: some View {
        switch vm.scannerAccesStatus {
        case .undetermined:
            Text("Requesting camera access")
        case .cameraAccessDenied:
            Text("Please provide access to camera settings")
        case .cameraUnavailable:
            Text("This device don't have a camera")
        case .scannerAvailable:
            mainView
        case .scannerUnavailable:
            Text("This device don't support camera")
        }
    }
    
    private var mainView: some View {
        VStack {
            if verticalSize == .compact {
                HStack {
                    DataScannerView(recognizedItems: $vm.recognizedItems, recognizedDataType: vm.recognizedDataType, recognizedMultipleItems: vm.recognizedMulitpleItems)
                    //            .frame(height: 350)
                        .background(Color.gray.opacity(0.3))
                        .ignoresSafeArea()
                        .id(vm.dataScannerViewId)
                    bodyView
                        .background(.ultraThinMaterial)
                        .presentationDetents([.medium, .fraction(100)])
                        .presentationDragIndicator(.visible)
                        .interactiveDismissDisabled()
                        .onAppear {
                            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                  let controller = windowScene.windows.first?.rootViewController?.presentedViewController else { return }
                            controller.view.backgroundColor = .clear
                        }
                }
            } else {
                VStack {
                    DataScannerView(recognizedItems: $vm.recognizedItems, recognizedDataType: vm.recognizedDataType, recognizedMultipleItems: vm.recognizedMulitpleItems)
                    //            .frame(height: 350)
                        .background(Color.gray.opacity(0.3))
                        .ignoresSafeArea()
                        .id(vm.dataScannerViewId)
                        .sheet(isPresented: .constant(true)) {
                            bodyView
                                .background(.ultraThinMaterial)
                                .presentationDetents([.medium, .fraction(100)])
                                .presentationDragIndicator(.visible)
                                .interactiveDismissDisabled()
                                .onAppear {
                                    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                          let controller = windowScene.windows.first?.rootViewController?.presentedViewController else { return }
                                    controller.view.backgroundColor = .clear
                                }
                        }
                }
            }
            
        }
        .onChange(of: vm.scanType) { _, _ in
            vm.recognizedItems = []
        }
        .onChange(of: vm.textContentType) { _, _ in
            vm.recognizedItems = []
        }
        .onChange(of: vm.recognizedMulitpleItems) { _, _ in
            vm.recognizedItems = []
        }
    }
    
    private var headerView: some View {
        VStack {
            HStack {
                Picker("Scan Type", selection: $vm.scanType) {
                    Text("Barcode")
                        .tag(ScanType.barcode)
                    Text("Text")
                        .tag(ScanType.text)
                }
                .pickerStyle(.segmented)
                
                Toggle("Scan Multiple", isOn: $vm.recognizedMulitpleItems)
            }
            .padding(.top)
            
            if vm.scanType == .text {
                Picker("Text content type", selection: $vm.textContentType) {
                    ForEach(textContentType, id: \.self.textContentType) {
                        Text($0.title)
                            .tag($0.textContentType)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Text(vm.headerText)
                .padding(.top)
        }
        .padding(.horizontal)
    }
    
    private var bodyView: some View {
        VStack {
            headerView
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(vm.recognizedItems) { item in
                        switch item {
                        case .barcode(let barcode):
                            Text(barcode.payloadStringValue ?? "Unknown barcode")
                        case .text(let text):
                            Text(text.transcript)
                        @unknown default:
                            Text("Unknown")
                        }
                    }
                }
                .padding()
            }
        }
    }
}

//#Preview {
//    HomeView()
//}
