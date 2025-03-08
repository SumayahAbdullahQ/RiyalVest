//
//  ProfileView.swift
//  RiyalVest
//
//  Created by Sumayah Alqahtani on 08/09/1446 AH.
//

import SwiftUI

struct ProfileView: View {
    var userName: String
    @State private var initialBalance: Double = 500000 // Initial balance
    @State private var currentBalance: Double = UserDefaults.standard.double(forKey: "balance") // Current balance
    
    // Load owned stocks from UserDefaults
    @State private var ownedStocks: [String: Int] = UserDefaults.standard.dictionary(forKey: "ownedStocks") as? [String: Int] ?? [:]
    
    // Load sold stocks from UserDefaults
    @State private var soldStocks: [String: Int] = UserDefaults.standard.dictionary(forKey: "soldStocks") as? [String: Int] ?? [:]
    
    // Calculate profit
    var profit: Double {
        return max(currentBalance - initialBalance, 0) // Profit is never negative
    }
    
    // Calculate loss
    var loss: Double {
        return max(initialBalance - currentBalance, 0) // Loss is never negative
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("\(userName)'s Profile")
                    .font(.largeTitle)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Wallet Card
                VStack(alignment: .leading, spacing: 15) {
                    Text("Your Wallet")
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Text("Current Balance:")
                        Spacer()
                        Text("$\(String(format: "%.2f", currentBalance))")
                            .bold()
                    }
                    
                    if profit > 0 {
                        HStack {
                            Text("Profit:")
                            Spacer()
                            Text("+$\(String(format: "%.2f", profit))")
                                .bold()
                                .foregroundColor(.green)
                        }
                    }
                    
                    if loss > 0 {
                        HStack {
                            Text("Loss:")
                            Spacer()
                            Text("-$\(String(format: "%.2f", loss))")
                                .bold()
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
                .padding(.horizontal)
                
                // Owned Stocks Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Owned Stocks")
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    if ownedStocks.isEmpty {
                        Text("You don't own any stocks yet.")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                    } else {
                        ForEach(Array(ownedStocks.keys), id: \.self) { symbol in
                            StockRow(symbol: symbol, shares: ownedStocks[symbol] ?? 0, isSold: false)
                        }
                    }
                }
                .padding(.vertical)
                
                // Sold Stocks Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Sold Stocks")
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    if soldStocks.isEmpty {
                        Text("You haven't sold any stocks yet.")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                    } else {
                        ForEach(Array(soldStocks.keys), id: \.self) { symbol in
                            StockRow(symbol: symbol, shares: soldStocks[symbol] ?? 0, isSold: true)
                        }
                    }
                }
                .padding(.vertical)
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            // Update current balance and stocks when the view appears
            currentBalance = UserDefaults.standard.double(forKey: "balance")
            ownedStocks = UserDefaults.standard.dictionary(forKey: "ownedStocks") as? [String: Int] ?? [:]
            soldStocks = UserDefaults.standard.dictionary(forKey: "soldStocks") as? [String: Int] ?? [:]
        }
    }
}

// Custom View for Stock Row
struct StockRow: View {
    var symbol: String
    var shares: Int
    var isSold: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(symbol)
                    .font(.headline)
                Text("\(shares) shares")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if isSold {
                Text("Sold")
                    .font(.subheadline)
                    .foregroundColor(.red)
            } else {
                Text("Owned")
                    .font(.subheadline)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}
#Preview {
    ProfileView(userName: "John Doe")
}
