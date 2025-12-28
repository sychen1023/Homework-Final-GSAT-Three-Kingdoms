import Foundation

struct BattleOutcome {
    let victory: Bool
    let myLosses: Int
    let enemyLosses: Int
    let moraleUsed: Double
    let notes: String
}

@MainActor
enum BattleSystem {
    static func fight(
        stage: Stage,
        commitTroops: Int,
        commitRations: Int,
        state: GameState,
        selectedGenerals: [General] = []
    ) -> BattleOutcome {
        // 將領加成彙總
        let totalAttackBonus: Double = selectedGenerals.reduce(0.0) { $0 + $1.attackBonus }
        let enemyMoraleMultiplier: Double = selectedGenerals.reduce(1.0) { $0 * $1.enemyMoraleMultiplier }
        let lossReduction: Double = min(0.80, selectedGenerals.reduce(0.0) { $0 + $1.lossReduction }) // 上限 80%
        let defeatHalve: Bool = selectedGenerals.contains(where: { $0.defeatLossHalve })

        // 實際兵力依糧草調整
        let commit = max(0, commitTroops)
        let rations = max(0, commitRations)
        let actualTroops: Int
        if rations >= commit {
            actualTroops = commit
        } else {
            actualTroops = max(0, 2 * rations - commit)
        }

        // 我方戰鬥力 = 實際兵力 * 將軍加成
        let myPowerDouble = Double(actualTroops) * (1.0 + totalAttackBonus)

        // 敵方戰鬥力 = 敵方兵力 * 地形加成 * 防守優勢(1.2) * 將軍削弱敵方比例
        let defenseAdvantage = 1.2
        let enemyPowerDouble = Double(stage.enemyTroops) * stage.terrain.multiplier * defenseAdvantage * enemyMoraleMultiplier

        // 改為抽籤決定勝負
        let myWeight = max(0, Int(myPowerDouble.rounded()))
        let enemyWeight = max(0, Int(enemyPowerDouble.rounded()))
        let totalWeight = max(1, myWeight + enemyWeight)
        let draw = Int.random(in: 1...totalWeight)
        let victory = draw <= myWeight

        var myLosses: Int
        var enemyLosses: Int
        if victory {
            let ratio = enemyPowerDouble / max(myPowerDouble, 1)
            var lossRate = min(0.30, max(0.05, ratio * 0.20))
            lossRate *= (1.0 - lossReduction)
            myLosses = max(10, Int(Double(commitTroops) * lossRate))
            enemyLosses = stage.enemyTroops
        } else {
            let ratio = myPowerDouble / max(enemyPowerDouble, 1)
            var lossRate = min(0.70, max(0.40, (1 - ratio) * 0.60))
            lossRate *= (1.0 - lossReduction)
            if defeatHalve {
                lossRate *= 0.5
            }
            myLosses = max(20, Int(Double(commitTroops) * lossRate))
            enemyLosses = max(0, Int(Double(stage.enemyTroops) * 0.1))
        }

        // 扣除兵力
        myLosses = min(commitTroops, myLosses)
        state.troops = max(0, state.troops - myLosses)
        state.rations = max(0, state.rations - max(0, commitRations))

        var notes = victory ? "勝利！" : "戰敗…"
        if !selectedGenerals.isEmpty {
            let names = selectedGenerals.map { $0.displayName }.joined(separator: "、")
            notes += "（上陣：\(names)）"
        }
        if victory && stage.rewardIP > 0 {
            state.addIP(stage.rewardIP)
            notes += " 獲得 \(stage.rewardIP) IP。"
        }

        return BattleOutcome(
            victory: victory,
            myLosses: myLosses,
            enemyLosses: enemyLosses,
            moraleUsed: 1.0,
            notes: notes
        )
    }
}
