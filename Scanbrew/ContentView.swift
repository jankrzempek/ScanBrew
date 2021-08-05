//
//  ContentView.swift
//  Scanbrew
//
//  Created by Jan Krzempek on 27/06/2021.
//

import CoreML
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import SwiftUI
import Vision

struct ContentView: View {
    let settings = FirestoreSettings()
    let storage = Storage.storage().reference()
    let db = Firestore.firestore()
    @State var title = "Proszę, zeskanuj piwo."
    @State var showButtons = false
    @State var errorAlert = false
    @State private var image: Image?
    @State var array: [String] = []
    @State var TestString: String = ""
    @State var name = "Nazwa piwa"
    @State var blessYou = ""
    @State var WGALabel = ""
    @State var IBULabel = ""
    @State var alcoholLabel = ""
    @State var isBack = ""
    @StateObject var viewModel = ViewModel()
    var body: some View {
        VStack {
            Text("\(name)")
                .font(.title)
                .bold()
            Spacer()
            HStack {
                Spacer()
                if showButtons {
                Button(action: {
                    title = "Super!"
                    print("Edit button was tapped")
                    showButtons = false
                }) {
                    Image(systemName: "checkmark.shield")
                        .resizable()
                        .scaledToFill()
                        .foregroundColor(Color.green)
                }
                .padding()
                .frame(width: 80, height: 80, alignment: .center)
                .overlay(
                       RoundedRectangle(cornerRadius: 40)
                           .stroke(Color.green, lineWidth: 2)
                   )
                .shadow(radius: 2)
                }
                Spacer()
                imageView(for: viewModel.selectedImage)
                Spacer()
                if showButtons {
                Button(action: {
                    sendToCollection()
                    showButtons = false
                    title = "Zeskanuj kolejną butelkę"
                }) {
                    Image(systemName: "xmark.shield")
                        .resizable()
                        .scaledToFill()
                        .foregroundColor(Color.red)
                }
                .padding()
                .frame(width: 80, height: 80, alignment: .center)
                .overlay(
                       RoundedRectangle(cornerRadius: 40)
                           .stroke(Color.red, lineWidth: 2)
                   )
                .shadow(radius: 2)
                }
                Spacer()
            }
            Spacer()
            Button(title) {
               print("TRUE")
            }
            .font(.subheadline)
            .foregroundColor(.white)
            .padding()
            .background(Color.purple)
            .clipShape(Capsule())
            .disabled(true)
            HStack {
                Spacer()
                VStack {
                    Button("\(alcoholLabel)\n%") {
                        // action here
                    }
                    .font(.system(size: 21, weight: .bold, design: .default))
                    .multilineTextAlignment(.center)
                    .frame(width: 85, height: 85, alignment: .center)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.orange)
                    .clipShape(Circle())
                    .disabled(true)
                    
                    Button("\(IBULabel)\nIBU") {
                        // action here
                    }
                    .font(.system(size: 21, weight: .bold, design: .default))
                    .multilineTextAlignment(.center)
                    .frame(width: 85, height: 85, alignment: .center)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.orange)
                    .clipShape(Circle())
                    .disabled(true)
                }
                Spacer()
                VStack {
                    Button("\(WGALabel)\nWGA") {
                        // action here
                    }
                    .font(.system(size: 21, weight: .bold, design: .default))
                    .multilineTextAlignment(.center)
                    .frame(width: 85, height: 85, alignment: .center)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.orange)
                    .clipShape(Circle())
                    .disabled(true)
                    
                    Button("\(isBack)\nZwrotna") {
                        // action here
                    }
                    .font(.system(size: 21, weight: .bold, design: .default))
                    .multilineTextAlignment(.center)
                    .frame(width: 85, height: 85, alignment: .center)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.orange)
                    .clipShape(Circle())
                    .disabled(true)
                }
                Spacer()
            }.padding()
            
            Text("Skanuj za pomocą:")
                .bold()
            HStack {
                Spacer()
                Button("Kamera") {
                    viewModel.takePhoto()
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.purple)
                .clipShape(Capsule())
                .shadow(radius: 5)
                Spacer()
                
                Button("Galeria") {
                    viewModel.choosePhoto()
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.purple)
                .clipShape(Capsule())
                .shadow(radius: 5)
                
                Spacer()
            }.padding()
        }.fullScreenCover(isPresented: $viewModel.isPresentingImagePicker, content: {
            ImagePicker(sourceType: viewModel.sourceType, completionHandler: viewModel.didSelectImage).ignoresSafeArea()
        })
            .onChange(of: viewModel.selectedImage) { value in
                if value != nil {
                guard let ciiImage = CIImage(image: value!) else {
                    fatalError("Sorry")
                }
                detectBottle(image: ciiImage)
                }
            }
        .alert(isPresented: $errorAlert, content: {
            Alert(title: Text("Błąd"), message: Text("Coś poszło nie tak."), dismissButton: .default(Text("OK")))
        })
    }

    @ViewBuilder
    func imageView(for image: UIImage?) -> some View {
        if let image = image {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
//                .scaledToFit()
        } else {
            Text("Nie wybrano zdjęcia")
        }
    }
    
    public func sendToCollection() {
        guard let pngImage = viewModel.selectedImage?.pngData() else {
            print("ERROR")
            errorAlert = true
            return
        }
        let uuid = UUID()
        let riversRef = storage.child("ImproveBeers/image\(uuid).png")

        riversRef.putData(pngImage, metadata: nil) { metadata, _ in
            guard metadata != nil else {
                print("error")
                errorAlert = true
                return
            }
            print("SEND")
        }
    }
    
    public func getCollection(name: String) {
        // [START get_collection]
        array = []
        let docRef = db.collection("BeerData").document(name)
        docRef.getDocument { [self] document, _ in
            if let document = document, document.exists {
                var dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                
                for (_, char) in dataDescription.enumerated() {
                    if char != ">" {
                        dataDescription.removeFirst()
                    } else {
                        dataDescription.removeFirst()
                        break
                    }
                }
                // VERSION READY TO USE WITH FULL NAME
                for (_, char) in dataDescription.enumerated() {
                    if char != "[", char != "]", char != "(", char != ")", char != ",", char != "\n" {
                        self.TestString += String(char)
                    }
                    if char == "," {
                        if self.TestString != "" {
                            array.append(String(self.TestString))
                            self.TestString = ""
                        }
                    }
                    if char == ")" {
                        if self.TestString != "" {
                            self.array.append(String(self.TestString))
                            self.TestString = ""
                        }
                    }
                }
                if self.array.count == 5 {
                    // uploading real photo
                    // finish uploading
                    let IBUVAL = self.array[2]
                    let firstArray = self.array[1]
                    let WGABeer = Double(self.array[4])
                    alcoholLabel = firstArray
                    self.name = String(self.array[0])
                    IBULabel = IBUVAL
                    WGALabel = String(WGABeer!)
                    if self.array[3] == "1" {
                        isBack = "Tak"
                    } else {
                        isBack = "Nie"
                    }
                    
                    // 15% of alcohol is taken as the maximum possible value
                    
                    self.blessYou = "Na Zdrowie 🍺!"
                } else {
                    self.blessYou = "Problem z danymi, wybacz."
                    self.name = "---"
                }
            } else {
                print("Document does not exist")
                self.blessYou = "Nie posiadam danych :("
                self.name = "---"
            }
        }
    }
    
    public func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: BeerImageClassifier_1_1_03(configuration: .init()).model) else {
            fatalError("Wybacz")
        }
        let request = VNCoreMLRequest(model: model) { request, _ in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Wybacz")
            }
            
            if let firstResult = results.first {
                let nameL = firstResult.identifier
                blessYou = "Anaizuję!"
                self.getCollection(name: nameL)
            }
        }
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
    func detectBottle(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: IfIsABottleModel_1(configuration: .init()).model) else {
            fatalError("Sorry")
        }
        let request = VNCoreMLRequest(model: model) { request, _ in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Sorry")
            }
            
            if let firstResult = results.first {
                if firstResult.identifier == "Bottle" {
                    self.detect(image: image)
                    title = "Czy butelka jest poprawna?"
                    showButtons = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                        title = "Zeskanuj kolejną butelkę"
                        showButtons = false
                    }
                } else {
                    blessYou = "To nie jest butelka piwa"
                    name = "Nazwa na to nie istnieje"
                    alcoholLabel = "-"
                    IBULabel = "-"
                    WGALabel = "-"
                    isBack = "-"
                }
            }
        }
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
}

extension ContentView {
    final class ViewModel: ObservableObject {
        @Published var selectedImage: UIImage?
        @Published var isPresentingImagePicker = false
        private(set) var sourceType: ImagePicker.SourceType = .camera
        
        func choosePhoto() {
            sourceType = .photoLibrary
            isPresentingImagePicker = true
        }
        
        func takePhoto() {
            sourceType = .camera
            isPresentingImagePicker = true
        }
        
        func didSelectImage(_ image: UIImage?) {
            selectedImage = image
            isPresentingImagePicker = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
