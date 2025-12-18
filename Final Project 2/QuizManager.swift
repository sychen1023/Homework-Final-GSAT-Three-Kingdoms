//
//  QuizManager.swift
//  Final Project 2
//
//  Created by 陳宣燁 on 2025/12/19.
//

import Foundation

struct AnswerResult {
    let isCorrect: Bool
    let baseIP: Int
    let bonusIP: Int
    let totalIP: Int
    let newCombo: Int
    let triggeredRampage: Bool
}

@MainActor
final class QuizManager {
    func answer(question: Question, chosenIndex: Int, state: GameState) -> AnswerResult {
        let correct = (chosenIndex == question.answer)
        var base = 0
        var bonus = 0
        var triggeredRampage = false

        if correct {
            base = question.difficulty.ipReward
            state.increaseCombo()

            if state.combo == 5 {
                bonus += 50
            } else if state.combo == 10 {
                bonus += 150
                state.hasRampageBuff = true
                triggeredRampage = true
            }

            state.addIP(base + bonus)
        } else {
            state.resetCombo()
        }

        return AnswerResult(
            isCorrect: correct,
            baseIP: base,
            bonusIP: bonus,
            totalIP: base + bonus,
            newCombo: state.combo,
            triggeredRampage: triggeredRampage
        )
    }
}
