//
//  StockViewModel.swift
//  RiyalVest
//
//  Created by Sumayah Alqahtani on 08/09/1446 AH.
//

//import Foundation
//import Combine
//
//class StockViewModel: ObservableObject {
//    @Published var stocks: [Stock] = []
//    private var cancellables = Set<AnyCancellable>()
//    private var timer: Timer?
//    
//    let apiKey = "ecf6db49df374c2b97930d9569bae2ae"
//    let symbols = ["AAPL", "MSFT", "GOOGL", "TSLA", "META"]
//    
//    private var stockData: [String: StockResponse] = [:]
//    
//    init() {
//        startTimer()
//    }
//    
//    func startTimer() {
//        timer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
//            Task {
//                await self.fetchStocks()
//            }
//        }
//    }
//    
//    func fetchStocks() async {
//        for symbol in symbols {
//            let urlString = "https://api.twelvedata.com/time_series?symbol=\(symbol)&interval=5min&apikey=\(apiKey)&country=United States"
//            
//            guard let url = URL(string: urlString) else { return }
//            
//            do {
//                let (data, _) = try await URLSession.shared.data(from: url)
//                let response = try JSONDecoder().decode(StockResponse.self, from: data)
//                
//                if response.status == "ok", let stock = response.toStock(name: await fetchStockName(for: symbol)) {
//                    DispatchQueue.main.async {
//                        if let index = self.stocks.firstIndex(where: { $0.symbol == stock.symbol }) {
//                            self.stocks[index] = stock
//                        } else {
//                            self.stocks.append(stock)
//                        }
//                    }
//                } else {
//                    print("Failed to fetch data for symbol: \(symbol)")
//                }
//            } catch {
//                print("Error fetching data: \(error)")
//            }
//        }
//    }
//    
//    func fetchStockName(for symbol: String) async -> String {
//        let urlString = "https://api.twelvedata.com/stocks?symbol=\(symbol)&apikey=\(apiKey)&country=United States"
//        
//        guard let url = URL(string: urlString) else { return "" }
//        
//        do {
//            let (data, _) = try await URLSession.shared.data(from: url)
//            let stockResponse = try JSONDecoder().decode(StockNameResponse.self, from: data)
//            return stockResponse.data.first?.name ?? ""
//        } catch {
//            print("Error fetching stock name: \(error)")
//            return ""
//        }
//    }
//}
//
//struct StockResponse: Codable {
//    let status: String?
//    let meta: Meta?
//    let values: [Value]?
//    
//    func toStock(name: String) -> Stock? {
//        guard let meta = meta, let values = values, let latestValue = values.first else {
//            return nil
//        }
//        let previousValue = values.count > 1 ? values[1] : latestValue
//        
//        // تقريب السعر إلى خانتين بعد الفاصلة
//        let closePrice = Double(latestValue.close) ?? 0
//        let roundedPrice = String(format: "%.2f", closePrice)
//        
//        let change = (Double(latestValue.close) ?? 0) - (Double(previousValue.close) ?? 0)
//        let changePercent = (change / (Double(previousValue.close) ?? 1)) * 100
//        
//        return Stock(
//            symbol: meta.symbol,
//            price: roundedPrice, // استخدام السعر المقرب
//            change: String(format: "%.2f", change),
//            changePercent: String(format: "%.2f%%", changePercent),
//            name: name
//        )
//    }
//}
//
//struct StockNameResponse: Codable {
//    let status: String
//    let data: [StockData]
//}
//
//struct StockData: Codable {
//    let symbol: String
//    let name: String
//}
//
//struct Meta: Codable {
//    let symbol: String
//}
//
//struct Value: Codable {
//    let datetime: String
//    let open: String
//    let high: String
//    let low: String
//    let close: String
//    let volume: String
//}
//
//struct Stock: Identifiable {
//    let id = UUID()
//    let symbol: String
//    let price: String
//    let change: String
//    let changePercent: String
//    let name: String // إضافة حقل اسم السهم
//}
import Foundation
import Combine

