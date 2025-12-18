//
//  BattleSystem.swift
//  Final Project 2
//
//  Created by 陳宣燁 on 2025/12/19.
//

import Foundation

// 舊版戰鬥結果（Legacy），避免與新版 BattleSystem 2.swift 衝突
struct LegacyBattleOutcome {
    let victory: Bool
    let myLosses: Int
    let enemyLosses: Int
    let moraleUsed: Double
    let notes: String
}

@MainActor
enum LegacyBattleSystem {
    static func fight(stage: Stage, commitTroops: Int, state: GameState) -> LegacyBattleOutcome {
        // 檢查糧草
        guard state.rations >= stage.requiredRations else {
            return LegacyBattleOutcome(
                victory: false,
                myLosses: 0,
                enemyLosses: 0,
                moraleUsed: 1.0,
                notes: "糧草不足，士氣渙散（強制戰敗）"
            )
        }

        // 消耗糧草
        state.rations -= stage.requiredRations

        // 士氣
        var morale = 1.0
        if state.hasRampageBuff {
            morale *= 1.10 // 勢如破竹 +10%
            state.clearRampageBuff()
        }

        // TCP 計算（MVP 簡化：不帶武將與錦囊）
        let myTCP = Double(commitTroops) * morale
        let enemyTCP = Double(stage.enemyTroops) * stage.terrain.multiplier

        let victory = myTCP > enemyTCP

        // 戰損（簡化規則）
        var myLosses: Int
        var enemyLosses: Int
        if victory {
            // 差距越大，損失越低；最低也會有少量損耗
            let ratio = enemyTCP / max(myTCP, 1)
            let lossRate = min(0.30, max(0.05, ratio * 0.20))
            myLosses = max(10, Int(Double(commitTroops) * lossRate))
            enemyLosses = stage.enemyTroops // 視為潰散
        } else {
            // 失敗損失較重
            let ratio = myTCP / max(enemyTCP, 1)
            let lossRate = min(0.70, max(0.40, (1 - ratio) * 0.60))
            myLosses = max(20, Int(Double(commitTroops) * lossRate))
            enemyLosses = max(0, Int(Double(stage.enemyTroops) * 0.1))
        }

        // 扣除兵力（不會小於 0）
        let appliedLosses = min(commitTroops, myLosses)
        state.troops = max(0, state.troops - appliedLosses)

        var notes = victory ? "勝利！" : "戰敗…"
        if victory && stage.rewardIP > 0 {
            state.addIP(stage.rewardIP)
            notes += " 獲得 \(stage.rewardIP) IP。"
        }

        return LegacyBattleOutcome(
            victory: victory,
            myLosses: appliedLosses,
            enemyLosses: enemyLosses,
            moraleUsed: morale,
            notes: notes
        )
    }
}
