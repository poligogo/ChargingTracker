import SwiftUI
import PhotosUI

struct VehicleSelectionView: View {
    @State private var carName: String = ""
    @Binding var selectedCarName: String
    @State private var availableCars: [(name: String, image: UIImage?)] = []
    @Binding var isVehicleSelected: Bool

    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showNameInputAlert = false
    @State private var showActionSheet = false
    @State private var showDeleteConfirmation = false
    @State private var carToDelete: String?
    @State private var showNoCarAlert = false

    @State private var draggingItem: (name: String, image: UIImage?)? = nil
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        ZStack {
            Color(hexString: "#E0F7FA").edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                if !availableCars.isEmpty {
                    Image("cat_image")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .padding(.top, -15)
                        .zIndex(1) // 將貓咪圖像置於頂層
                }
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))], spacing: 20) {
                        ForEach(availableCars.indices, id: \.self) { index in
                            let car = availableCars[index]
                            ZStack(alignment: .top) {
                                VStack {
                                    if let image = car.image {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 250, height: 250)
                                            .cornerRadius(8)
                                    } else {
                                        Image("default_car_image")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 180, height: 180)
                                            .cornerRadius(8)
                                    }
                                    HStack {
                                        Spacer()
                                        Text(car.name)
                                            .font(.headline)
                                            .foregroundColor(Color(hexString: "#37474F"))
                                        Button(action: {
                                            selectedCarName = car.name
                                            carName = car.name
                                            showActionSheet = true
                                        }) {
                                            Image(systemName: "pencil.circle.fill")
                                                .foregroundColor(.blue)
                                                .font(.system(size: 20))
                                        }
                                        Spacer()
                                    }
                                    .padding(.top, 8)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: Color(hexString: "#B0BEC5").opacity(0.2), radius: 10, x: 0, y: 5)
                                .offset(draggingItem?.name == car.name ? dragOffset : .zero)
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            if draggingItem == nil {
                                                draggingItem = car
                                            }
                                            dragOffset = value.translation
                                        }
                                        .onEnded { value in
                                            if let draggingItem = draggingItem {
                                                withAnimation {
                                                    moveItem(draggingItem, to: value.location)
                                                }
                                            }
                                            draggingItem = nil
                                            dragOffset = .zero
                                        }
                                )
                            }
                            .actionSheet(isPresented: $showActionSheet) {
                                ActionSheet(
                                    title: Text("操作"),
                                    message: Text("請選擇操作"),
                                    buttons: [
                                        .default(Text("修改照片")) {
                                            selectedCarName = car.name
                                            showImagePicker = true
                                        },
                                        .destructive(Text("刪除此輛汽車資料")) {
                                            showDeleteConfirmation = true
                                            carToDelete = car.name
                                        },
                                        .cancel()
                                    ]
                                )
                            }
                            .alert(isPresented: $showDeleteConfirmation) {
                                Alert(
                                    title: Text("確定刪除"),
                                    message: Text("刪除後無法復原，確定要刪除嗎？"),
                                    primaryButton: .destructive(Text("刪除")) {
                                        if let carToDelete = carToDelete {
                                            availableCars.removeAll { $0.name == carToDelete }
                                            saveCars()
                                        }
                                    },
                                    secondaryButton: .cancel()
                                )
                            }
                            .onTapGesture {
                                selectedCarName = car.name
                                isVehicleSelected = true
                                UserDefaults.standard.set(selectedCarName, forKey: "selectedCarName")
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selectedCarName == car.name ? Color.blue : Color.clear, lineWidth: 3)
                            )
                        }
                    }
                    .padding()
                }
                .padding(.top, -40)
            }
        }
        .navigationBarItems(trailing: Button(action: {
            carName = ""
            showNameInputAlert = true
        }) {
            Image(systemName: "plus")
                .font(.title)
                .foregroundColor(Color(hexString: "#4DB6AC"))
        })
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage, onImageSelected: {
                updateCarImage()
            })
        }
        .textFieldAlert(isPresented: $showNameInputAlert, text: $carName, title: "輸入車輛名稱", placeholder: "車輛名稱") {
            if !carName.isEmpty {
                addNewCar()
            }
        }
        .onAppear {
            loadCars()
        }
    }

    private func addNewCar() {
        availableCars.append((name: carName, image: UIImage(named: "default_car_image")))
        saveCars()
        UserDefaults.standard.set(carName, forKey: "selectedCarName")
    }

    private func updateCarImage() {
        if let index = availableCars.firstIndex(where: { $0.name == selectedCarName }) {
            availableCars[index].image = selectedImage
            saveCars()
        }
    }

    private func saveCars() {
        let carNames = availableCars.map { $0.name }
        UserDefaults.standard.set(carNames, forKey: "carNames")
        for car in availableCars {
            if let image = car.image, let imageData = image.pngData() {
                UserDefaults.standard.set(imageData, forKey: "carImage_\(car.name)")
            }
        }
    }

    private func loadCars() {
        let carNames = UserDefaults.standard.stringArray(forKey: "carNames") ?? []
        availableCars = carNames.map { name in
            let imageData = UserDefaults.standard.data(forKey: "carImage_\(name)")
            let image = imageData != nil ? UIImage(data: imageData!) : UIImage(named: "default_car_image")
            return (name: name, image: image)
        }
    }

    private func moveItem(_ item: (name: String, image: UIImage?), to location: CGPoint) {
        guard let fromIndex = availableCars.firstIndex(where: { $0.name == item.name }) else {
            return
        }
        let toIndex = calculateDestinationIndex(location: location)

        if fromIndex != toIndex {
            withAnimation {
                availableCars.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex)
                saveCars()
            }
        }
    }

    private func calculateDestinationIndex(location: CGPoint) -> Int {
        let distances = availableCars.map { car -> CGFloat in
            let carIndex = availableCars.firstIndex(where: { $0.name == car.name })!
            let carPosition = CGPoint(x: 200 * (carIndex % 2), y: 220 * (carIndex / 2))
            return abs(location.x - carPosition.x) + abs(location.y - carPosition.y)
        }
        return distances.enumerated().min(by: { $0.element < $1.element })?.offset ?? 0
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var onImageSelected: () -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider else { return }
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { (image, error) in
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image as? UIImage
                        self.parent.onImageSelected()
                    }
                }
            }
        }
    }
}

struct TextFieldAlert<Presenting>: View where Presenting: View {
    @Binding var isPresented: Bool
    @Binding var text: String
    let presenting: Presenting
    let title: String
    let placeholder: String
    let action: () -> Void

    var body: some View {
        ZStack(alignment: .center) {
            presenting
                .blur(radius: isPresented ? 2 : 0)

            if isPresented {
                VStack {
                    Text(title)
                        .font(.headline)
                    TextField(placeholder, text: $text)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    HStack {
                        Button("取消") {
                            withAnimation {
                                isPresented = false
                            }
                        }
                        Spacer()
                        Button("確定") {
                            withAnimation {
                                isPresented = false
                                action()
                            }
                        }
                    }
                    .padding()
                }
                .frame(width: 300)
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 20)
            }
        }
    }
}

extension View {
    func textFieldAlert(isPresented: Binding<Bool>, text: Binding<String>, title: String, placeholder: String, action: @escaping () -> Void) -> some View {
        TextFieldAlert(isPresented: isPresented, text: text, presenting: self, title: title, placeholder: placeholder, action: action)
    }
}

extension Color {
    init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

