//
//  Stages.swift
//  Final Project 2
//
//  Created by 陳宣燁 on 2025/12/19.
//

import Foundation

enum Terrain {
    case plain      // 平原 1.0
    case pass       // 關隘/水戰 1.2

    var multiplier: Double {
        switch self {
        case .plain: return 1.0
        case .pass: return 1.2
        }
    }

    var display: String {
        switch self {
        case .plain: return "平原(1.0)"
        case .pass: return "關隘/水戰(1.2)"
        }
    }
}

struct Stage: Identifiable {
    let id = UUID()
    let order: Int
    let name: String
    let enemyGeneral: String
    let enemyTroops: Int
    let requiredRations: Int
    let terrain: Terrain
    let rewardIP: Int
    let note: String
}

enum Campaign {
    static let all: [Stage] = [
        Stage(
            order: 1,
            name: "涿郡起義",
            enemyGeneral: "黃巾賊程遠志",
            enemyTroops: 500,
            requiredRations: 100,
            terrain: .plain,
            rewardIP: 0,
            note: "新手教學關（勝利獲稱號）"
        )
        // 後續關卡可依你的表格逐步擴充
    ]
}
