//
//  ContentView.swift
//  Final Project 2
//
//  Created by 陳宣燁 on 2025/12/19.
//

import SwiftUI
import LaTeXSwiftUI


private enum Theme {
    // 淺黃色（accent）
    static let accent = Color(.sRGB, red: 1, green: 0.3, blue: 0.2, opacity: 1.0)
    // 主要前景（柔和白）
    static let primaryFG = Color.white.opacity(0.65)
    // 次要前景（較淡的白）
    static let secondaryFG = Color.white.opacity(0.45)
    // 卡片底（半透明深色）- 供非首頁使用
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
    @AppStorage("game_state_v1") private var storedGameState: Data = Data()
    @State private var selectedTab = 0

    var body: some View {
        GeometryReader { outerGeometry in
            TabView(selection: $selectedTab) {
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
                .tag(0)

                // 2) 研讀兵書
                NavigationStack {
                    GeometryReader { geometry in
                        ZStack {
                            BackgroundView(size: outerGeometry.size)
                            QuizView(state: state)
                                .foregroundStyle(.white) // 除了導航標題外，整個頁面字體改為白色
                                .navigationTitle("研讀兵書")
                                .toolbarBackground(.hidden, for: .navigationBar)
                                .background(Color.clear)
                                .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height, alignment: .topLeading)
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                }
                .tabItem { Label("研讀兵書", systemImage: "book.closed.fill") }
                .tag(1)

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
                .tag(2)

                // 4) 出征
                NavigationStack {
                    GeometryReader { geometry in
                        ZStack {
                            BackgroundView(size: outerGeometry.size)
                            Group {
                                if state.currentStageIndex < Campaign.all.count {
                                    let stage = Campaign.all[state.currentStageIndex]
                                    BattleView(state: state, stage: stage)
                                        .navigationTitle("出征")
                                } else {
                                    Text("已完成「一統中原」！")
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
                .tag(3)

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
                .tag(4)
            }
            .tint(Theme.accent) // 全域 accent 設為淺黃色
            .background(Color.clear)
            .toolbarBackground(.hidden, for: .tabBar)
            .frame(width: outerGeometry.size.width, height: outerGeometry.size.height, alignment: .center)
            .animation(.easeInOut(duration: 0.3), value: selectedTab)
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

            // 載入保存的進度
            if !storedGameState.isEmpty {
                do {
                    let snapshot = try JSONDecoder().decode(GameState.Snapshot.self, from: storedGameState)
                    state.apply(snapshot: snapshot)
                } catch {
                    // 若解碼失敗，忽略並繼續使用預設狀態
                    print("Failed to decode saved game state: \(error)")
                }
            }
        }
        .onChange(of: state.ip) { saveState() }
        .onChange(of: state.troops) { saveState() }
        .onChange(of: state.rations) { saveState() }
        .onChange(of: state.combo) { saveState() }
        .onChange(of: state.hasRampageBuff) { saveState() }
        .onChange(of: state.currentStageIndex) { saveState() }
        .onChange(of: state.ownedGenerals) { saveState() }
        .onChange(of: state.answeredCorrect) { saveState() }
        .onChange(of: state.answeredWrong) { saveState() }
        .preferredColorScheme(.light)
    }

    private func saveState() {
        do {
            let data = try JSONEncoder().encode(state.makeSnapshot())
            storedGameState = data
        } catch {
            print("Failed to encode game state: \(error)")
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
    @AppStorage("game_state_v1") private var storedGameState: Data = Data()
    @State private var showResetAlert = false

    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 16) {
                // 資源概況
                ThemedGroupBox {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 16) {
                            ThemedStatBadge(title: "IP", value: state.ip)
                                .animation(.bouncy(duration: 0.6), value: state.ip)
                            ThemedStatBadge(title: "兵馬", value: state.troops)
                                .animation(.bouncy(duration: 0.6), value: state.troops)
                            ThemedStatBadge(title: "糧草", value: state.rations)
                                .animation(.bouncy(duration: 0.6), value: state.rations)
                        }
                        HStack(spacing: 16) {
                            ThemedStatBadge(title: "連勝", value: state.combo)
                                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: state.combo)
                            if state.hasRampageBuff {
                                Label("勢如破竹：士氣 +10%", systemImage: "bolt.fill")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.black)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                    .transition(.asymmetric(
                                        insertion: .scale.combined(with: .opacity),
                                        removal: .scale.combined(with: .opacity)
                                    ))
                                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: state.hasRampageBuff)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(.black)
                } label: {
                    ThemedLabel("資源與狀態", systemImage: "cube.box.fill")
                }

                // 關卡進度
                ThemedGroupBox {
                    VStack(alignment: .leading, spacing: 6) {
                        if state.currentStageIndex < Campaign.all.count {
                            let stage = Campaign.all[state.currentStageIndex]
                            Text("當前關卡：\(stage.name)")
                                .foregroundStyle(.black)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                            Text("敵將：\(stage.enemyGeneral)  兵力：\(stage.enemyTroops)")
                                .foregroundStyle(.black)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                            Text("地形：\(stage.terrain.display)")
                                .foregroundStyle(.black)
                                .font(.footnote)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                            Text("目前進度：第 \(state.currentStageIndex + 1) 關 / \(Campaign.all.count)")
                                .foregroundStyle(.black)
                                .font(.footnote.weight(.semibold))
                        } else {
                            Text("當前關卡：已完成『一統中原』")
                                .foregroundStyle(.black)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
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
                            .foregroundStyle(.black)
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
                                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black.opacity(0.1)))

                                    Text(g.displayName)
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.black)
                                        .shadow(radius: 0)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                }
                                .padding(8)
                                .frame(maxWidth: .infinity)
                                .background(Color.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.1)))
                                .scaleEffect(1.0)
                                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: owned.count)
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity).combined(with: .move(edge: .top)),
                                    removal: .scale.combined(with: .opacity)
                                ))
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
                                .foregroundStyle(Color(.systemGreen))
                                .animation(.easeInOut(duration: 0.3), value: state.answeredCorrect.count)
                            Spacer(minLength: 8)
                            Label("錯題：\(state.answeredWrong.count)", systemImage: "xmark.circle.fill")
                                .foregroundStyle(Color(.systemRed))
                                .animation(.easeInOut(duration: 0.3), value: state.answeredWrong.count)
                        }
                        .foregroundStyle(.black)
                        Text("提示：已答對的題目不再出現；錯題可在「錯題整理」中練習。")
                            .font(.footnote)
                            .foregroundStyle(.black)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                } label: {
                    ThemedLabel("題庫進度", systemImage: "book.fill")
                }

                // 重置資料
                ThemedGroupBox {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("重置所有遊戲進度和資料")
                            .font(.subheadline)
                            .foregroundStyle(.black)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Button {
                            showResetAlert = true
                        } label: {
                            HStack {
                                Image(systemName: "trash.fill")
                                Text("重置所有資料")
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.8), in: RoundedRectangle(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.red))
                        }
                        .foregroundStyle(.white)
                        
                        Text("⚠️ 此操作將清除所有進度，無法復原")
                            .font(.caption)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                } label: {
                    ThemedLabel("資料管理", systemImage: "gear.fill")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color.clear)
        .alert("確認重置", isPresented: $showResetAlert) {
            Button("取消", role: .cancel) { }
            Button("重置", role: .destructive) {
                resetAllData()
            }
        } message: {
            Text("此操作將清除所有遊戲進度，包括資源、武將、關卡進度和題目記錄。此操作無法復原，確定要繼續嗎？")
        }
    }
    
    private func resetAllData() {
        // 重置 GameState
        state.reset()
        
        // 清除 AppStorage
        storedGameState = Data()
        
        // 清除所有 UserDefaults 中可能存在的其他資料
        // 如果未來有其他 AppStorage 變數，也可以在這裡清除
        UserDefaults.standard.removeObject(forKey: "game_state_v1")
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
                        .scaleEffect(1.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.2), value: wrongPairs.isEmpty)
                    Text("目前沒有錯題，太棒了！")
                        .foregroundStyle(Theme.secondaryFG)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .opacity(1.0)
                        .animation(.easeInOut(duration: 0.5).delay(0.4), value: wrongPairs.isEmpty)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                .background(Color.clear)
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .scale.combined(with: .opacity)
                ))
            } else {
                List {
                    ForEach(Array(wrongPairs.enumerated()), id: \.element.0.id) { index, pair in
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
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    practiceQuestion = q
                                    showPracticeSheet = true
                                }
                            } label: {
                                Text("練習")
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Theme.buttonBG, in: Capsule())
                                    .overlay(Capsule().stroke(Theme.accent.opacity(0.6)))
                                    .scaleEffect(1.0)
                            }
                            .foregroundStyle(Theme.primaryFG)
                            .buttonStyle(.plain)
                            .onTapGesture {
                                // 添加點擊回饋動畫
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    practiceQuestion = q
                                    showPracticeSheet = true
                                }
                            }
                        }
                        .contentShape(Rectangle())
                        .listRowBackground(Theme.cardBG)
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading).combined(with: .opacity),
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        ))
                        .animation(.easeInOut(duration: 0.3).delay(Double(index) * 0.05), value: wrongPairs.count)
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
                        .foregroundStyle(.black)
                    LaTeX(question.prompt)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    ForEach(question.choices.indices, id: \.self) { idx in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                selected = idx
                                result = manager.answer(question: question, chosenIndex: idx, state: state)
                                if idx == question.answer {
                                    state.markCorrect(questionID: question.id)
                                } else {
                                    state.markWrong(questionID: question.id)
                                }
                            }
                        } label: {
                            HStack(alignment: .top) {
                                Text(optionLabel(idx))
                                    .font(.headline)
                                    .foregroundStyle(.black)
                                LaTeX(question.choices[idx])
                                    .foregroundStyle(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                Theme.buttonBG,
                                in: RoundedRectangle(cornerRadius: 10)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(
                                        selected == idx 
                                        ? (idx == question.answer ? Color.green : Color.red)
                                        : Theme.cardStroke,
                                        lineWidth: selected == idx ? 2 : 1
                                    )
                                    .animation(.easeInOut(duration: 0.2), value: selected)
                            )
                            .scaleEffect(selected == idx ? 0.98 : 1.0)
                            .animation(.easeInOut(duration: 0.1), value: selected)
                        }
                        .disabled(selected != nil)
                        .buttonStyle(.plain)
                    }

                    if let r = result {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(r.isCorrect ? "答對！" : "答錯…")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(.black)
                            if r.isCorrect {
                                Text("獲得 IP：基礎 \(r.baseIP) + 加成 \(r.bonusIP) = \(r.totalIP)")
                                    .foregroundStyle(.black)
                                Text("當前連勝：\(r.newCombo)")
                                    .foregroundStyle(.black)
                            } else {
                                Text("連勝已重置。")
                                    .foregroundStyle(.black)
                            }
                            if let exp = question.explanation {
                                Divider().overlay(Theme.cardStroke).padding(.vertical, 2)
                                LaTeX("解析：\(exp)")
                                    .font(.footnote)
                                    .foregroundStyle(.black)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Theme.cardBG, in: RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.cardStroke))
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .move(edge: .bottom).combined(with: .opacity)
                        ))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: result != nil)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .foregroundStyle(.black)
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
                .background(Color.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.1)))
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
            .foregroundStyle(.black)
    }
}

private struct ThemedStatBadge: View {
    let title: String
    let value: Int
    @State private var displayValue: Int = 0
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text("\(displayValue)")
                .font(.title3.weight(.bold))
                .foregroundStyle(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .contentTransition(.numericText())
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black.opacity(0.1)))
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                displayValue = value
            }
        }
        .onChange(of: value) { newValue in
            withAnimation(.bouncy(duration: 0.6)) {
                displayValue = newValue
            }
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.light)
}

