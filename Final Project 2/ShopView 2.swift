import SwiftUI

struct ShopView: View {
    @ObservedObject var state: GameState

    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 20) {

                    Text("資源：兵馬")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            TroopCard(
                                title: "徵召鄉勇",
                                subtitle: "+100 兵",
                                price: 50,
                                canBuy: state.ip >= 50
                            ) {
                                if state.spendIP(50) {
                                    state.addTroops(100)
                                }
                            }

                            TroopCard(
                                title: "精銳步兵",
                                subtitle: "+1000 兵",
                                price: 450,
                                canBuy: state.ip >= 450
                            ) {
                                if state.spendIP(450) {
                                    state.addTroops(1000)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    Text("資源：糧草")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            RationCard(
                                title: "小型糧倉",
                                subtitle: "+100 糧",
                                price: 100,
                                canBuy: state.ip >= 100
                            ) {
                                if state.spendIP(100) {
                                    state.addRations(100)
                                }
                            }

                            RationCard(
                                title: "大型糧倉",
                                subtitle: "+300 糧",
                                price: 300,
                                canBuy: state.ip >= 300
                            ) {
                                if state.spendIP(300) {
                                    state.addRations(300)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    Text("武將")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(GeneralCatalog.all) { general in
                                GeneralBigCard(
                                    general: general,
                                    owned: state.has(general),
                                    canBuy: state.ip >= general.price
                                ) {
                                    guard !state.has(general) else { return }
                                    if state.spendIP(general.price) {
                                        state.own(general)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("資產概況")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.white)
                        VStack(spacing: 8) {
                            HStack { Text("IP").foregroundStyle(.white); Spacer(); Text("\(state.ip)").foregroundStyle(.white) }
                            HStack { Text("兵馬").foregroundStyle(.white); Spacer(); Text("\(state.troops)").foregroundStyle(.white) }
                            HStack { Text("糧草").foregroundStyle(.white); Spacer(); Text("\(state.rations)").foregroundStyle(.white) }
                            HStack(alignment: .top) {
                                Text("武將").foregroundStyle(.white)
                                Spacer()
                                Text(state.ownedGenerals.map { GeneralCatalog.byID($0)?.displayName ?? $0 }.joined(separator: "、"))
                                    .foregroundStyle(.white)
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                        .padding(12)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)

                }
                .padding(.vertical, 16)
            }
            .background(Color.clear)
            .navigationTitle("招兵買馬")
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
}

private struct TroopCard: View {
    let title: String
    let subtitle: String
    let price: Int
    let canBuy: Bool
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.black)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.black.opacity(0.8))

            Spacer(minLength: 4)

            HStack {
                Text("\(price) IP")
                    .font(.caption)
                    .foregroundStyle(.black.opacity(0.7))
                Spacer()
                Button("購買", action: action)
                    .buttonStyle(.borderedProminent)
                    .disabled(!canBuy)
            }
        }
        .padding(12)
        .frame(width: 240, height: 130, alignment: .topLeading)
        .background(Color.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.1)))
    }
}

private struct RationCard: View {
    let title: String
    let subtitle: String
    let price: Int
    let canBuy: Bool
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.black)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.black.opacity(0.8))

            Spacer(minLength: 4)

            HStack {
                Text("\(price) IP")
                    .font(.caption)
                    .foregroundStyle(.black.opacity(0.7))
                Spacer()
                Button("購買", action: action)
                    .buttonStyle(.borderedProminent)
                    .disabled(!canBuy)
            }
        }
        .padding(12)
        .frame(width: 240, height: 130, alignment: .topLeading)
        .background(Color.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.1)))
    }
}

private struct GeneralBigCard: View {
    let general: General
    let owned: Bool
    let canBuy: Bool
    let onBuy: () -> Void

    private let imageSize: CGFloat = 150

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .topTrailing) {
                Image(general.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: imageSize, height: imageSize, alignment: .top)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.12)))

                if owned {
                    Text("已擁有")
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(.ultraThinMaterial, in: Capsule())
                        .overlay(Capsule().stroke(Color.black.opacity(0.1)))
                        .offset(x: -6, y: 6)
                }
            }

            Text(general.displayName)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)

            HStack {
                if !owned {
                    Text("\(general.price) IP")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                    Spacer()
                    Button("購買", action: onBuy)
                        .buttonStyle(.borderedProminent)
                        .disabled(!canBuy)
                } else {
                    Spacer()
                }
            }
        }
        .frame(width: imageSize, alignment: .top)
    }
}
