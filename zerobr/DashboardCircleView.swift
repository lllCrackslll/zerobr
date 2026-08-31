//
//  DashboardCircleView.swift
//  zerobr
//
//  Created by Rayane Batil on 31/08/2026.
//

import SwiftUI

// MARK: - Onglet Cercle

struct DashboardCircleView: View {
    private struct Member: Identifiable {
        let id = UUID()
        let rank: Int
        let name: String
        let initials: String
        let days: Int
        let badge: String
        let tint: Color
        let isUser: Bool
        let hasRelapsed: Bool
    }

    private let members: [Member] = [
        Member(rank: 1, name: "Lucas M.", initials: "LM", days: 42, badge: "Maître Dopamine", tint: ZBTheme.amber, isUser: false, hasRelapsed: false),
        Member(rank: 2, name: "Maxime D.", initials: "MD", days: 28, badge: "Guerrier", tint: ZBTheme.cyan, isUser: false, hasRelapsed: false),
        Member(rank: 3, name: "Antoine R.", initials: "AR", days: 15, badge: "En Course", tint: ZBTheme.flameOrange, isUser: false, hasRelapsed: false),
        Member(rank: 4, name: "Alexandre (Toi)", initials: "AL", days: 1, badge: "Nouveau Départ", tint: ZBTheme.violet, isUser: true, hasRelapsed: false),
        Member(rank: 5, name: "Thomas B.", initials: "TB", days: 0, badge: "Recommencé hier", tint: ZBTheme.pink, isUser: false, hasRelapsed: true)
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                header

                PodiumView(
                    first: (name: "Lucas M.", days: 42, initials: "LM"),
                    second: (name: "Maxime D.", days: 28, initials: "MD"),
                    third: (name: "Antoine R.", days: 15, initials: "AR")
                )

                VStack(spacing: 10) {
                    ForEach(members) { member in
                        MemberRow(member: member)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 120)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Mon Cercle de Discipline")
                .font(ZBTheme.font(26, .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                Haptics.tap()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "link")
                        .font(.system(size: 15, weight: .bold))

                    Text("Inviter un allié")
                        .font(ZBTheme.font(15, .bold))

                    Spacer()

                    Text("Code : ZERO-782")
                        .font(ZBTheme.font(13, .semibold))
                        .foregroundStyle(.white.opacity(0.75))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.white.opacity(0.14))
                        .clipShape(Capsule())
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .frame(height: 54)
                .background {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [ZBTheme.indigo, ZBTheme.cyan.opacity(0.75)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                .shadow(color: ZBTheme.indigo.opacity(0.4), radius: 14, y: 5)
            }
            .buttonStyle(PressableButtonStyle())
        }
        .padding(.top, 8)
    }

    // MARK: Podium

    private struct PodiumView: View {
        let first: (name: String, days: Int, initials: String)
        let second: (name: String, days: Int, initials: String)
        let third: (name: String, days: Int, initials: String)

        var body: some View {
            HStack(alignment: .bottom, spacing: 12) {
                PodiumColumn(
                    medal: "🥈",
                    name: second.name,
                    days: second.days,
                    initials: second.initials,
                    height: 96,
                    tint: Color(red: 0xC0 / 255, green: 0xC4 / 255, blue: 0xCC / 255)
                )

                PodiumColumn(
                    medal: "🥇",
                    name: first.name,
                    days: first.days,
                    initials: first.initials,
                    height: 130,
                    tint: ZBTheme.amber,
                    showsCrown: true
                )

                PodiumColumn(
                    medal: "🥉",
                    name: third.name,
                    days: third.days,
                    initials: third.initials,
                    height: 74,
                    tint: Color(red: 0xCD / 255, green: 0x7F / 255, blue: 0x32 / 255)
                )
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .dashboardCard()
        }
    }

    private struct PodiumColumn: View {
        let medal: String
        let name: String
        let days: Int
        let initials: String
        let height: CGFloat
        let tint: Color
        var showsCrown = false

        var body: some View {
            VStack(spacing: 8) {
                if showsCrown {
                    Text("👑")
                        .font(.system(size: 22))
                }

                MemberAvatar(initials: initials, tint: tint, size: 46)

                Text(name)
                    .font(ZBTheme.font(12, .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text("\(days) j")
                    .font(ZBTheme.font(12, .bold))
                    .foregroundStyle(tint)

                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [tint.opacity(0.55), tint.opacity(0.12)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(alignment: .top) {
                        Text(medal)
                            .font(.system(size: 20))
                            .padding(.top, 8)
                    }
                    .frame(height: height)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: Ligne du classement

    private struct MemberRow: View {
        let member: Member

        @State private var boostSent = false
        @State private var boostBounce = false

        var body: some View {
            HStack(spacing: 14) {
                Text("#\(member.rank)")
                    .font(ZBTheme.font(15, .bold))
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(width: 30, alignment: .leading)

                MemberAvatar(initials: member.initials, tint: member.tint, size: 42)

                VStack(alignment: .leading, spacing: 3) {
                    Text(member.name)
                        .font(ZBTheme.font(15, .bold))
                        .foregroundStyle(.white)

                    Text(member.badge)
                        .font(ZBTheme.font(12, .semibold))
                        .foregroundStyle(member.hasRelapsed ? ZBTheme.pink : member.tint)
                }

                Spacer(minLength: 0)

                if member.hasRelapsed {
                    Button {
                        guard !boostSent else { return }
                        Haptics.success()
                        withAnimation(.spring(duration: 0.4, bounce: 0.6)) {
                            boostSent = true
                            boostBounce = true
                        }
                        Task {
                            try? await Task.sleep(for: .milliseconds(350))
                            withAnimation(.spring(duration: 0.3)) {
                                boostBounce = false
                            }
                        }
                    } label: {
                        Text(boostSent ? "Force envoyée ✅" : "👊 Envoyer de la force")
                            .font(ZBTheme.font(12, .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background {
                                Capsule().fill(
                                    boostSent
                                        ? AnyShapeStyle(Color.white.opacity(0.10))
                                        : AnyShapeStyle(
                                            LinearGradient(
                                                colors: [ZBTheme.flameOrange, ZBTheme.pink],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                )
                            }
                            .scaleEffect(boostBounce ? 1.15 : 1)
                    }
                    .buttonStyle(PressableButtonStyle())
                } else {
                    HStack(spacing: 4) {
                        Text(member.hasRelapsed ? "⚠️" : "🔥")
                        Text("\(member.days) j")
                            .font(ZBTheme.font(15, .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .dashboardCard(
                cornerRadius: 20,
                borderColor: member.isUser ? ZBTheme.violet.opacity(0.55) : .white.opacity(0.10)
            )
            .overlay {
                if member.isUser {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [ZBTheme.violet.opacity(0.7), ZBTheme.cyan.opacity(0.5)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 1.2
                        )
                }
            }
            .shadow(color: member.isUser ? ZBTheme.violet.opacity(0.25) : .clear, radius: 14, y: 4)
        }
    }
}

// MARK: - Avatar géométrique néon

struct MemberAvatar: View {
    let initials: String
    let tint: Color
    let size: CGFloat

    var body: some View {
        Text(initials)
            .font(ZBTheme.font(size * 0.34, .bold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background {
                Circle().fill(
                    AngularGradient(
                        colors: [tint, tint.opacity(0.4), tint],
                        center: .center
                    )
                )
            }
            .overlay {
                Circle().strokeBorder(.white.opacity(0.25), lineWidth: 1)
            }
            .shadow(color: tint.opacity(0.4), radius: 8)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        DashboardCircleView()
    }
    .preferredColorScheme(.dark)
}
