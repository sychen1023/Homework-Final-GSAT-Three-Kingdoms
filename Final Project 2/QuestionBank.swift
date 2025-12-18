import Foundation

// 題目難度（用於計算 IP 獎勵）
public enum Difficulty: String, Codable, CaseIterable {
    case easy
    case medium
    case hard

    public var ipReward: Int {
        switch self {
        case .easy: return 10
        case .medium: return 20
        case .hard: return 30
        }
    }

    public var displayName: String {
        switch self {
        case .easy: return "簡易"
        case .medium: return "中等"
        case .hard: return "困難"
        }
    }
}

// 最簡單的題目模型：主題、年份、題幹、選項、正確索引、解析（可選）、難度
public struct Question: Identifiable, Codable, Hashable {
    public var id: UUID
    public var subject: String        // 直接用字串，如：「國文」「英文」「歷史」
    public var year: Int?             // 學年度（可省略）
    public var prompt: String         // 題幹
    public var choices: [String]      // 選項（A/B/C/D…）
    public var answer: Int            // 正確選項索引（0 起算）
    public var explanation: String?   // 解析（可省略）
    public var difficulty: Difficulty // 難度（影響 IP 獎勵）

    public init(
        id: UUID = UUID(),
        subject: String,
        year: Int? = nil,
        prompt: String,
        choices: [String],
        answer: Int,
        explanation: String? = nil,
        difficulty: Difficulty = .medium
    ) {
        self.id = id
        self.subject = subject
        self.year = year
        self.prompt = prompt
        self.choices = choices
        self.answer = answer
        self.explanation = explanation
        self.difficulty = difficulty
    }
}

// 題庫錯誤（僅保留最基本）
public enum QuestionBankError: Error, LocalizedError {
    case fileNotFound(String)
    case decodingFailed(Error)
    case indexOutOfBounds

    public var errorDescription: String? {
        switch self {
        case .fileNotFound(let name):
            return "找不到題庫檔案：\(name)"
        case .decodingFailed(let err):
            return "題庫解析失敗：\(err.localizedDescription)"
        case .indexOutOfBounds:
            return "索引超出範圍"
        }
    }
}

// 簡化版題庫容器：保留最基本的增刪查、隨機抽題與（可選）本機 JSON 載入
public final class QuestionBank {

    public static let shared = QuestionBank()

    private(set) var questions: [Question] = []

    public init(seedWithSamples: Bool = true) {
        if seedWithSamples {
            self.questions = Self.sampleQuestions
        }
    }

    // MARK: - 基本操作

    public func all() -> [Question] {
        questions
    }

    public func count() -> Int {
        questions.count
    }

    public func question(at index: Int) throws -> Question {
        guard questions.indices.contains(index) else { throw QuestionBankError.indexOutOfBounds }
        return questions[index]
    }

    public func add(_ q: Question) {
        questions.append(q)
    }

    public func add(contentsOf qs: [Question]) {
        questions.append(contentsOf: qs)
    }

    public func remove(id: UUID) {
        questions.removeAll { $0.id == id }
    }

    public func clear() {
        questions.removeAll()
    }

    // MARK: - 篩選與抽題（簡化）

    public func filter(subject: String? = nil, year: Int? = nil) -> [Question] {
        questions.filter { q in
            if let subject, q.subject != subject { return false }
            if let year, q.year != year { return false }
            return true
        }
    }

    public func random(count: Int, subject: String? = nil, year: Int? = nil) -> [Question] {
        let pool = filter(subject: subject, year: year)
        return Array(pool.shuffled().prefix(count))
    }

    // MARK: - 從本機 JSON 載入（可選）

