import SwiftUI

struct QuizView: View {
    @ObservedObject var state: GameState
    @State private var current: Question?
    @State private var showExplanation = false
    @State private var lastResult: AnswerResult?
    private let manager = QuizManager()

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                header

                if let q = current {
                    questionBlock(q)
                } else {
                    Text(emptyMessage())
                        .foregroundStyle(.secondary)
                }

                if let result = lastResult {
                    resultBlock(result)
                }

                Spacer()

                footerControls
            }
            .padding()
            .navigationTitle("研讀兵書")
            .onAppear { loadNextQuestion() }
        }
    }

    // MARK: - Subviews

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("題庫進度")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(spacing: 12) {
                    Label("已答對：\(state.answeredCorrect.count)", systemImage: "checkmark.circle.fill")
                        .labelStyle(.iconOnly)
                        .foregroundStyle(.green)
                        .overlay(Text("已答對：\(state.answeredCorrect.count)").font(.caption), alignment: .trailing)
                        .opacity(0)

                    Label("錯題：\(state.answeredWrong.count)", systemImage: "xmark.circle.fill")
                        .labelStyle(.iconOnly)
                        .foregroundStyle(.red)
                        .overlay(Text("錯題：\(state.answeredWrong.count)").font(.caption), alignment: .trailing)
                        .opacity(0)
                }
            }
            Spacer()
            if let q = current {
                Text(q.difficulty.displayName)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial, in: Capsule())
            }
        }
    }

    private func questionBlock(_ q: Question) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("[\(q.subject)]")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(q.prompt)
                .font(.title3).bold()

            ForEach(q.choices.indices, id: \.self) { idx in
                Button {
                    answer(idx)
                } label: {
                    HStack(alignment: .top) {
                        Text(optionLabel(idx))
                            .font(.headline)
                        Text(q.choices[idx])
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }

    private func resultBlock(_ result: AnswerResult) -> some View {
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
                Text("解析：\(exp)").font(.footnote)
            }
        }
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var footerControls: some View {
        HStack {
            Button("看解析") { showExplanation.toggle() }
                .disabled(current?.explanation == nil)
            Spacer()
            Button("下一題") { loadNextQuestion() }
        }
    }

    // MARK: - Logic

    private func optionLabel(_ idx: Int) -> String {
        let letters = ["A","B","C","D","E","F","G","H"]
        return idx < letters.count ? letters[idx] : "\(idx + 1)."
    }

    private func emptyMessage() -> String {
        let total = QuestionBank.shared.count()
        if state.answeredCorrect.count >= total && total > 0 {
            return "恭喜！你已經把題庫全部答對清空了。"
        } else if total == 0 {
            return "題庫是空的，請先加入題目。"
        } else {
            return "目前沒有可出題的題目。"
        }
    }

    // 僅排除已答對的題目，不再優先出錯題
    private func loadNextQuestion() {
        let bank = QuestionBank.shared
        let all = bank.all()

        // 只從「尚未答對」的題目中抽一題
        let remaining = all.filter { !state.answeredCorrect.contains($0.id) }
        if let pick = remaining.randomElement() {
            current = pick
            lastResult = nil
            showExplanation = false
            return
        }

        // 全部答對了或沒有題目
        current = nil
        lastResult = nil
        showExplanation = false
    }

    private func answer(_ idx: Int) {
        guard let q = current else { return }
        let result = manager.answer(question: q, chosenIndex: idx, state: state)
        lastResult = result

        if result.isCorrect {
            state.markCorrect(questionID: q.id)
        } else {
            // 仍可保留錯題紀錄，但不再影響出題順序
            state.markWrong(questionID: q.id)
        }
    }
}
