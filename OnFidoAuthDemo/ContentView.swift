import SwiftUI
import Onfido
import AVFoundation

struct ContentView: View {
    @State private var isShowingOnfido = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var verificationCompleted = false
    @State private var showWealthManagement = false
    
    var body: some View {
        ZStack {
            if showWealthManagement {
                WealthManagementView()
            } else if verificationCompleted {
                VerificationSuccessView(showWealthManagement: $showWealthManagement)
            } else {
                // Background gradient
                LinearGradient(gradient: Gradient(colors: [Color(hex: "#e3ab9a"), Color(hex: "#e3ab9a").opacity(0.8)]),
                              startPoint: .topLeading,
                              endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                VStack(spacing: 25) {
                    // App Header
                    VStack(spacing: 15) {
                        Text("PBRelationship App")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                        Text("ID&V")
                            .font(.system(size: 24, weight: .medium, design: .rounded))
                            .foregroundColor(.black)
                    }
                    .padding(.top, 40)
                    
                    // Icon Stack
                    HStack(spacing: 25) {
                        FeatureIcon(systemName: "person.text.rectangle.fill", text: "ID Doc")
                        FeatureIcon(systemName: "faceid", text: "Selfie")
                        FeatureIcon(systemName: "checkmark.shield.fill", text: "Verify")
                    }
                    .padding(.vertical, 30)
                    
                    // Main verification section
                    VStack(spacing: 30) {
                        Image(systemName: "person.badge.shield.checkmark.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .foregroundStyle(.black, .black.opacity(0.3))
                        
                        Text("Identity Verification")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        Text("Verify your identity securely with our automated verification process")
                            .font(.body)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: {
                            checkCameraPermissionAndStartFlow()
                        }) {
                            HStack {
                                Text("Start Verification")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                Image(systemName: "arrow.right.circle.fill")
                                    .foregroundColor(.white)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(gradient: Gradient(colors: [Color.black, Color.black.opacity(0.8)]),
                                                     startPoint: .leading,
                                                     endPoint: .trailing)
                                    )
                            )
                            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3)
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                    .padding()
                    
                    Spacer()
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if alertTitle == "Success" {
                        verificationCompleted = true
                    }
                }
            )
        }
    }
    
    // Feature Icon View
    private struct FeatureIcon: View {
        let systemName: String
        let text: String
        
        var body: some View {
            VStack {
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: systemName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundColor(.black)
                }
                
                Text(text)
                    .font(.footnote)
                    .foregroundColor(.black)
            }
        }
    }
    
    private func checkCameraPermissionAndStartFlow() {
        // Ensure we're on the main thread when checking permissions
        DispatchQueue.main.async {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                self.startOnfidoFlow()
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    DispatchQueue.main.async {
                        if granted {
                            self.startOnfidoFlow()
                        } else {
                            self.showCameraPermissionDeniedAlert()
                        }
                    }
                }
            case .denied, .restricted:
                self.showCameraPermissionDeniedAlert()
            @unknown default:
                self.showCameraPermissionDeniedAlert()
            }
        }
    }
    
    private func showCameraPermissionDeniedAlert() {
        alertTitle = "Camera Access Required"
        alertMessage = "Please enable camera access in Settings to use identity verification."
        showAlert = true
    }
    
    private func startOnfidoFlow() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            alertTitle = "Error"
            alertMessage = "Could not initialize verification flow. Please try again."
            showAlert = true
            return
        }
        
        do {
            let sdkToken = "test-1234"
            
            let config = try OnfidoConfig.builder()
                .withSDKToken(sdkToken)
                .withWelcomeStep()
                .withDocumentStep()
                .withFaceStep(ofVariant: .photo(withConfiguration: nil))
                .build()
            
            let onfidoFlow = OnfidoFlow(withConfiguration: config)
                .with(responseHandler: { response in
                    DispatchQueue.main.async {
                        switch response {
                        case .success(let results):
                            print("Success with results: \(results)")
                            self.alertTitle = "Success"
                            self.alertMessage = "Verification completed successfully!"
                            self.showAlert = true
                        case .error(let error):
                            print("Error occurred: \(error)")
                            self.alertTitle = "Error"
                            self.alertMessage = "An error occurred during verification: \(error.localizedDescription)"
                            self.showAlert = true
                        case .cancel:
                            print("Flow cancelled by user")
                            self.alertTitle = "Cancelled"
                            self.alertMessage = "Verification was cancelled"
                            self.showAlert = true
                        @unknown default:
                            print("Unknown response received")
                            self.alertTitle = "Unexpected Response"
                            self.alertMessage = "Received an unexpected response from the verification process"
                            self.showAlert = true
                        }
                    }
                })
            
            try onfidoFlow.run(from: rootViewController)
            
        } catch let error as OnfidoConfigError {
            print("Configuration Error: \(error)")
            alertTitle = "Configuration Error"
            switch error {
            case .invalidSDKToken:
                alertMessage = "Invalid SDK token. Please check your configuration."
            default:
                alertMessage = "Failed to configure Onfido: \(error.localizedDescription)"
            }
            showAlert = true
        } catch {
            print("General Error: \(error)")
            alertTitle = "Error"
            alertMessage = "An unexpected error occurred: \(error.localizedDescription)"
            showAlert = true
        }
    }
}

struct VerificationSuccessView: View {
    @Binding var showWealthManagement: Bool
    
