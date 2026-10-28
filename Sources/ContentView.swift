//
//  ContentView.swift
//  LOS PLUS
//
//  Official Native iOS Client
//  Copyright © 2026 LOS PLUS LLC. All rights reserved.
//

import SwiftUI

struct AppItem: Identifiable, Codable {
    let id: String
    let name: String
    let arabicName: String?
    let bundleId: String?
    let version: String?
    let size: String?
    let iconUrl: String?
    let downloadUrl: String?
    let description: String?
}

struct AppsResponse: Codable {
    let success: Bool
    let total: Int?
    let apps: [AppItem]?
}

struct ContentView: View {
    @State private var apps: [AppItem] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    @State private var activeTab = 0
    @State private var deviceUdid: String = "جهاز آيفون موثق"
    @State private var vipStatus: String = "اشتراك VIP نشط (1/1)"

    // Portal dynamic base URL injected at build time
    private let portalBaseUrl = "https://ais-dev-5vuicf7wclj4zdm4tmrlfs-79727261116.europe-west1.run.app"

    // LOS PLUS Brand Theme Colors
    private let bgDark = Color(red: 0.02, green: 0.02, blue: 0.03) // #050507
    private let cardDark = Color(red: 0.07, green: 0.07, blue: 0.10)
    private let brandPink = Color(red: 1.00, green: 0.16, blue: 0.72) // #FF28B8
    private let brandPurple = Color(red: 0.55, green: 0.26, blue: 1.00) // #8B42FF

    var body: some View {
        ZStack {
            bgDark.ignoresSafeArea()

            // Subtle neon ambient glow
            Circle()
                .fill(brandPink.opacity(0.12))
                .blur(radius: 80)
                .frame(width: 280, height: 280)
                .offset(x: -90, y: -220)

            Circle()
                .fill(brandPurple.opacity(0.12))
                .blur(radius: 80)
                .frame(width: 280, height: 280)
                .offset(x: 90, y: 220)

            VStack(spacing: 0) {
                // Top Header Bar
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [brandPink, brandPurple], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 42, height: 42)
                        Text("LP")
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("LOS PLUS")
                            .font(.system(size: 19, weight: .black))
                            .foregroundColor(.white)
                        Text("المتجر الرسمي لتطبيقات البلس وشهادات VIP")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    Text("VIP")
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(brandPink.opacity(0.2))
                        .foregroundColor(brandPink)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 12)
                .background(Color.black.opacity(0.4))

                // Subscription Banner
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(brandPink)
                    Text(vipStatus)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Text("iOS 18+ جاهز")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.green)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(cardDark)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

                // Apps List
                if isLoading {
                    Spacer()
                    ProgressView()
                        .tint(brandPink)
                    Text("جاري مزامنة التطبيقات من السيرفر...")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                    Spacer()
                } else if let error = errorMessage {
                    Spacer()
                    Text(error)
                        .font(.system(size: 13))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                    Button("إعادة المحاولة") {
                        loadApps()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(brandPink)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(apps) { app in
                                appRow(app)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 30)
                    }
                    .refreshable {
                        loadApps()
                    }
                }
            }
        }
        .onAppear {
            loadApps()
        }
    }

    @ViewBuilder
    private func appRow(_ app: AppItem) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.6))
                    .frame(width: 58, height: 58)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(brandPurple.opacity(0.4), lineWidth: 1)
                    )
                Image(systemName: "app.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .foregroundColor(brandPink)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(app.arabicName ?? app.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)

                Text(app.description ?? "تطبيق بلس موثق بشهادة رسمية")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text("v\(app.version ?? "1.0")")
                        .font(.system(size: 10, weight: .mono))
                        .foregroundColor(.gray)
                    Text("•")
                        .foregroundColor(.gray)
                    Text(app.size ?? "50 MB")
                        .font(.system(size: 10, weight: .mono))
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            Button(action: {
                installApp(app)
            }) {
                Text("تثبيت")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(colors: [brandPink, brandPurple], startPoint: .leading, endPoint: .trailing)
                    )
                    .clipShape(Capsule())
                    .shadow(color: brandPink.opacity(0.4), radius: 6, x: 0, y: 2)
            }
        }
        .padding(12)
        .background(cardDark)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func loadApps() {
        isLoading = true
        errorMessage = nil

        guard let url = URL(string: "\(portalBaseUrl)/api/apps") else {
            errorMessage = "رابط السيرفر غير صالح"
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, err in
            DispatchQueue.main.async {
                self.isLoading = false
                if let data = data {
                    do {
                        let res = try JSONDecoder().decode(AppsResponse.self, from: data)
                        self.apps = res.apps ?? []
                    } catch {
                        self.errorMessage = "تعذر قراءة بيانات التطبيقات"
                    }
                } else {
                    self.errorMessage = "تعذر الاتصال بسيرفر المتجر"
                }
            }
        }.resume()
    }

    private func installApp(_ app: AppItem) {
        let manifestUrl = "\(portalBaseUrl)/api/ota/manifest.plist?appId=\(app.id)"
        if let itmsUrl = URL(string: "itms-services://?action=download-manifest&url=\(manifestUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
            UIApplication.shared.open(itmsUrl)
        }
    }
}
