//
//  TradeView.swift
//  RiyalVest
//
//  Created by Sumayah Alqahtani on 08/09/1446 AH.
//

import SwiftUI

struct TradeView: View {
    var stock: Stock
    @State private var quantity: Int = 0
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var balance: Double
    @State private var ownedStocks: [String: Int] = UserDefaults.standard.dictionary(forKey: "ownedStocks") as? [String: Int] ?? [:]
    @State private var soldStocks: [String: Int] = UserDefaults.standard.dictionary(forKey: "soldStocks") as? [String: Int] ?? [:]
    
    var body: some View {
        VStack(spacing: 20) {
            Text(stock.name)
                .font(.title)
                .padding()
            
            Text("Current Price: \(stock.price)")
                .font(.headline)
            
            HStack(spacing: 20) {
                Button(action: {
                    if quantity > 0 {
                        quantity -= 1
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                }
                
                Text("\(quantity)")
                    .font(.title)
                    .frame(width: 50, alignment: .center)
                
                Button(action: {
                    quantity += 1
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.green)
                }
            }
            .padding()
            
            Text("Owned: \(ownedStocks[stock.symbol, default: 0]) shares")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack(spacing: 20) {
                Button("Buy") {
                    if quantity > 0 {
                        let totalCost = Double(quantity) * (Double(stock.price) ?? 0)
                        if balance >= totalCost {
                            balance -= totalCost
                            ownedStocks[stock.symbol, default: 0] += quantity
                            alertMessage = "You bought \(quantity) shares of \(stock.symbol) at \(stock.price) each. Total cost: $\(String(format: "%.2f", totalCost))."
                            
                            // حفظ البيانات المحدثة
                            UserDefaults.standard.set(balance, forKey: "balance")
                            UserDefaults.standard.set(ownedStocks, forKey: "ownedStocks")
                        } else {
                            alertMessage = "Insufficient balance to buy \(quantity) shares of \(stock.symbol)."
                        }
                    } else {
                        alertMessage = "Please select a valid quantity."
                    }
                    showAlert = true
                }
                .frame(width: 120, height: 50)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Button("Sell") {
                    if quantity > 0 {
                        let ownedQuantity = ownedStocks[stock.symbol, default: 0]
                        if ownedQuantity >= quantity {
                            let totalEarnings = Double(quantity) * (Double(stock.price) ?? 0)
                            balance += totalEarnings
                            ownedStocks[stock.symbol] = ownedQuantity - quantity
                            
                            // تحديث الأسهم المباعة
                            soldStocks[stock.symbol, default: 0] += quantity
                            
                            // إذا تم بيع كل الأسهم، قم بإزالة السهم من ownedStocks
                            if ownedStocks[stock.symbol] == 0 {
                                ownedStocks.removeValue(forKey: stock.symbol)
                            }
                            
                            alertMessage = "You sold \(quantity) shares of \(stock.symbol) at \(stock.price) each. Total earnings: $\(String(format: "%.2f", totalEarnings))."
                            
                            // حفظ البيانات المحدثة
                            UserDefaults.standard.set(balance, forKey: "balance")
                            UserDefaults.standard.set(ownedStocks, forKey: "ownedStocks")
                            UserDefaults.standard.set(soldStocks, forKey: "soldStocks")
                        } else {
                            alertMessage = "You don't have enough shares of \(stock.symbol) to sell."
                        }
                    } else {
                        alertMessage = "Please select a valid quantity."
                    }
                    showAlert = true
                }
                .frame(width: 120, height: 50)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Trade \(stock.symbol)")
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Trade Result"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if alertMessage.contains("successfully") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
    }
}
#Preview {
    TradeView(stock: Stock(symbol: "AAPL", price: "150.00", change: "+2.00", changePercent: "+1.35%", name: "Apple Inc."), balance: .constant(500000))
}
