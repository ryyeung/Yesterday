import SwiftUI
import PhotosUI

class AlbumList: ObservableObject {
    @Published var albumList: [Album] = []

    func addAlbum(named name: String, selectedImages: [Image] = []) {
        let newAlbum = Album(name: name, selectedImages: selectedImages)
        albumList.append(newAlbum)
    }
}

class Album: ObservableObject, Identifiable {
    @Published var selectedImages = [Image]()
    @Published var name = ""
    let id: UUID

    init(name: String = "", selectedImages: [Image] = [], id: UUID = UUID()) {
        self.name = name
        self.selectedImages = selectedImages
        self.id = id
    }
}

struct HomePage: View {
    @StateObject var albumList: AlbumList = AlbumList()

    var body: some View {
        NavigationView {
            ZStack {
                Color.orange.ignoresSafeArea()
                VStack {
                    Spacer().padding(.bottom)
                    NavigationLink(destination: ContentView(albumList: albumList)) {
                        Text("Create New Album")
                            .padding(.all)
                            .background(Color.white)
                            .foregroundColor(.orange)
                            .font(.system(size: 20))
                            .cornerRadius(8.0)
                    }
                    Spacer()
                    ScrollView {
                        ForEach(albumList.albumList) { album in
                            Text(album.name)
                                .padding(.horizontal)
                                .background(Color.white)
                                .foregroundColor(.orange)
                                .font(.system(size: 20))
                                .cornerRadius(5.0)
                        }
                    }
                }
            }
        }
    }
}

struct ContentView: View {
    @ObservedObject var albumList: AlbumList
    @State private var pickerItems = [PhotosPickerItem]()
    @StateObject var album: Album = Album()
    @State var enteredName: String = ""

    var body: some View {
        ZStack {
            Color.orange.ignoresSafeArea()
            VStack {
                HStack {
                    TextField(text: $enteredName, prompt: Text("Enter Album Name")) {
                        Text("Enter Album Name")
                            .foregroundColor(Color.orange)
                            .background(Color.white)
                    }
                    .padding(.horizontal, 50)
                    .textFieldStyle(.roundedBorder)
                    .background(Color.orange)

                    Button("Done") {
                        album.name = enteredName
                        albumList.addAlbum(named: album.name, selectedImages: album.selectedImages)
                    }
                    .frame(height: 5)
                    .padding(.all, 10)
                    .background(Color.white)
                    .foregroundColor(Color.orange)
                    .cornerRadius(10)

                    Spacer().frame(width: 30)
                }

                Spacer().padding(.top)

                PhotosPicker("Select a picture", selection: $pickerItems, matching: .images)
                    .foregroundColor(.orange)
                    .bold()
                    .frame(height: 5)
                    .padding(.all, 15)
                    .background(Color.white)
                    .foregroundColor(Color.orange)
                    .cornerRadius(10)

                Spacer()

                ScrollView {
                    ForEach(0..<album.selectedImages.count, id: \.self) { i in
                        album.selectedImages[i]
                            .resizable()
                            .scaledToFit()
                            .rotationEffect(.degrees(90))
                    }
                }
            }
            .onChange(of: pickerItems) { newPickerItems in
                Task {
                    for item in newPickerItems {
                        if let loadedImage = try await item.loadTransferable(type: Image.self) {
                            album.selectedImages.append(loadedImage)
                        }
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
    }
}
