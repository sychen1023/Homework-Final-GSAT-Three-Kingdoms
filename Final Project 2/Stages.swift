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
        ),
        Stage(
            order: 2,
            name: "虎牢關激戰",
            enemyGeneral: "呂布",
            enemyTroops: 1200,
            requiredRations: 180,
            terrain: .pass,
            rewardIP: 50,
            note: "諸侯聯軍鏖戰虎牢關"
        ),
        Stage(
            order: 3,
            name: "官渡之戰",
            enemyGeneral: "袁紹",
            enemyTroops: 2000,
            requiredRations: 260,
            terrain: .plain,
            rewardIP: 80,
            note: "以少勝多的經典會戰"
        ),
        Stage(
            order: 4,
            name: "赤壁火攻",
            enemyGeneral: "曹操水軍",
            enemyTroops: 2500,
            requiredRations: 320,
            terrain: .pass,
            rewardIP: 120,
            note: "借東風，一把火定江東"
        ),
        Stage(
            order: 5,
            name: "荊州爭奪",
            enemyGeneral: "劉表殘部",
            enemyTroops: 1800,
            requiredRations: 240,
            terrain: .plain,
            rewardIP: 100,
            note: "南北要衝，得之可控兩河"
        ),
        Stage(
            order: 6,
            name: "漢中爭霸",
            enemyGeneral: "張郃",
            enemyTroops: 2600,
            requiredRations: 340,
            terrain: .pass,
            rewardIP: 150,
            note: "蜀魏角力於巴蜀天險"
        ),
        Stage(
            order: 7,
            name: "夷陵決戰",
            enemyGeneral: "陸遜",
            enemyTroops: 3000,
            requiredRations: 380,
            terrain: .pass,
            rewardIP: 160,
            note: "火計奇襲，勝負轉瞬"
        ),
        Stage(
            order: 8,
            name: "合肥強襲",
            enemyGeneral: "張遼",
            enemyTroops: 3200,
            requiredRations: 420,
            terrain: .pass,
            rewardIP: 180,
            note: "虎將威震逍遙津"
        ),
        Stage(
            order: 9,
            name: "襄樊會戰",
            enemyGeneral: "曹仁",
            enemyTroops: 3500,
            requiredRations: 460,
            terrain: .plain,
            rewardIP: 200,
            note: "扼守漢水要地，決勝中原之前哨"
        ),
        Stage(
            order: 10,
            name: "一統中原",
            enemyGeneral: "司馬懿",
            enemyTroops: 4500,
            requiredRations: 600,
            terrain: .plain,
            rewardIP: 300,
            note: "最終決戰——終結群雄割據，完成一統！"
        )
    ]
}