    // 將題目放到專案資源（bundle）中，格式為 [Question].self
    public func loadFromBundleJSON(named fileName: String, withExtension ext: String = "json") throws {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: ext) else {
            throw QuestionBankError.fileNotFound("\(fileName).\(ext)")
        }
        let data = try Data(contentsOf: url)
        do {
            let decoded = try JSONDecoder().decode([Question].self, from: data)
            self.questions = decoded
        } catch {
            throw QuestionBankError.decodingFailed(error)
        }
    }

    // MARK: - 占位題（自擬，非歷屆真題；可隨時替換）
    // 注意：以下樣本題僅為占位，風格接近學測，但非歷屆真題。

    static let sampleQuestions: [Question] = [
        // 三國/歷史相關（中等）
        Question(
            subject: "歷史",
            year: 2024,
            prompt: "下列關於三國時期政策的敘述，何者較為合理？",
            choices: [
                "蜀漢率先推行科舉，擴大取士來源",
                "魏國實施屯田，有助穩定軍糧與社會秩序",
                "吳國嚴禁海運，導致長江以南經濟衰退",
                "曹操主張無為而治，減少軍事行動"
            ],
            answer: 1,
            explanation: "魏國屯田制能補充軍糧、安定社會；科舉在隋唐後成熟，三國尚未實行。",
            difficulty: .medium
        ),
        Question(
            subject: "國文",
            year: 2023,
            prompt: "閱讀《出師表》語氣與主旨，下列何者最貼近文本？",
            choices: [
                "鋪陳誇飾，以讚頌先帝功德為主",
                "忠懇直陳，闡明治國與用人之道",
                "寓言曲喻，借古以諷今為大宗",
                "激昂慷慨，鼓舞三軍士氣為主"
            ],
            answer: 1,
            explanation: "《出師表》以忠懇直陳、條理清晰著稱，重在治國與用人建議。",
            difficulty: .easy
        ),
        Question(
            subject: "社會",
            year: 2022,
            prompt: "以制度史觀點比較蜀漢與魏國，下列何者較恰當？",
            choices: [
                "蜀漢以均田制為核心，社會流動大增",
                "魏國施行九品中正，影響人才選拔與官僚結構",
                "吳國以游牧經濟為主，故海運不發達",
                "蜀漢廣行世卿世祿，抑制士人崛起"
            ],
            answer: 1,
            explanation: "九品中正制為魏晉以降的重要官僚制度，影響人才選拔與社會結構。",
            difficulty: .medium
        ),
        Question(
            subject: "英文",
            year: 2023,
            prompt: "Which option best describes Zhuge Liang’s leadership style?",
            choices: [
                "Spontaneous and impulsive decision-making",
                "Strategic planning with attention to logistics",
                "Avoidance of collaboration with allies",
                "Exclusive focus on naval warfare"
            ],
            answer: 1,
            explanation: "常見描寫強調其謀略與後勤規劃。",
            difficulty: .easy
        ),

        // 你剛才選取的片段（我補上難度標註）
        Question(
            subject: "歷史",
            year: 2023,
            prompt: "17世紀中葉，荷蘭東印度公司在臺灣的統治面臨挑戰。下列哪一事件直接導致荷蘭人退出臺灣？",
            choices: [
                "郭懷一事件爆發，漢人反抗劇烈",
                "鄭成功率軍攻臺，荷蘭簽約投降",
                "清朝實施海禁，斷絕荷蘭貿易來源",
                "西班牙人北上進攻，荷蘭防守失利"
            ],
            answer: 1,
            explanation: "1661年鄭成功率軍攻臺，圍困熱蘭遮城，1662年荷蘭東印度公司簽字投降並退出臺灣。",
            difficulty: .medium
        ),
        Question(
            subject: "歷史",
            year: 2022,
            prompt: "某位古代思想家主張：「民為貴，社稷次之，君為輕。」並認為若君主無道，人民有權推翻。這位思想家屬於哪一學派？",
            choices: ["道家","法家","墨家","儒家"],
            answer: 3,
            explanation: "此為孟子的核心思想，孟子是儒家代表人物，強調民本思想。",
            difficulty: .easy
        ),
        Question(
            subject: "地理",
            year: 2023,
            prompt: "臺灣許多河川具有「荒溪型」特徵，流量季節變化大。造成此現象的主要氣候因素為何？",
            choices: ["年均溫高，蒸發旺盛","降雨季節分佈不均","地勢陡峭，河川短急","颱風侵襲頻率過高"],
            answer: 1,
            explanation: "臺灣降雨集中在夏季（梅雨、颱風），冬季枯水期長，導致河川流量季節變化顯著。",
            difficulty: .easy
        ),
        Question(
            subject: "公民與社會",
            year: 2022,
            prompt: "政府為了解決外部成本問題，對排放污染的工廠徵收碳稅。此政策在經濟學上希望達到何種效果？",
            choices: ["將外部成本內部化","增加廠商的生產意願","降低產品的市場價格","消除所有的環境汙染"],
            answer: 0,
            explanation: "徵收碳稅是為了讓廠商承擔汙染的社會成本，即「外部成本內部化」，使其產量回歸社會最適水準。",
            difficulty: .easy
        ),
        Question(
            subject: "歷史",
            year: 2021,
            prompt: "19世紀後期，清廷在臺灣推行「開山撫番」政策，主要目的是為了因應下列哪一國際事件的衝擊？",
            choices: ["英法聯軍","牡丹社事件","甲午戰爭","中法戰爭"],
            answer: 1,
            explanation: "1874年牡丹社事件（日軍侵臺）後，清廷體認到臺灣後山防務的重要，沈葆楨遂推行開山撫番。",
            difficulty: .medium
        ),
        Question(
            subject: "地理",
            year: 2024,
            prompt: "若要分析某連鎖超商在全臺的分佈熱點與服務範圍，最適合使用下列哪一種地理資訊系統（GIS）分析功能？",
            choices: ["視域分析","疊圖分析","環域分析","路網分析"],
            answer: 2,
            explanation: "環域分析（Buffer）常用於界定點、線、面圖徵周圍一定距離內的服務範圍或影響範圍。",
            difficulty: .easy
        ),
        Question(
            subject: "公民與社會",
            year: 2023,
            prompt: "依據我國《憲法》及增修條文規定，下列關於總統職權的敘述，何者正確？",
            choices: [
                "總統可直接任命行政院院長，無須立法院同意",
                "總統發布所有命令，均須經行政院院長副署",
                "總統可主動解散立法院，重新進行改選",
                "總統主持行政院會議，決定國家重大政策"
            ],
            answer: 0,
            explanation: "自1997年修憲後，總統任命行政院院長不需經立法院同意（選項0正確）。總統發布依憲法經立法院解散或任免行政院長之命令無須副署。總統被動解散國會（需立法院通過不信任案）。行政院會議由行政院長主持。",
            difficulty: .medium
        ),

        // 其餘樣本（挑幾題，標註難度）
        Question(
            subject: "歷史",
            year: 2020,
            prompt: "冷戰時期，美國為了圍堵共產勢力擴張，在亞洲建立了防禦體系。下列哪一戰爭直接促成了美國將臺灣納入防禦體系？",
            choices: ["越戰","韓戰","國共內戰","八二三砲戰"],
            answer: 1,
            explanation: "1950年韓戰爆發，美國派遣第七艦隊協防臺灣海峽，正式將臺灣納入西太平洋防禦體系。",
            difficulty: .easy
        ),
        Question(
            subject: "地理",
            year: 2022,
            prompt: "澳洲大堡礁面臨白化危機，這與全球暖化導致海水溫度上升有關。這類環境議題最適合用哪種地圖投影來呈現全球分布狀況，以減少面積變形？",
            choices: ["麥卡托投影","蘭伯特投影","等積投影","等角投影"],
            answer: 2,
            explanation: "討論全球性現象分佈時通常選用等積投影以維持面積比例正確。",
            difficulty: .medium
        ),
        Question(
            subject: "公民與社會",
            year: 2024,
            prompt: "某國實施內閣制，國會大選後，沒有任何單一政黨取得過半席次。此時最可能出現的政府組成型態為何？",
            choices: ["少數政府","聯合政府","看守政府","分立政府"],
            answer: 1,
            explanation: "通常會組成聯合政府以取得多數。",
            difficulty: .easy
        )
    ]
}

/*
 JSON 範例（請依此格式提供你已授權可用的題目）：
 [
   {
     "id":"C7B5C2B7-2F67-4F36-8B9D-6F2E1B3B2F10",
     "subject":"國文",
     "year":2021,
     "prompt":"（題幹文字…）",
     "choices":["A 選項","B 選項","C 選項","D 選項"],
     "answer":2,
     "explanation":"（解析，可省略）",
     "difficulty":"medium"
   }
 ]
 注意：
 - 若省略 id，請在載入前自行補上 UUID（或改為非必要欄位）。
 - 學測歷屆題多受著作權保護，正式上架前請確認授權；占位題可先跑流程。
*/
