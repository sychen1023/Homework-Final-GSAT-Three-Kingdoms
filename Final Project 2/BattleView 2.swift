import SwiftUI

struct BattleView: View {
    @ObservedObject var state: GameState
    let stage: Stage

    @State private var commit: Double = 0
    @State private var commitRations: Double = 0
    @State private var outcome: BattleOutcome?
    @State private var selectedGeneralIDs: Set<General.ID> = []
    @State private var showOutcomeAlert = false

    private let maxGenerals = 3

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    GroupBox("敵情") {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("\(stage.name) - 守將：\(stage.enemyGeneral)")
                            Text("守軍兵力：\(stage.enemyTroops)")
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
                            Text("可用糧草：\(state.rations)")
                            HStack {
                                Text("投入糧草：\(Int(commitRations))")
                                Slider(value: $commitRations, in: 0...Double(state.rations), step: 10)
                            }
                            if state.hasRampageBuff {
                                Text("勢如破竹：本場士氣 +10%")
                                    .foregroundStyle(.orange)
                            }
                        }
                    }
                    
                    GroupBox("上陣武將（最多 \(maxGenerals) 名）") {
                        let owned = GeneralCatalog.all.filter { state.ownedGenerals.contains($0.id) }
                        if owned.isEmpty {
                            Text("尚未擁有武將，可至商店購買。")
                                .foregroundStyle(.secondary)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(owned) { g in
                                        GeneralCard(
                                            general: g,
                                            selected: selectedGeneralIDs.contains(g.id)
                                        )
                                        .onTapGesture {
                                            toggleSelect(g)
                                        }
                                    }
                                }
                            }
                            Text("已選：\(selectedGeneralIDs.count) / \(maxGenerals)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Button {
                        let usedTroops = Int(commit)
                        guard usedTroops > 0 else { return }
                        let usedRations = Int(commitRations)
                        let selected = GeneralCatalog.all.filter { selectedGeneralIDs.contains($0.id) }
                        outcome = BattleSystem.fight(
                            stage: stage,
                            commitTroops: usedTroops,
                            commitRations: usedRations,
                            state: state,
                            selectedGenerals: Array(selected.prefix(maxGenerals))
                        )
                        showOutcomeAlert = true
                    } label: {
                        Text("攻打")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(state.troops == 0)
                    
                    Spacer()
                }
                .padding()
                .navigationTitle("出征")
                .alert(outcome?.victory == true ? "勝利！" : "戰敗…", isPresented: $showOutcomeAlert, presenting: outcome) { _ in
                    Button("好", role: .cancel) {
                        if let o = outcome, o.victory {
                            // 推進到下一關（若尚未到最後）
                            if state.currentStageIndex + 1 < Campaign.all.count {
                                state.currentStageIndex += 1
                            }
                        }
                    }
                } message: { o in
                    Text(
                        "士氣：x\(String(format: "%.2f", o.moraleUsed))\n" +
                        "我方損失：\(o.myLosses)\n" +
                        "敵方損失：\(o.enemyLosses)\n" +
                        o.notes
                    )
                }
            }
        }
    }

    private func toggleSelect(_ g: General) {
        if selectedGeneralIDs.contains(g.id) {
            selectedGeneralIDs.remove(g.id)
        } else {
            if selectedGeneralIDs.count < maxGenerals {
                selectedGeneralIDs.insert(g.id)
            }
        }
    }
}

private struct GeneralCard: View {
    let general: General
    let selected: Bool

    var body: some View {
        VStack(spacing: 6) {
            Image(general.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 88, height: 88)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(selected ? Color.accentColor : Color.secondary.opacity(0.3), lineWidth: selected ? 3 : 1)
                )
            Text(general.displayName)
                .font(.caption)
            HStack(spacing: 6) {
                if general.attackBonus > 0 {
                    Tag(text: "+\(Int(general.attackBonus * 100))%")
                }
                if general.enemyMoraleMultiplier < 1.0 {
                    Tag(text: "敵-\(Int((1 - general.enemyMoraleMultiplier) * 100))%")
                }
                if general.lossReduction > 0 {
                    Tag(text: "損-\(Int(general.lossReduction * 100))%")
                }
                if general.defeatLossHalve {
                    Tag(text: "敗半")
                }
            }
        }
        .frame(width: 110)
    }
}

private struct Tag: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(.ultraThinMaterial, in: Capsule())
    }
}

