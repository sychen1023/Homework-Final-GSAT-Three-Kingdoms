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
        state: GameState,
        selectedGenerals: [General] = []
    ) -> BattleOutcome {
        // 檢查糧草
        guard state.rations >= stage.requiredRations else {
            return BattleOutcome(
                victory: false,
                myLosses: 0,
                enemyLosses: 0,
                moraleUsed: 1.0,
                notes: "糧草不足，士氣渙散（強制戰敗）"
            )
        }

        // 消耗糧草
        state.rations -= stage.requiredRations

        // 基礎士氣
        var morale = 1.0
        if state.hasRampageBuff {
            morale *= 1.10 // 勢如破竹 +10%
            state.clearRampageBuff()
        }

        // 將領加成彙總
        let totalAttackBonus: Double = selectedGenerals.reduce(0.0) { $0 + $1.attackBonus }
        let enemyMoraleMultiplier: Double = selectedGenerals.reduce(1.0) { $0 * $1.enemyMoraleMultiplier }
        let lossReduction: Double = min(0.80, selectedGenerals.reduce(0.0) { $0 + $1.lossReduction }) // 上限 80%
        let defeatHalve: Bool = selectedGenerals.contains(where: { $0.defeatLossHalve })

        // TCP 計算
        let myTCPBase = Double(commitTroops) * morale
        let myTCP = myTCPBase * (1.0 + totalAttackBonus)

        let enemyTCPBase = Double(stage.enemyTroops) * stage.terrain.multiplier
        let enemyTCP = enemyTCPBase * enemyMoraleMultiplier

        let victory = myTCP > enemyTCP

        // 戰損
        var myLosses: Int
        var enemyLosses: Int
        if victory {
            let ratio = enemyTCP / max(myTCP, 1)
            var lossRate = min(0.30, max(0.05, ratio * 0.20))
            lossRate *= (1.0 - lossReduction)
            myLosses = max(10, Int(Double(commitTroops) * lossRate))
            enemyLosses = stage.enemyTroops
        } else {
            let ratio = myTCP / max(enemyTCP, 1)
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
            moraleUsed: morale,
            notes: notes
        )
    }
}
