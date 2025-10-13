//
//  PaywallView.swift
//  OtoTheory
//
//  Phase 1: Pro subscription paywall
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var proManager = ProManager.shared
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Hero Section
                    VStack(spacing: 16) {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 64))
                            .foregroundStyle(.blue.gradient)
                        
                        Text("OtoTheory Pro")
                            .font(.system(size: 36, weight: .bold))
                        
                        Text("すべての機能を解放")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                    
                    // Features
                    VStack(alignment: .leading, spacing: 20) {
                        FeatureRow(
                            icon: "music.note",
                            color: .blue,
                            title: "50種類のプリセット",
                            description: "Free 20種 + Pro限定 30種の多彩なコード進行"
                        )
                        
                        FeatureRow(
                            icon: "square.grid.3x2",
                            color: .purple,
                            title: "セクション編集",
                            description: "Verse/Chorus/Bridgeを自由に構成"
                        )
                        
                        FeatureRow(
                            icon: "waveform",
                            color: .green,
                            title: "MIDI出力",
                            description: "DAWで編集可能なSMFファイルを書き出し"
                        )
                        
                        FeatureRow(
                            icon: "icloud",
                            color: .orange,
                            title: "無制限保存",
                            description: "クラウド同期でデバイス間で共有"
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    Divider()
                        .padding(.horizontal, 24)
                    
                    // Pricing
                    if let product = proManager.products.first {
                        VStack(spacing: 20) {
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text(product.displayPrice)
                                    .font(.system(size: 56, weight: .bold))
                                
                                Text("/ 月")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                            }
                            
                            Button(action: {
                                purchaseSubscription(product)
                            }) {
                                HStack {
                                    if isPurchasing {
                                        ProgressView()
                                            .tint(.white)
                                    }
                                    Text(isPurchasing ? "処理中..." : "購読を開始")
                                        .font(.headline)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .disabled(isPurchasing || proManager.isLoading)
                            
                            Button(action: {
                                restorePurchases()
                            }) {
                                Text("購入履歴を復元")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                            .disabled(isPurchasing || proManager.isLoading)
                        }
                        .padding(.horizontal, 24)
                    } else if proManager.isLoading {
                        ProgressView()
                            .padding()
                    } else {
                        Text("商品情報の読み込みに失敗しました")
                            .foregroundColor(.secondary)
                            .padding()
                        
                        Button("再試行") {
                            Task {
                                await proManager.loadProducts()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    // Terms
                    VStack(spacing: 12) {
                        Text("サブスクリプションは自動更新されます。\nいつでもキャンセル可能です。")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        HStack(spacing: 20) {
                            Link("利用規約", destination: URL(string: "https://ototheory.com/terms")!)
                            Link("プライバシーポリシー", destination: URL(string: "https://ototheory.com/privacy")!)
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
        .alert("エラー", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            // Track paywall view
            TelemetryService.shared.trackPaywallView()
        }
    }
    
    // MARK: - Actions
    
    private func purchaseSubscription(_ product: Product) {
        Task {
            isPurchasing = true
            defer { isPurchasing = false }
            
            do {
                try await proManager.purchase(product)
                
                // Success - dismiss paywall
                dismiss()
            } catch PurchaseError.userCancelled {
                // User cancelled, no error message needed
                return
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    private func restorePurchases() {
        Task {
            isPurchasing = true
            defer { isPurchasing = false }
            
            do {
                try await proManager.restore()
                
                if proManager.isProUser {
                    // Success - dismiss paywall
                    dismiss()
                } else {
                    errorMessage = "復元できる購入履歴が見つかりませんでした"
                    showError = true
                }
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    PaywallView()
}

