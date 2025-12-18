import Foundation
import Combine

@MainActor
final class GameState: ObservableObject {
    // 經濟資源
    @Published var ip: Int = 0            // 智力點
    @Published var troops: Int = 0        // 兵馬總量
    @Published var rations: Int = 0       // 糧草總量

    // 答題連勝與 Buff
    @Published var combo: Int = 0         // 連勝數
    @Published var hasRampageBuff: Bool = false // 勢如破竹（下一場士氣 +10%）

    // 關卡進度
    @Published var currentStageIndex: Int = 0   // 目前推進到的關卡（0 = 涿郡）

    // 題目紀錄
    // - answeredCorrect: 一旦答對就加入，之後不再抽到
    // - answeredWrong: 曾答錯的題目及錯誤次數（優先抽這些，直到答對為止）
    @Published var answeredCorrect: Set<UUID> = []
    @Published var answeredWrong: [UUID: Int] = [:]

    // MARK: - 經濟操作
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

    // MARK: - 連勝與 Buff
    func resetCombo() { combo = 0 }
    func increaseCombo() { combo += 1 }
    func clearRampageBuff() { hasRampageBuff = false }

    // MARK: - 題目紀錄
    func markCorrect(questionID: UUID) {
        answeredCorrect.insert(questionID)
        answeredWrong.removeValue(forKey: questionID)
    }

    func markWrong(questionID: UUID) {
        // 若已經答對過，則不記錄為錯題
        guard !answeredCorrect.contains(questionID) else { return }
        answeredWrong[questionID, default: 0] += 1
    }

    // 清空所有題目紀錄（可用於重置）
    func resetQuestionProgress() {
        answeredCorrect.removeAll()
        answeredWrong.removeAll()
        combo = 0
        hasRampageBuff = false
    }
}
