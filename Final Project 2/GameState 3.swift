import Foundation
import Combine

@MainActor
final class GameState: ObservableObject {
    // 經濟資源
    @Published var ip: Int = 0           // 智力點
    @Published var troops: Int = 0        // 兵馬總量
    @Published var rations: Int = 0       // 糧草總量

    // 答題連勝與 Buff
    @Published var combo: Int = 0         // 連勝數
    @Published var hasRampageBuff: Bool = false // 勢如破竹（下一場士氣 +10%）

    // 關卡進度
    @Published var currentStageIndex: Int = 0   // 目前推進到的關卡（0 = 涿郡）

    // 題目紀錄
    @Published var answeredCorrect: Set<UUID> = []
    @Published var answeredWrong: [UUID: Int] = [:]

    // 名將擁有清單（使用 General.ID = String，對應圖片資源名）
    @Published var ownedGenerals: Set<General.ID> = []

    // MARK: - 持久化快照
    struct Snapshot: Codable {
        var ip: Int
        var troops: Int
        var rations: Int
        var combo: Int
        var hasRampageBuff: Bool
        var currentStageIndex: Int
        var answeredCorrect: [UUID]
        var answeredWrong: [UUID: Int]
        var ownedGenerals: [String]
    }

    func makeSnapshot() -> Snapshot {
        Snapshot(
            ip: ip,
            troops: troops,
            rations: rations,
            combo: combo,
            hasRampageBuff: hasRampageBuff,
            currentStageIndex: currentStageIndex,
            answeredCorrect: Array(answeredCorrect),
            answeredWrong: answeredWrong,
            ownedGenerals: Array(ownedGenerals)
        )
    }

    func apply(snapshot: Snapshot) {
        self.ip = snapshot.ip
        self.troops = snapshot.troops
        self.rations = snapshot.rations
        self.combo = snapshot.combo
        self.hasRampageBuff = snapshot.hasRampageBuff
        self.currentStageIndex = snapshot.currentStageIndex
        self.answeredCorrect = Set(snapshot.answeredCorrect)
        self.answeredWrong = snapshot.answeredWrong
        self.ownedGenerals = Set(snapshot.ownedGenerals)
    }

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
        guard !answeredCorrect.contains(questionID) else { return }
        answeredWrong[questionID, default: 0] += 1
    }

    func resetQuestionProgress() {
        answeredCorrect.removeAll()
        answeredWrong.removeAll()
        combo = 0
        hasRampageBuff = false
    }

    // MARK: - 名將
    func own(_ general: General) {
        ownedGenerals.insert(general.id)
    }

    func has(_ general: General) -> Bool {
        ownedGenerals.contains(general.id)
    }
    
    // MARK: - 資料重置
    func reset() {
        ip = 20000  // 重置為初始值
        troops = 0
        rations = 0
        combo = 0
        hasRampageBuff = false
        currentStageIndex = 0
        answeredCorrect.removeAll()
        answeredWrong.removeAll()
        ownedGenerals.removeAll()
    }
}

