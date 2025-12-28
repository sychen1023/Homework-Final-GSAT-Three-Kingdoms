import SwiftUI
#if canImport(FoundationModels)
import FoundationModels
#endif

struct AIHelperView: View {
    @State private var prompt: String = "我想學習兵法，有什麼建議？"
    @State private var response: String = ""
    @State private var isThinking = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        if !response.isEmpty {
                            Text(response)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        } else {
                            Text("輸入問題，向 AI 詢問建議。")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal)
                }

                HStack(alignment: .bottom, spacing: 8) {
                    TextField("輸入你的問題…", text: $prompt, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(4)
                        .submitLabel(.send)
                        .onSubmit { askAI() }
                    Button(action: askAI) {
                        if isThinking {
                            ProgressView()
                        } else {
                            Image(systemName: "paperplane.fill")
                        }
                    }
                    .disabled(prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isThinking)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("AI 小助手")
        }
    }

    private func askAI() {
        let question = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty else { return }
        isThinking = true
        response = ""

        // Prefer Apple on-device model when available, else fallback
        #if canImport(FoundationModels)
        useFoundationModels(question: question)
        #else
        fallbackAnswer(question: question)
        #endif
    }

    #if canImport(FoundationModels)
    private func useFoundationModels(question: String) {
        // Pseudocode stub using Apple's on-device LLM framework. Replace with actual API if integrated.
        Task {
            do {
                // This is intentionally simplified to avoid compile errors without full framework context.
                // Imagine there is a simple static API like below:
                let generated = "[On-device AI 回覆] " + question
                try await Task.sleep(nanoseconds: 400_000_000)
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        self.response = generated
                    }
                    self.isThinking = false
                }
            } catch {
                await MainActor.run {
                    self.response = "AI 產生內容時發生錯誤：\(error.localizedDescription)"
                    self.isThinking = false
                }
            }
        }
    }
    #endif

    private func fallbackAnswer(question: String) {
        // Very simple local heuristic answer
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 300_000_000)
            if question.contains("兵") || question.localizedCaseInsensitiveContains("戰") {
                withAnimation(.easeInOut(duration: 0.25)) {
                    self.response = "建議先從孫子兵法的\"始計篇\"與\"作戰篇\"入手，每天固定時間練習題目，並在錯題本複習。"
                }
            } else {
                withAnimation(.easeInOut(duration: 0.25)) {
                    self.response = "目前未啟用 Apple on-device AI。這是本機的建議：『\(question)』是個好問題，試著拆解目標、設定提醒並逐步練習。"
                }
            }
            self.isThinking = false
        }
    }
}

#Preview {
    AIHelperView()
}
