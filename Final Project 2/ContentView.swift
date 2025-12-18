//
//  ContentView.swift
//  Final Project 2
//
//  Created by 陳宣燁 on 2025/12/19.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var state = GameState()
    @State private var showQuiz = false
    @State private var showShop = false
    @State private var showBattle = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // 頂部資訊區：IP / 兵馬 / 糧草 + Buff + 關卡名稱
                VStack(spacing: 8) {
                    Text("軍帳")
                        .font(.largeTitle).bold()
                    HStack(spacing: 16) {
                        StatBadge(title: "IP", value: state.ip)
                        StatBadge(title: "兵馬", value: state.troops)
                        StatBadge(title: "糧草", value: state.rations)
                    }
                    if state.hasRampageBuff {
                        Text("勢如破竹：下一場士氣 +10%")
                            .foregroundStyle(.orange)
                            .font(.subheadline)
                    }
                    Text("當前關卡：\(Campaign.all.first?.name ?? "—")")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // 主要操作：研讀兵書 / 招兵買馬 / 出征
                VStack(spacing: 12) {
                    Button {
                        showQuiz = true
                    } label: {
                        PrimaryButtonLabel(title: "研讀兵書（答題）")
                    }

                    Button {
                        showShop = true
                    } label: {
                        PrimaryButtonLabel(title: "招兵買馬（商店）")
                    }

                    Button {
                        showBattle = true
                    } label: {
                        PrimaryButtonLabel(title: "出征（涿郡起義）")
                    }
                }
                .padding(.top, 8)

                Spacer()
                Text("小提醒：先答題拿 IP，再到商店買兵/糧，最後挑戰第一關。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .sheet(isPresented: $showQuiz) {
                QuizView(state: state)
            }
            .sheet(isPresented: $showShop) {
                ShopView(state: state)
            }
            .sheet(isPresented: $showBattle) {
                if let stage = Campaign.all.first {
                    BattleView(state: state, stage: stage)
                }
            }
        }
    }
}

private struct StatBadge: View {
    let title: String
    let value: Int
    var body: some View {
        VStack {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text("\(value)").font(.title3).bold()
        }
        .padding(8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct PrimaryButtonLabel: View {
    let title: String
    var body: some View {
        Text(title)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentColor)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ContentView()
}
