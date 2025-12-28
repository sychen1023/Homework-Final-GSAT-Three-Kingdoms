import Foundation
import SwiftUI

enum GeneralType: String, Codable, CaseIterable {
    case warrior   // 武力型（加攻擊）
    case strategist // 智力型（輔助/減損耗/士氣）
}

struct General: Identifiable, Hashable, Codable {
    typealias ID = String

    let id: ID              // 方便用固定字串（同圖片資源名）
    let displayName: String
    let type: GeneralType
    let price: Int
    let imageName: String

    // 數值影響（MVP 簡化）
    // - 攻擊加成：我方 TCP 乘上 (1 + attackBonus)
    // - 敵方士氣削弱：敵方 TCP 乘上 enemyMoraleMultiplier（< 1 代表削弱）
    // - 戰損減免：勝利/失敗時的我方損耗乘上 (1 - lossReduction)
    // - 敗北損失減半：若 true，敗北時我方損耗 * 0.5
    let attackBonus: Double
    let enemyMoraleMultiplier: Double
    let lossReduction: Double
    let defeatLossHalve: Bool

    var idString: String { id }
}

enum GeneralCatalog {
    // 名稱與圖片需對應 Assets：
    // Guan-yu, Huang-zhong, Jiang-wei, Ma-chao, Zhang-fei, Zhao-yun, Zhu-ge-liang
    static let all: [General] = [
        General(
            id: "Guan-yu",
            displayName: "關羽",
            type: .warrior,
            price: 5000,
            imageName: "Guan-yu",
            attackBonus: 0.20,
            enemyMoraleMultiplier: 1.0,
            lossReduction: 0.05,
            defeatLossHalve: false
        ),
        General(
            id: "Zhang-fei",
            displayName: "張飛",
            type: .warrior,
            price: 4500,
            imageName: "Zhang-fei",
            attackBonus: 0.10,
            enemyMoraleMultiplier: 0.90,
            lossReduction: 0.05,
            defeatLossHalve: false
        ),
        General(
            id: "Zhao-yun",
            displayName: "趙雲",
            type: .warrior,
            price: 4800,
            imageName: "Zhao-yun",
            attackBonus: 0.12,
            enemyMoraleMultiplier: 1.0,
            lossReduction: 0.10,
            defeatLossHalve: true
        ),
        General(
            id: "Ma-chao",
            displayName: "馬超",
            type: .warrior,
            price: 4400,
            imageName: "Ma-chao",
            attackBonus: 0.15,
            enemyMoraleMultiplier: 1.0,
            lossReduction: 0.05,
            defeatLossHalve: false
        ),
        General(
            id: "Huang-zhong",
            displayName: "黃忠",
            type: .warrior,
            price: 4300,
            imageName: "Huang-zhong",
            attackBonus: 0.10,
            enemyMoraleMultiplier: 1.0,
            lossReduction: 0.08,
            defeatLossHalve: false
        ),
        General(
            id: "Jiang-wei",
            displayName: "姜維",
            type: .strategist,
            price: 3800,
            imageName: "Jiang-wei",
            attackBonus: 0.08,
            enemyMoraleMultiplier: 0.95,
            lossReduction: 0.08,
            defeatLossHalve: false
        ),
        General(
            id: "Zhu-ge-liang",
            displayName: "諸葛亮",
            type: .strategist,
            price: 10000,
            imageName: "Zhu-ge-liang",
            attackBonus: 0.4,
            enemyMoraleMultiplier: 0.8,
            lossReduction: 0.10,
            defeatLossHalve: true
        )
    ]

    static func byID(_ id: General.ID) -> General? {
        all.first { $0.id == id }
    }
}
