//
//  ShopView.swift
//  Final Project 2
//
//  Created by 陳宣燁 on 2025/12/19.
//

import SwiftUI

struct ShopView: View {
    @ObservedObject var state: GameState

    var body: some View {
        NavigationStack {
            List {
                Section("資源：兵馬（Troops）") {
                    ShopRow(
                        title: "徵召鄉勇（+100 兵）",
                        price: 50,
                        canBuy: state.ip >= 50
                    ) {
                        if state.spendIP(50) {
                            state.addTroops(100)
                        }
                    }
                    ShopRow(
                        title: "精銳步兵（+1000 兵）",
                        price: 450,
                        canBuy: state.ip >= 450
                    ) {
                        if state.spendIP(450) {
                            state.addTroops(1000)
                        }
                    }
                }

                Section("資源：糧草（Rations）") {
                    ShopRow(
                        title: "小型糧倉（+100 糧）",
                        price: 100,
                        canBuy: state.ip >= 100
                    ) {
                        if state.spendIP(100) {
                            state.addRations(100)
                        }
                    }
                    ShopRow(
                        title: "大型糧倉（+300 糧）",
                        price: 300,
                        canBuy: state.ip >= 300
                    ) {
                        if state.spendIP(300) {
                            state.addRations(300)
                        }
                    }
                }

                Section("資產概況") {
                    HStack { Text("IP"); Spacer(); Text("\(state.ip)") }
                    HStack { Text("兵馬"); Spacer(); Text("\(state.troops)") }
                    HStack { Text("糧草"); Spacer(); Text("\(state.rations)") }
                }
            }
            .navigationTitle("招兵買馬")
        }
    }
}

private struct ShopRow: View {
    let title: String
    let price: Int
    let canBuy: Bool
    let action: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                Text("價格：\(price) IP").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Button("購買") {
                action()
            }
            .buttonStyle(.borderedProminent)
            .disabled(!canBuy)
        }
    }
}
