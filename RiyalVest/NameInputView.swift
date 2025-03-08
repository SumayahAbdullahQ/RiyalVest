//
//  NameInputView.swift
//  RiyalVest
//
//  Created by Sumayah Alqahtani on 08/09/1446 AH.
//

import SwiftUI

struct NameInputView: View {
    @State private var userName = ""
    @State private var navigateToContentView = false
    @State private var balance: Double = 500000
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Enter your name")
                    .font(.title)
                    .padding()
                
                TextField("Enter your name", text: $userName)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .autocapitalization(.words)
                
                NavigationLink(
                    destination: ContentView(userName: userName, balance: $balance),
                    isActive: $navigateToContentView
                ) {
                    Button("Enter") {
                        if !userName.trimmingCharacters(in: .whitespaces).isEmpty {
                            // حفظ البيانات في UserDefaults
                            UserDefaults.standard.set(userName, forKey: "userName")
                            UserDefaults.standard.set(balance, forKey: "balance")
                            navigateToContentView = true
                        }
                    }
                    .padding()
                    .background(userName.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(userName.isEmpty)
            }
        }
        .onAppear {
            // تحميل البيانات المحفوظة عند فتح التطبيق
            if let savedUserName = UserDefaults.standard.string(forKey: "userName") {
                userName = savedUserName
                balance = UserDefaults.standard.double(forKey: "balance")
                navigateToContentView = true
            }
        }
    }
}
#Preview {
    NameInputView()
}