class StockViewModel: ObservableObject {
    @Published var stocks: [Stock] = []
    @Published var lastFetchedStocks: [Stock] = [] // آخر بيانات تم جلبها بنجاح
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    
    let apiKey = "ecf6db49df374c2b97930d9569bae2ae"
    let symbols = ["AAPL", "MSFT", "GOOGL", "TSLA", "META"]
    
    init() {
        startTimer()
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in // 5 دقائق
            Task {
                await self.fetchStocks()
            }
        }
    }
    
    func fetchStocks() async {
        for symbol in symbols {
            let urlString = "https://api.twelvedata.com/time_series?symbol=\(symbol)&interval=5min&apikey=\(apiKey)&country=United States"
            guard let url = URL(string: urlString) else { return }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let response = try JSONDecoder().decode(StockResponse.self, from: data)
                
                if response.status == "ok", let stock = response.toStock(name: await fetchStockName(for: symbol)) {
                    DispatchQueue.main.async {
                        if let index = self.stocks.firstIndex(where: { $0.symbol == stock.symbol }) {
                            self.stocks[index] = stock
                        } else {
                            self.stocks.append(stock)
                        }
                        // تحديث آخر بيانات تم جلبها بنجاح
                        self.lastFetchedStocks = self.stocks
                    }
                    // طباعة رسالة نجاح جلب البيانات الحية
                    print("Successfully fetched live data for \(symbol).")
                } else if response.status == "error" && response.code == 429 {
                    // إذا وصلنا إلى الحد اليومي، نعرض آخر بيانات تم جلبها بنجاح
                    DispatchQueue.main.async {
                        self.stocks = self.lastFetchedStocks
                        print("Rate limit exceeded. Displaying last fetched data.")
                    }
                    
                    // انتظر لمدة دقيقة (60 ثانية) ثم أعد المحاولة
                    try await Task.sleep(nanoseconds: 60 * 1_000_000_000) // انتظر 60 ثانية
                    print("Retrying to fetch live data after waiting for 60 seconds...")
                    await fetchStocks() // إعادة المحاولة
                }
            } catch {
                print("Error fetching data: \(error)")
            }
        }
    }
    
    func fetchStockName(for symbol: String) async -> String {
        let urlString = "https://api.twelvedata.com/stocks?symbol=\(symbol)&apikey=\(apiKey)&country=United States"
        guard let url = URL(string: urlString) else { return "" }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let stockResponse = try JSONDecoder().decode(StockNameResponse.self, from: data)
            return stockResponse.data.first?.name ?? ""
        } catch {
            print("Error fetching stock name: \(error)")
            return ""
        }
    }
}

struct StockResponse: Codable {
    let code: Int? // كود الخطأ
    let message: String? // رسالة الخطأ
    let status: String? // حالة الطلب (مثلاً "ok" أو "error")
    let meta: Meta?
    let values: [Value]?
    
    func toStock(name: String) -> Stock? {
        guard status == "ok", let meta = meta, let values = values, let latestValue = values.first else {
            return nil
        }
        let previousValue = values.count > 1 ? values[1] : latestValue
        
        let closePrice = Double(latestValue.close) ?? 0
        let roundedPrice = String(format: "%.2f", closePrice)
        
        let change = (Double(latestValue.close) ?? 0) - (Double(previousValue.close) ?? 0)
        let changePercent = (change / (Double(previousValue.close) ?? 1)) * 100
        
        return Stock(
            symbol: meta.symbol,
            price: roundedPrice,
            change: String(format: "%.2f", change),
            changePercent: String(format: "%.2f%%", changePercent),
            name: name
        )
    }
}

struct StockNameResponse: Codable {
    let status: String
    let data: [StockData]
}

struct StockData: Codable {
    let symbol: String
    let name: String
}

struct Meta: Codable {
    let symbol: String
}

struct Value: Codable {
    let datetime: String
    let open: String
    let high: String
    let low: String
    let close: String
    let volume: String
}

struct Stock: Identifiable {
    let id = UUID()
    let symbol: String
    let price: String
    let change: String
    let changePercent: String
    let name: String
}
