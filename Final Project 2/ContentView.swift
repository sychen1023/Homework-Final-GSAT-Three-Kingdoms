//
//  ContentView.swift
//  Final Project 2
//
//  Created by 陳宣燁 on 2025/12/19.
//

import SwiftUI

private enum Theme {
    // 暖金橘（夕陽）
    static let accent = Color(.sRGB, red: 0.95, green: 0.65, blue: 0.20, opacity: 1.0)
    // 主要前景（柔和白）
    static let primaryFG = Color.white.opacity(0.95)
    // 次要前景（較淡的白）
    static let secondaryFG = Color.white.opacity(0.75)
    // 卡片底（半透明深色）
    static let cardBG = Color.black.opacity(0.28)
    // 卡片描邊（極淡白）
    static let cardStroke = Color.white.opacity(0.08)
    // 選項/按鈕底（微亮）
    static let buttonBG = Color.white.opacity(0.10)
    // 背景遮罩強度
    static let backdrop = Color.black.opacity(0.30)
}

struct ContentView: View {
    @StateObject private var state = GameState()

    var body: some View {
        GeometryReader { outerGeometry in
            TabView {
                // 1) 主頁
                NavigationStack {
                    GeometryReader { geometry in
                        ZStack {
                            BackgroundView(size: outerGeometry.size)
                            HomeTabView(state: state)
                                .navigationTitle("軍帳")
                                .toolbarBackground(.hidden, for: .navigationBar)
                                .background(Color.clear)
                                .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height, alignment: .topLeading)
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                }
                .tabItem { Label("主頁", systemImage: "house.fill") }

                // 2) 研讀兵書
                NavigationStack {
                    GeometryReader { geometry in
                        ZStack {
                            BackgroundView(size: outerGeometry.size)
                            QuizView(state: state)
                                .navigationTitle("研讀兵書")
                                .toolbarBackground(.hidden, for: .navigationBar)
                                .background(Color.clear)
                                .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height, alignment: .topLeading)
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                }
                .tabItem { Label("研讀兵書", systemImage: "book.closed.fill") }

                // 3) 招兵買馬
                NavigationStack {
                    GeometryReader { geometry in
                        ZStack {
                            BackgroundView(size: outerGeometry.size)
                            ShopView(state: state)
                                .navigationTitle("招兵買馬")
                                .toolbarBackground(.hidden, for: .navigationBar)
                                .background(Color.clear)
                                .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height, alignment: .topLeading)
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                }
                .tabItem { Label("招兵買馬", systemImage: "cart.fill") }

                // 4) 出征
                NavigationStack {
                    GeometryReader { geometry in
                        ZStack {
                            BackgroundView(size: outerGeometry.size)
                            Group {
                                if let stage = Campaign.all.first {
                                    BattleView(state: state, stage: stage)
                                        .navigationTitle("出征")
                                } else {
                                    Text("尚未設定關卡")
                                        .foregroundStyle(Theme.secondaryFG)
                                        .navigationTitle("出征")
                                        .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height, alignment: .center)
                                }
                            }
                            .toolbarBackground(.hidden, for: .navigationBar)
                            .background(Color.clear)
                            .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height, alignment: .topLeading)
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                }
                .tabItem { Label("出征", systemImage: "shield.lefthalf.filled") }

                // 5) 錯題整理
                NavigationStack {
                    GeometryReader { geometry in
                        ZStack {
                            BackgroundView(size: outerGeometry.size)
                            WrongBookView(state: state)
                                .navigationTitle("錯題整理")
                                .toolbarBackground(.hidden, for: .navigationBar)
                                .background(Color.clear)
                                .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height, alignment: .topLeading)
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                }
                .tabItem { Label("錯題整理", systemImage: "xmark.circle.fill") }
            }
            .tint(Theme.accent)
            .background(Color.clear)
            .toolbarBackground(.hidden, for: .tabBar)
            .frame(width: outerGeometry.size.width, height: outerGeometry.size.height, alignment: .center)
        }
        .ignoresSafeArea()
        .onAppear {
            // TabBar / NavigationBar 透明
            let tab = UITabBarAppearance()
            tab.configureWithTransparentBackground()
            tab.backgroundColor = .clear
            tab.shadowColor = .clear
            UITabBar.appearance().standardAppearance = tab
            UITabBar.appearance().scrollEdgeAppearance = tab

            let nav = UINavigationBarAppearance()
            nav.configureWithTransparentBackground()
            nav.backgroundColor = .clear
            nav.shadowColor = .clear
            UINavigationBar.appearance().standardAppearance = nav
            UINavigationBar.appearance().scrollEdgeAppearance = nav
            UINavigationBar.appearance().compactAppearance = nav
        }
    }
}

// 共用背景（固定尺寸，加入暖色漸層與柔和遮罩）
private struct BackgroundView: View {
    let size: CGSize

    var body: some View {
        GeometryReader { _ in
            ZStack {
                Image("background-picture")
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.width, height: size.height)
                    .clipped()
                    .ignoresSafeArea(.all)

                // 暖色漸層（上亮下稍暗），讓上方標題/內容更清晰
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.black.opacity(0.15),
                        Color.black.opacity(0.25)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // 全域柔和遮罩，微微壓低背景亮度
                Theme.backdrop
                    .ignoresSafeArea()
            }
            .allowsHitTesting(false)
        }
    }
}

private struct HomeTabView: View {
    @ObservedObject var state: GameState

    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 16) {
                // 資源概況
                ThemedGroupBox {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 16) {
                            ThemedStatBadge(title: "IP", value: state.ip)
                            ThemedStatBadge(title: "兵馬", value: state.troops)
                            ThemedStatBadge(title: "糧草", value: state.rations)
                        }
                        HStack(spacing: 16) {
                            ThemedStatBadge(title: "連勝", value: state.combo)
                            if state.hasRampageBuff {
                                Label("勢如破竹：下一場士氣 +10%", systemImage: "bolt.fill")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Theme.accent)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                } label: {
                    ThemedLabel("資源與狀態", systemImage: "cube.box.fill")
                }

                // 關卡進度
                ThemedGroupBox {
                    VStack(alignment: .leading, spacing: 6) {
                        if let stage = Campaign.all.first {
                            Text("當前關卡：\(stage.name)")
                                .foregroundStyle(Theme.primaryFG)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                            Text("敵將：\(stage.enemyGeneral)  兵力：\(stage.enemyTroops)")
                                .foregroundStyle(Theme.primaryFG)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                            Text("所需糧草：\(stage.requiredRations)  地形：\(stage.terrain.display)")
                                .foregroundStyle(Theme.secondaryFG)
                                .font(.footnote)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        } else {
                            Text("尚未設定關卡")
                                .foregroundStyle(Theme.secondaryFG)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                } label: {
                    ThemedLabel("征戰路線", systemImage: "map.fill")
                }

                // 已擁有武將
                ThemedGroupBox {
                    let owned = GeneralCatalog.all.filter { state.ownedGenerals.contains($0.id) }
                    if owned.isEmpty {
                        Text("尚未擁有武將，可至「招兵買馬」購買。")
                            .foregroundStyle(Theme.secondaryFG)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        LazyVGrid(
                            columns: [GridItem(.adaptive(minimum: 90), spacing: 12)],
                            spacing: 12
                        ) {
                            ForEach(owned) { g in
                                VStack(spacing: 6) {
                                    Image(g.imageName)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.cardStroke))

                                    Text(g.displayName)
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(Theme.primaryFG)
                                        .shadow(radius: 2)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                }
                                .padding(8)
                                .frame(maxWidth: .infinity)
                                .background(Theme.cardBG, in: RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.cardStroke))
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                } label: {
                    ThemedLabel("武將與軍師", systemImage: "person.3.fill")
                }

                // 題庫進度
                ThemedGroupBox {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Label("已答對：\(state.answeredCorrect.count)", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Spacer(minLength: 8)
                            Label("錯題：\(state.answeredWrong.count)", systemImage: "xmark.circle.fill")
                                .foregroundStyle(.red)
                        }
                        .foregroundStyle(Theme.primaryFG)
                        Text("提示：已答對的題目不再出現；錯題可在「錯題整理」中練習。")
                            .font(.footnote)
                            .foregroundStyle(Theme.secondaryFG)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                } label: {
                    ThemedLabel("題庫進度", systemImage: "book.fill")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color.clear)
    }
}

private struct WrongBookView: View {
    @ObservedObject var state: GameState
    @State private var practiceQuestion: Question?
    @State private var showPracticeSheet = false

    var body: some View {
        let wrongPairs: [(Question, Int)] = {
            let bank = QuestionBank.shared.all()
            let wrongMap = state.answeredWrong
            return bank.compactMap { q in
                if let c = wrongMap[q.id], !state.answeredCorrect.contains(q.id) {
                    return (q, c)
                }
                return nil
            }
            .sorted { $0.1 > $1.1 }
        }()

        return Group {
            if wrongPairs.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.green)
                    Text("目前沒有錯題，太棒了！")
                        .foregroundStyle(Theme.secondaryFG)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                .background(Color.clear)
            } else {
                List {
                    ForEach(Array(wrongPairs.enumerated()), id: \.element.0.id) { _, pair in
                        let q = pair.0
                        let count = pair.1
                        HStack(alignment: .top, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("[\(q.subject)] \(q.difficulty.displayName)")
                                    .font(.caption)
                                    .foregroundStyle(Theme.secondaryFG)
                                Text(q.prompt)
                                    .font(.subheadline)
                                    .foregroundStyle(Theme.primaryFG)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                                Text("錯誤次數：\(count)")
                                    .font(.caption2)
                                    .foregroundStyle(.red.opacity(0.9))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            Button {
                                practiceQuestion = q
                                showPracticeSheet = true
                            } label: {
                                Text("練習")
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Theme.buttonBG, in: Capsule())
                                    .overlay(Capsule().stroke(Theme.accent.opacity(0.6)))
                            }
                            .foregroundStyle(Theme.primaryFG)
                        }
                        .contentShape(Rectangle())
                        .listRowBackground(Theme.cardBG)
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
        }
        .sheet(isPresented: $showPracticeSheet) {
            if let q = practiceQuestion {
                PracticeSheet(question: q, state: state)
                    .presentationDetents([.medium, .large])
            }
        }
    }
}

private struct PracticeSheet: View {
    let question: Question
    @ObservedObject var state: GameState
    @State private var selected: Int?
    @State private var result: AnswerResult?
    private let manager = QuizManager()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("[\(question.subject)] \(question.difficulty.displayName)")
                        .font(.caption)
                        .foregroundStyle(Theme.secondaryFG)
                    Text(question.prompt)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Theme.primaryFG)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    ForEach(question.choices.indices, id: \.self) { idx in
                        Button {
                            selected = idx
                            result = manager.answer(question: question, chosenIndex: idx, state: state)
                            if idx == question.answer {
                                state.markCorrect(questionID: question.id)
                            } else {
                                state.markWrong(questionID: question.id)
                            }
                        } label: {
                            HStack(alignment: .top) {
                                Text(optionLabel(idx))
                                    .font(.headline)
                                    .foregroundStyle(Theme.accent)
                                Text(question.choices[idx])
                                    .foregroundStyle(Theme.primaryFG)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Theme.buttonBG, in: RoundedRectangle(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.cardStroke))
                        }
                        .disabled(selected != nil)
                    }

                    if let r = result {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(r.isCorrect ? "答對！" : "答錯…")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(r.isCorrect ? Color.green.opacity(0.9) : Color.red.opacity(0.9))
                            if r.isCorrect {
                                Text("獲得 IP：基礎 \(r.baseIP) + 加成 \(r.bonusIP) = \(r.totalIP)")
                                    .foregroundStyle(Theme.primaryFG)
                                Text("當前連勝：\(r.newCombo)")
                                    .foregroundStyle(Theme.primaryFG)
                            } else {
                                Text("連勝已重置。")
                                    .foregroundStyle(Theme.secondaryFG)
                            }
                            if let exp = question.explanation {
                                Divider().overlay(Theme.cardStroke).padding(.vertical, 2)
                                Text("解析：\(exp)")
                                    .font(.footnote)
                                    .foregroundStyle(Theme.secondaryFG)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Theme.cardBG, in: RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.cardStroke))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            .navigationTitle("單題練習")
            .toolbarBackground(.hidden, for: .navigationBar)
            .background(
                LinearGradient(colors: [.clear, Color.black.opacity(0.25)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            )
        }
    }

    @Environment(\.dismiss) private var dismiss

    private func optionLabel(_ idx: Int) -> String {
        let letters = ["A","B","C","D","E","F","G","H"]
        return idx < letters.count ? letters[idx] : "\(idx + 1)."
    }
}

private struct ThemedGroupBox<Content: View, Label: View>: View {
    @ViewBuilder var content: Content
    @ViewBuilder var label: Label

    var body: some View {
        GroupBox {
            content
                .padding(12)
                .background(Theme.cardBG, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.cardStroke))
        } label: {
            label
        }
    }
}

private struct ThemedLabel: View {
    let title: String
    let systemImage: String
    init(_ title: String, systemImage: String) {
        self.title = title
        self.systemImage = systemImage
    }
    var body: some View {
        Label(title, systemImage: systemImage)
            .foregroundStyle(Theme.primaryFG)
    }
}

private struct ThemedStatBadge: View {
    let title: String
    let value: Int
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(Theme.secondaryFG)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text("\(value)")
                .font(.title3.weight(.bold))
                .foregroundStyle(Theme.primaryFG)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(Theme.cardBG, in: RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.cardStroke))
    }
}

#Preview {
    ContentView()
}
