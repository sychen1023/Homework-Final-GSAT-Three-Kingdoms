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

                Section("武將（永久資產）") {
                    ForEach(GeneralCatalog.all) { general in
                        GeneralRow(
                            general: general,
                            owned: state.has(general),
                            canBuy: state.ip >= general.price
                        ) {
                            guard !state.has(general) else { return }
                            if state.spendIP(general.price) {
                                state.own(general)
                            }
                        }
                    }
                }

                Section("資產概況") {
                    HStack { Text("IP"); Spacer(); Text("\(state.ip)") }
                    HStack { Text("兵馬"); Spacer(); Text("\(state.troops)") }
                    HStack { Text("糧草"); Spacer(); Text("\(state.rations)") }
                    HStack(alignment: .top) {
                        Text("武將")
                        Spacer()
                        Text(state.ownedGenerals.map { GeneralCatalog.byID($0)?.displayName ?? $0 }.joined(separator: "、"))
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden) // 讓 List 背景透明
            .background(Color.clear)          // 讓底層背景圖透出
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

private struct GeneralRow: View {
    let general: General
    let owned: Bool
    let canBuy: Bool
    let onBuy: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(general.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(.secondary.opacity(0.2)))

            VStack(alignment: .leading, spacing: 4) {
                Text(general.displayName)
                    .font(.headline)
                Text(general.type == .warrior ? "武力型" : "智力型")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(spacing: 10) {
                    if general.attackBonus > 0 {
                        Text("攻擊 +\(Int(general.attackBonus * 100))%").font(.caption2)
                    }
                    if general.enemyMoraleMultiplier < 1.0 {
                        Text("敵士氣 -\(Int((1 - general.enemyMoraleMultiplier) * 100))%").font(.caption2)
                    }
                    if general.lossReduction > 0 {
                        Text("戰損 -\(Int(general.lossReduction * 100))%").font(.caption2)
                    }
                    if general.defeatLossHalve {
                        Text("敗北損失減半").font(.caption2)
                    }
                }
                .foregroundStyle(.secondary)
            }

            Spacer()

            if owned {
                Text("已擁有")
                    .font(.caption)
                    .foregroundStyle(.green)
            } else {
                VStack(alignment: .trailing) {
                    Text("\(general.price) IP")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Button("購買") { onBuy() }
                        .buttonStyle(.borderedProminent)
                        .disabled(!canBuy)
                }
            }
        }
    }
}
