import SwiftUI

struct SettingsView: View {
    @Binding var username: String
    @Binding var musicVolume: Double
    @Binding var remindDate: Date
    @Binding var preferredDifficulty: Int
    @Binding var notificationsEnabled: Bool

    @Environment(\.dismiss) private var dismiss
    @State private var showResetAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Section("個人化") {
                    TextField("稱號", text: $username)
                    Slider(value: $musicVolume, in: 0...1) {
                        Text("音量")
                    } minimumValueLabel: { Text("0") } maximumValueLabel: { Text("1") }
                }
                Section("提醒") {
                    DatePicker("學習時間", selection: $remindDate, displayedComponents: [.hourAndMinute])
                    Toggle("通知", isOn: $notificationsEnabled)
                }
                Section("難度偏好") {
                    Picker("難度", selection: $preferredDifficulty) {
                        Text("容易").tag(0)
                        Text("普通").tag(1)
                        Text("困難").tag(2)
                    }
                    .pickerStyle(.segmented)
                }
                Section {
                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        Label("重置所有設定", systemImage: "arrow.counterclockwise")
                    }
                }
            }
            .navigationTitle("設定")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("關閉") { dismiss() }
                }
            }
            .alert("確定要重置所有設定嗎？", isPresented: $showResetAlert) {
                Button("取消", role: .cancel) {}
                Button("重置", role: .destructive) {
                    username = "將軍"
                    musicVolume = 0.5
                    remindDate = Date()
                    preferredDifficulty = 1
                    notificationsEnabled = true
                }
            } message: {
                Text("此操作不可復原。")
            }
        }
    }
}

#Preview {
    SettingsView(
        username: .constant("將軍"),
        musicVolume: .constant(0.5),
        remindDate: .constant(Date()),
        preferredDifficulty: .constant(1),
        notificationsEnabled: .constant(true)
    )
}
