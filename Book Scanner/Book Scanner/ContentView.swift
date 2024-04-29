//
//  ContentView.swift
//  Book Scanner
//
//  Created by Israel Manzo on 12/2/23.
//

import SwiftUI

struct Books: Decodable {
    var items: [BookItem]
}

struct BookItem: Decodable {
    let id: String
    let volumeInfo: VolumeInfo
}

struct VolumeInfo: Decodable {
    let title: String
    let subtitle: String?
    let authors: [String]?
    let publishedDate: String?
    let pageCount: Int?
    let language: String?
}

struct ContentView: View {
    
    @State var isPresented = false
    @State var isbn: String?
    @State var foundBooks: Books?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Books")) {
                    Text("\(foundBooks?.items.first?.volumeInfo.title ?? "Book Title")")
                        .font(.title2)
                    Text("\(foundBooks?.items.first?.volumeInfo.subtitle ?? "Subtitle")")
                    Text("by \(foundBooks?.items.first?.volumeInfo.authors?.first ?? "Author")")
                        .font(.callout)
                }
                Section(header: Text("Info")) {
                    Text("\(foundBooks?.items.first?.volumeInfo.publishedDate ?? "Published date")")
                    Text("\(foundBooks?.items.first?.volumeInfo.pageCount ?? 0)")
                    Text("Lang: \(foundBooks?.items.first?.volumeInfo.language ?? "Language")")
                    Text("ISBN: \(isbn ?? "ISBN")")
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
    ContentView()
}

import UIKit
import AVFoundation

final class SearchBookManager {
    
    static let shred = SearchBookManager()
    
    func search(isbn: String, completion: @escaping (Books) -> Void) {
        
        let sessionConfiguration = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfiguration)
        
        guard var url = URL(string: "https://www.googleapis.com/books/v1/volumes/") else { return }
        
        url.append(queryItems: [URLQueryItem(name: "q", value: "isbn:\(isbn)")])
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                print("Error in url session")
               return
            }
            guard let data = data else { return }
            do {
                let bookData = try JSONDecoder().decode(Books.self, from: data)
                completion(bookData)
            } catch {
                print("Error decoding book data")
            }
        }
        task.resume()
    }
}



struct BarCodeScanner: UIViewControllerRepresentable {
    @Binding var isbn: String?
    @Binding var foundBooks: Books?
    
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .black
        context.coordinator.captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { 
            fatalError("Could not capture video")
        }
        
        let videoInput: AVCaptureDeviceInput
        videoInput = try! AVCaptureDeviceInput(device: videoCaptureDevice)
        
        if context.coordinator.captureSession.canAddInput(videoInput) {
            context.coordinator.captureSession.addInput(videoInput)
        } else {
            print("Could not add input from session")
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if context.coordinator.captureSession.canAddOutput(metadataOutput) {
            context.coordinator.captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417]
        } else {
            print("No output")
        }
        
        context.coordinator.previewLayer = AVCaptureVideoPreviewLayer(session: context.coordinator.captureSession)
        context.coordinator.previewLayer.frame = viewController.view.layer.bounds
        context.coordinator.previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(context.coordinator.previewLayer)
        
        DispatchQueue.global(qos: .background).async {
            context.coordinator.captureSession.startRunning()
        }
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        let parent: BarCodeScanner
        
        var captureSession: AVCaptureSession!
        var previewLayer: AVCaptureVideoPreviewLayer!
        
        init(_ parent: BarCodeScanner) {
            self.parent = parent
        }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            guard let metadataObject = metadataObjects.first,
                  let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                  let stringValue = readableObject.stringValue else { return }
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            foundCode(of: stringValue)
            captureSession.stopRunning()
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func foundCode(of isbn: String) {
            print(isbn)
            parent.isbn = isbn
            
            // Search Book manager
            SearchBookManager.shred.search(isbn: isbn) { [weak self] books in
                DispatchQueue.main.async {
                    if let self {
                        self.parent.foundBooks = books
                    }
                }
            }
        }
    }
    
    
    
}