    var body: some View {
        ZStack {
            Color(hex: "#e3ab9a")
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.black)
                
                Text("Thank You!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                
                Text("Your verification was successful")
                    .font(.title2)
                    .foregroundColor(.black)
                
                Text("You can now access your Wealth Management Account")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .padding(.horizontal)
                
                Button(action: {
                    showWealthManagement = true
                }) {
                    HStack {
                        Text("Continue to Account")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        Image(systemName: "arrow.right")
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        Capsule()
                            .fill(Color.black)
                    )
                    .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3)
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
            }
            .padding()
        }
    }
}

struct WealthManagementView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#e3ab9a")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Welcome Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("J.P. Morgan")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.black)
                            Text("Private Banking & Wealth Management")
                                .font(.system(size: 16))
                                .foregroundColor(.black.opacity(0.8))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // Portfolio Value Card
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Total Portfolio Value")
                                .font(.subheadline)
                                .foregroundColor(.black)
                            
                            HStack(alignment: .bottom) {
                                Text("$2,547,892")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                VStack(alignment: .trailing) {
                                    Text("+$12,450")
                                        .foregroundColor(.green)
                                    Text("Today's Change")
                                        .font(.caption)
                                        .foregroundColor(.black.opacity(0.6))
                                }
                            }
                            
                            Divider()
                                .background(Color.black.opacity(0.2))
                            
                            HStack {
                                ValueChangeItem(title: "1Y Return", value: "+8.2%")
                                Spacer()
                                ValueChangeItem(title: "YTD", value: "+4.5%")
                                Spacer()
                                ValueChangeItem(title: "Since Inception", value: "+12.4%")
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.1), radius: 10)
                        .padding(.horizontal)
                        
                        // Quick Actions
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                JPMorganActionButton(title: "Transfer", systemImage: "arrow.left.arrow.right")
                                JPMorganActionButton(title: "Invest", systemImage: "chart.line.uptrend.xyaxis")
                                JPMorganActionButton(title: "Trade", systemImage: "dollarsign.circle")
                                JPMorganActionButton(title: "Pay Bills", systemImage: "doc.text")
                                JPMorganActionButton(title: "Statements", systemImage: "doc.plaintext")
                            }
                            .padding(.horizontal)
                        }
                        
                        // Asset Allocation
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Asset Allocation")
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            ForEach(["Equities", "Fixed Income", "Alternative Investments", "Cash & Cash Equivalents"], id: \.self) { asset in
                                AssetRow(
                                    name: asset,
                                    percentage: asset == "Equities" ? 45 :
                                              asset == "Fixed Income" ? 30 :
                                              asset == "Alternative Investments" ? 15 : 10,
                                    value: asset == "Equities" ? "$1,146,551" :
                                          asset == "Fixed Income" ? "$764,367" :
                                          asset == "Alternative Investments" ? "$382,183" : "$254,789"
                                )
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.1), radius: 10)
                        .padding(.horizontal)
                        
                        // Recent Activity
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Recent Activity")
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            ForEach([
                                ("Dividend Payment - AAPL", "+$2,450", "Mar 15"),
                                ("Bond Interest - US Treasury", "+$5,230", "Mar 12"),
                                ("Securities Purchase", "-$50,000", "Mar 10"),
                                ("Advisory Fee", "-$2,500", "Mar 1")
                            ], id: \.0) { activity in
                                ActivityRow(
                                    title: activity.0,
                                    amount: activity.1,
                                    date: activity.2
                                )
                                if activity.0 != "Advisory Fee" {
                                    Divider()
                                        .background(Color.black.opacity(0.2))
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.1), radius: 10)
                        .padding(.horizontal)
                    }
                    .padding(.bottom)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image(systemName: "line.3.horizontal")
                        .foregroundColor(.black)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: "bell")
                        .foregroundColor(.black)
                }
            }
        }
    }
}

struct ValueChangeItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .foregroundColor(.green)
                .font(.system(size: 16, weight: .semibold))
            Text(title)
                .font(.caption)
                .foregroundColor(.black.opacity(0.6))
        }
    }
}

struct JPMorganActionButton: View {
    let title: String
    let systemImage: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundColor(.black)
            Text(title)
                .font(.caption)
                .foregroundColor(.black)
        }
        .frame(width: 80, height: 80)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5)
    }
}

struct AssetRow: View {
    let name: String
    let percentage: Int
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(name)
                    .foregroundColor(.black)
                Spacer()
                Text("\(percentage)%")
                    .foregroundColor(.black.opacity(0.8))
            }
            
            HStack {
                Rectangle()
                    .fill(Color.black)
                    .frame(width: CGFloat(percentage) * 2, height: 6)
                    .cornerRadius(3)
                Spacer()
            }
            
            HStack {
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.black.opacity(0.8))
                Spacer()
            }
        }
    }
}

struct ActivityRow: View {
    let title: String
    let amount: String
    let date: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .foregroundColor(.black)
                Text(date)
                    .font(.caption)
                    .foregroundColor(.black.opacity(0.6))
            }
            Spacer()
            Text(amount)
                .foregroundColor(amount.hasPrefix("+") ? .green : .black)
        }
        .padding(.vertical, 4)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
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
            (a, r, g, b) = (1, 1, 1, 0)
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

extension UIColor {
    convenience init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
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
            return nil
        }
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}

