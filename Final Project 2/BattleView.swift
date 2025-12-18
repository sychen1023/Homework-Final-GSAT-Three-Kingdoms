//
//  BattleView.swift
//  Final Project 2
//
//  Created by 陳宣燁 on 2025/12/19.
//

import SwiftUI

struct BattleView: View {
    @ObservedObject var state: GameState
    let stage: Stage

    @State private var commit: Double = 0
    @State private var outcome: BattleOutcome?

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                GroupBox("敵情") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(stage.name) - 守將：\(stage.enemyGeneral)")
                        Text("守軍兵力：\(stage.enemyTroops)")
                        Text("所需糧草：\(stage.requiredRations)")
                        Text("地形：\(stage.terrain.display)")
                    }
                }

                GroupBox("我軍配置") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("可用兵力：\(state.troops)")
                        HStack {
                            Text("投入兵力：\(Int(commit))")
                            Slider(value: $commit, in: 0...Double(state.troops), step: 50)
                        }
                        if state.hasRampageBuff {
                            Text("勢如破竹：本場士氣 +10%")
                                .foregroundStyle(.orange)
                        }
                    }
                }

                Button {
                    let used = Int(commit)
                    guard used > 0 else { return }
                    outcome = BattleSystem.fight(stage: stage, commitTroops: used, state: state)
                } label: {
                    Text("攻打")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(state.troops == 0)

                if let o = outcome {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(o.victory ? "勝利！" : "戰敗…")
                            .font(.title3).bold()
                            .foregroundStyle(o.victory ? .green : .red)
                        Text("士氣：x\(String(format: "%.2f", o.moraleUsed))")
                        Text("我方損失：\(o.myLosses)")
                        Text("敵方損失：\(o.enemyLosses)")
                        Text(o.notes).foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }

                Spacer()
            }
            .padding()
            .navigationTitle("出征")
        }
    }
}
