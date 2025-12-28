import SwiftUI
import LaTeXSwiftUI


struct QuizView: View {
    @ObservedObject var state: GameState

    @State private var questions: [Question] = []
    @State private var index: Int = 0                 // 目前第幾題（0-based）
    @State private var stage: String = "quiz"        // "quiz", "answer", "end"

    @State private var selectedAnswerIndex: Int? = nil
    @State private var userIsCorrect: Bool = false
    @State private var lastResult: AnswerResult? = nil

    @State private var sessionCorrect: Int = 0
    @State private var sessionIP: Int = 0

    private let manager = QuizManager()

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack {
                    if stage == "quiz" {
                        Quiz
                    } else if stage == "answer" {
                        Answer
                    } else {
                        End
                    }
                    Spacer()
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .padding()
            .navigationTitle("研讀兵書")
            .toolbarBackground(.hidden, for: .navigationBar)
            .background(Color.clear)
        }
        .onAppear {
            if questions.isEmpty {
                startSession()
            }
        }
    }

    // MARK: - Quiz
    private var Quiz: some View {
        Group {
            if questions.indices.contains(index) {
                let q = questions[index]
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("第 \(index + 1) 題 / 共 \(questions.count) 題")
                            Spacer()
                            Text(q.difficulty.displayName)
                        }
                        .font(.headline)
                        .foregroundStyle(.white)

                        Text("[\(q.subject)]")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))

                        LaTeX(q.prompt)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)

                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(q.choices.indices, id: \.self) { idx in
                                Button(action: {
                                    selectedAnswerIndex = idx
                                    let result = manager.answer(question: q, chosenIndex: idx, state: state, awardImmediately: false)
                                    lastResult = result
                                    userIsCorrect = result.isCorrect
                                    if result.isCorrect {
                                        state.markCorrect(questionID: q.id)
                                        sessionCorrect += 1
                                        sessionIP += result.totalIP
                                    } else {
                                        state.markWrong(questionID: q.id)
                                    }
                                    stage = "answer"
                                }) {
                                    HStack(alignment: .top, spacing: 12) {
                                        Text(optionLabel(idx))
                                            .font(.headline)
                                            .foregroundStyle(.black)
                                        LaTeX(q.choices[idx])
                                            .font(.title3.weight(.semibold))
                                            .foregroundStyle(.black)
                                            .multilineTextAlignment(.leading)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .strokeBorder(.white.opacity(0.35), lineWidth: 1)
                                )
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("正在準備題目…")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .task {
                    if questions.isEmpty {
                        startSession()
                    }
                }
            }
        }
    }

    // MARK: - Answer
    private var Answer: some View {
        Group {
            if questions.indices.contains(index) {
                let q = questions[index]
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 10) {
                            Image(systemName: userIsCorrect ? "checkmark.circle.fill" : "xmark.octagon.fill")
                                .foregroundStyle(userIsCorrect ? .green : .red)
                                .font(.system(size: 28, weight: .bold))
                            Text(userIsCorrect ? "恭喜你答對了" : "你答錯了")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(.white)
                        }

                        if let selected = selectedAnswerIndex, !userIsCorrect {
                            LaTeX("你的選擇：\(q.choices[selected])")
                                .font(.body)
                                .foregroundStyle(.black.opacity(0.9))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        ForEach(q.choices.indices, id: \.self) { idx in
                            if idx == q.answer {
                                LaTeX("正確答案：\(q.choices[idx])")
                                    .font(.headline)
                                    .foregroundStyle(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }

                        if let exp = q.explanation, !exp.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("解釋：")
                                    .font(.headline)
                                    .foregroundStyle(.black)
                                LaTeX(exp)
                                    .font(.body)
                                    .foregroundStyle(.black.opacity(0.95))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(16)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(.white.opacity(0.3), lineWidth: 1)
                            )
                        }

                        Spacer(minLength: 8)

                        HStack {
                            Button("重新開始") {
                                startSession()
                            }
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.25)))

                            Spacer()

                            if index < questions.count - 1 {
                                Button("下一題") {
                                    index += 1
                                    selectedAnswerIndex = nil
                                    lastResult = nil
                                    userIsCorrect = false
                                    stage = "quiz"
                                }
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.25)))
                            } else {
                                Button("查看結果") {
                                    // 一次性發放本回合 IP
                                    if sessionIP > 0 {
                                        state.addIP(sessionIP)
                                    }
                                    stage = "end"
                                }
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.25)))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("正在準備答案頁…")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .task {
                    if questions.isEmpty {
                        startSession()
                    } else {
                        stage = "quiz"
                    }
                }
            }
        }
    }

    // MARK: - End
    private var End: some View {
        VStack(spacing: 24) {
            if questions.isEmpty {
                Text("目前沒有可出題的題目（你可能已經全數答對）")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            } else {
                Text("本回合完成！")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white)
                Text("共 \(questions.count) 題，答對 \(sessionCorrect) 題，獲得 IP：\(sessionIP)")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.95))
            }

            Button("再玩一次") {
                startSession()
            }
            .font(.title3.weight(.semibold))
            .foregroundStyle(.black)
            .padding(.horizontal, 22)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.35)))
        }
        .padding(.top, 40)
        .padding(.horizontal)
    }

    // MARK: - Helpers
    private func startSession() {
        let pool = availablePool()
        questions = Array(pool.shuffled().prefix(10))
        index = 0
        selectedAnswerIndex = nil
        userIsCorrect = false
        lastResult = nil
        sessionCorrect = 0
        sessionIP = 0
        stage = questions.isEmpty ? "end" : "quiz"
    }

    private func availablePool() -> [Question] {
        // 僅從尚未答對的題目中抽題
        let all = QuestionBank.shared.all()
        return all.filter { !state.answeredCorrect.contains($0.id) }
    }

    private func optionLabel(_ idx: Int) -> String {
        let letters = ["A","B","C","D","E","F","G","H"]
        return idx < letters.count ? letters[idx] : "\(idx + 1)."
    }
}
