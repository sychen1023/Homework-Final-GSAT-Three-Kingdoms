//
//  GameState.swift
//  Final Project 2
//
//  Created by 陳宣燁 on 2025/12/19.
//

import Foundation
import Combine

// 注意：此檔原本與 GameState 2.swift 重複定義 GameState。
// 為避免衝突，改名為 LegacyGameState，並保留供日後參考。
// 專案中實際使用的型別為 GameState（定義於「GameState 2.swift」）。

@MainActor
final class LegacyGameState: ObservableObject {
    @Published var ip: Int = 0            // 智力點
    @Published var troops: Int = 0        // 兵馬總量
    @Published var rations: Int = 0       // 糧草總量
    @Published var combo: Int = 0         // 連勝數
    @Published var hasRampageBuff: Bool = false // 勢如破竹（下一場士氣 +10%）
    @Published var currentStageIndex: Int = 0   // 目前推進到的關卡（0 = 涿郡）

    func addIP(_ value: Int) { ip += value }
    func spendIP(_ value: Int) -> Bool {
        guard ip >= value else { return false }
        ip -= value
        return true
    }

    func addTroops(_ value: Int) { troops += value }
    func addRations(_ value: Int) { rations += value }

    func consumeRations(_ value: Int) -> Bool {
        guard rations >= value else { return false }
        rations -= value
        return true
    }

    func resetCombo() { combo = 0 }
    func increaseCombo() { combo += 1 }
    func clearRampageBuff() { hasRampageBuff = false }
}

