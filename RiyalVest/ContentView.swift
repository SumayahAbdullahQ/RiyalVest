//
//  ContentView.swift
//  RiyalVest
//
//  Created by Sumayah Alqahtani on 06/09/1446 AH.
//


import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = StockViewModel()
    var userName: String
    @Binding var balance: Double // تغيير balance إلى @Binding

    var body: some View {
        NavigationStack {
            VStack {
                List(viewModel.stocks) { stock in
                    NavigationLink(destination: TradeView(stock: stock, balance: $balance)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(stock.symbol)
                                    .font(.headline)
                                Text(stock.name)
                                    .font(.subheadline)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .leading) {
                                Text(stock.price)
                                Text("\(stock.change) (\(stock.changePercent))")
                                    .foregroundColor(stock.change.contains("-") ? .red : .green)
                            }
                        }
                        .padding()
                    }
                }
                .onAppear {
                    Task {
                        await viewModel.fetchStocks()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        // صورة البروفايل
                        NavigationLink(destination: ProfileView(userName: userName)) {
                            Image(systemName: "person.circle.fill")                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.blue)
                        }
                        
                        // نص الترحيب
                        Text("Hi \(userName)")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("Balance: $\(String(format: "%.2f", balance))")
                        .font(.headline)
                        .foregroundColor(.green)
                }
            }
            .navigationTitle("Stocks")
            .navigationBarBackButtonHidden(true)
        }
    }
}
//#Preview {
//    ContentView(userName: "John Doe", balance: .constant(500000))
//}
