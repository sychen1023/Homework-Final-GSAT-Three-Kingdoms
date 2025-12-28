//
//  QuizView.swift
//  Final Project 2
//
//  Created by 陳宣燁 on 2025/12/19.
//

import SwiftUI

// 注意：此檔原本與「QuizView 2.swift」重複定義 QuizView。
// 為避免衝突，改名為 LegacyQuizView，專案實際使用的是「QuizView 2.swift」中的 QuizView。

struct LegacyQuizView: View {
    @ObservedObject var state: GameState
    @State private var current: Question?
    @State private var showExplanation = false
    @State private var lastResult: AnswerResult?
    private let manager = QuizManager()

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                if let q = current {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("[\(q.subject)] \(q.difficulty.displayName) 題")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if containsLatex(q.prompt) {
                            MathLabelView(latex: normalizeDollarDelimiters(q.prompt), fontSize: 20, textColor: UIColor.label)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            Text(q.prompt)
                                .font(.title3).bold()
                        }
                        ForEach(q.choices.indices, id: \.self) { idx in
                            Button {
                                answer(idx)
                            } label: {
                                HStack(alignment: .top) {
                                    Text(optionLabel(idx))
                                        .font(.headline)
                                    if containsLatex(q.choices[idx]) {
                                        MathLabelView(latex: normalizeDollarDelimiters(q.choices[idx]), fontSize: 17, textColor: UIColor.label)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    } else {
                                        Text(q.choices[idx])
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                                .padding()
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                } else {
                    Text("沒有題目可作答。")
                }

                if let result = lastResult {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(result.isCorrect ? "答對！" : "答錯…")
                            .font(.headline)
                            .foregroundStyle(result.isCorrect ? .green : .red)
                        if result.isCorrect {
                            Text("獲得 IP：基礎 \(result.baseIP) + 加成 \(result.bonusIP) = \(result.totalIP)")
                            Text("當前連勝：\(result.newCombo)")
                            if result.triggeredRampage {
                                Text("達成 10 連勝！獲得「勢如破竹」：下一場士氣 +10%")
                                    .foregroundStyle(.orange)
                            }
                        } else {
                            Text("連勝已重置。")
                        }
                        if showExplanation, let exp = current?.explanation {
                            Divider()
                            if containsLatex(exp) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("解析：").font(.footnote.weight(.semibold))
                                    MathLabelView(latex: normalizeDollarDelimiters(exp), fontSize: 15, textColor: UIColor.label)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            } else {
                                Text("解析：\(exp)").font(.footnote)
                            }
                        }
                    }
                    .padding(12)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }

                Spacer()

                HStack {
                    Button("看解析") { showExplanation.toggle() }
                        .disabled(current?.explanation == nil)
                    Spacer()
                    Button("下一題") { loadRandom() }
                }
            }
            .padding()
            .navigationTitle("研讀兵書")
            .onAppear { loadRandom() }
        }
    }

    private func optionLabel(_ idx: Int) -> String {
        let letters = ["A","B","C","D","E","F","G","H"]
        return idx < letters.count ? letters[idx] : "\(idx + 1)."
    }

    private func loadRandom() {
        let bank = QuestionBank.shared
        current = bank.random(count: 1).first ?? bank.all().shuffled().first
        lastResult = nil
        showExplanation = false
    }

    private func answer(_ idx: Int) {
        guard let q = current else { return }
        let result = manager.answer(question: q, chosenIndex: idx, state: state)
        lastResult = result
    }
}

// MARK: - 替代 SwiftMath 的簡單實現
struct MathLabelView: View {
    let latex: String
    let fontSize: CGFloat
    let textColor: UIColor
    
    var body: some View {
        // 簡化版本：移除 LaTeX 標記並顯示純文字
        Text(cleanLatexText(latex))
            .font(.system(size: fontSize))
            .foregroundStyle(Color(textColor))
    }
    
    private func cleanLatexText(_ text: String) -> String {
        // 移除常見的 LaTeX 標記
        return text
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: "\\", with: "")
            .replacingOccurrences(of: "_{", with: "_")
            .replacingOccurrences(of: "^{", with: "^")
            .replacingOccurrences(of: "}", with: "")
            .replacingOccurrences(of: "\\frac", with: "")
            .replacingOccurrences(of: "\\sqrt", with: "√")
            .replacingOccurrences(of: "\\pi", with: "π")
            .replacingOccurrences(of: "\\alpha", with: "α")
            .replacingOccurrences(of: "\\beta", with: "β")
            .replacingOccurrences(of: "\\gamma", with: "γ")
            .replacingOccurrences(of: "\\theta", with: "θ")
            .replacingOccurrences(of: "\\sigma", with: "σ")
            .replacingOccurrences(of: "\\infty", with: "∞")
    }
}

// 輔助函數
func containsLatex(_ text: String) -> Bool {
    return text.contains("$") || text.contains("\\")
}

func normalizeDollarDelimiters(_ text: String) -> String {
    return text
}

