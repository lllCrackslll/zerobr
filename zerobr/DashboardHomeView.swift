//
//  DashboardHomeView.swift
//  zerobr
//
//  Created by Rayane Batil on 31/08/2026.
//

import Combine
import SwiftUI

// MARK: - Onglet Accueil

struct DashboardHomeView: View {
    @State private var showSOSModal = false
    @State private var selectedMood: String?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                header

                StreakHeroCard()

                sosCard

                HStack(spacing: 14) {
                    MetricTile(
                        icon: "bolt.fill",
                        tint: ZBTheme.cyan,
                        value: "+18 %",
                        label: "Clarté mentale",
                        detail: "cette semaine"
                    )

                    MetricTile(
                        icon: "hourglass",
                        tint: ZBTheme.flameOrange,
                        value: "45 min",
                        label: "Temps préservé",
                        detail: "aujourd'hui"
                    )
                }

                checkInCard
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 120)
        }
        .fullScreenCover(isPresented: $showSOSModal) {
            SOSBreathingModal()
        }
    }

    // MARK: Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Bonjour Alexandre 👋")
                    .font(ZBTheme.font(26, .bold))
                    .foregroundStyle(.white)

                Text("Jour 1 • Phase Détox")
                    .font(ZBTheme.font(12, .bold))
                    .tracking(0.4)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        LinearGradient(
                            colors: [ZBTheme.violet, ZBTheme.cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
            }

            Spacer()
        }
        .padding(.top, 8)
    }

    // MARK: Bouton d'urgence

    private var sosCard: some View {
        Button {
            Haptics.heavy()
            showSOSModal = true
        } label: {
            HStack(spacing: 16) {
                Image(systemName: "light.beacon.max.fill")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 54, height: 54)
                    .background(.white.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text("🚨 Bouton d'Urgence")
                        .font(ZBTheme.font(18, .bold))
                        .foregroundStyle(.white)

                    Text("Envie soudaine ? Active la caméra miroir pour briser l'impulsion.")
                        .font(ZBTheme.font(13, .medium))
                        .foregroundStyle(.white.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0xDC / 255, green: 0x26 / 255, blue: 0x26 / 255),
                                Color(red: 0x7F / 255, green: 0x1D / 255, blue: 0x5C / 255)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(.white.opacity(0.18), lineWidth: 1)
            }
            .shadow(color: Color(red: 0xDC / 255, green: 0x26 / 255, blue: 0x26 / 255).opacity(0.35), radius: 18, y: 6)
        }
        .buttonStyle(PressableButtonStyle())
    }

    // MARK: Check-in quotidien

    private var checkInCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Comment te sens-tu ce soir ?")
                .font(ZBTheme.font(17, .bold))
                .foregroundStyle(.white)

            HStack(spacing: 8) {
                ForEach(["😌 Serein", "⚡ Tenté", "🚀 Énergisé", "😴 Fatigué"], id: \.self) { mood in
                    let isSelected = selectedMood == mood

                    Button {
                        Haptics.tick()
                        withAnimation(.spring(duration: 0.3)) {
                            selectedMood = mood
                        }
                    } label: {
                        Text(mood)
                            .font(ZBTheme.font(13, .semibold))
                            .foregroundStyle(isSelected ? .white : .white.opacity(0.6))
                            .padding(.horizontal, 11)
                            .padding(.vertical, 9)
                            .background {
                                if isSelected {
                                    Capsule().fill(
                                        LinearGradient(
                                            colors: [ZBTheme.violet, ZBTheme.indigo],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                } else {
                                    Capsule().fill(.white.opacity(0.06))
                                }
                            }
                            .overlay {
                                Capsule().strokeBorder(
                                    isSelected ? ZBTheme.violet.opacity(0.6) : .white.opacity(0.10),
                                    lineWidth: 1
                                )
                            }
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .dashboardCard()
    }
}

// MARK: - Hero card : compteur de streak

private struct StreakHeroCard: View {
    private let currentDay = 1
    private let goalDays = 90

    var body: some View {
        VStack(spacing: 20) {
            TimelineView(.animation(minimumInterval: 1.0 / 40.0)) { timeline in
                let t = timeline.date.timeIntervalSinceReferenceDate

                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.08), lineWidth: 9)

                    Circle()
                        .trim(from: 0, to: CGFloat(currentDay) / CGFloat(goalDays))
                        .stroke(
                            LinearGradient(
                                colors: [ZBTheme.violet, ZBTheme.cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 9, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .shadow(color: ZBTheme.cyan.opacity(0.6), radius: 8)

                    VStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [ZBTheme.flameOrange, ZBTheme.pink],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .scaleEffect(1 + 0.07 * sin(t * 2.4))
                            .shadow(color: ZBTheme.flameOrange.opacity(0.45 + 0.25 * sin(t * 2.4)), radius: 14)

                        Text("\(currentDay)")
                            .font(ZBTheme.font(58, .bold))
                            .foregroundStyle(.white)
                            .monospacedDigit()

                        Text("JOUR")
                            .font(ZBTheme.font(13, .bold))
                            .tracking(4)
                            .foregroundStyle(.white.opacity(0.55))
                    }
                }
            }
            .frame(width: 210, height: 210)

            VStack(spacing: 6) {
                Text("23h 48m avant le palier Jour 2")
                    .font(ZBTheme.font(15, .semibold))
                    .foregroundStyle(.white)

                Text("Objectif : \(goalDays) jours • \(currentDay) / \(goalDays)")
                    .font(ZBTheme.font(13, .medium))
                    .foregroundStyle(.white.opacity(0.55))
            }
        }
        .padding(.vertical, 28)
        .frame(maxWidth: .infinity)
        .dashboardCard(borderColor: .white.opacity(0.10))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [ZBTheme.violet.opacity(0.55), ZBTheme.cyan.opacity(0.45)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
        }
        .shadow(color: ZBTheme.violet.opacity(0.25), radius: 24, y: 8)
    }
}

// MARK: - Tuile de métrique

private struct MetricTile: View {
    let icon: String
    let tint: Color
    let value: String
    let label: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 38, height: 38)
                .background(tint.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(value)
                    .font(ZBTheme.font(24, .bold))
                    .foregroundStyle(.white)

                Text(label)
                    .font(ZBTheme.font(13, .semibold))
                    .foregroundStyle(.white.opacity(0.75))

                Text(detail)
                    .font(ZBTheme.font(12, .medium))
                    .foregroundStyle(.white.opacity(0.45))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .dashboardCard(cornerRadius: 20)
    }
}

// MARK: - Modal SOS : respiration 60 secondes

private struct SOSBreathingModal: View {
    @Environment(\.dismiss) private var dismiss

    @State private var secondsLeft = 60
    @State private var startDate = Date()

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    /// Cycle de respiration : 4 s d'inspiration, 4 s d'expiration.
    private func breathPhase(_ t: TimeInterval) -> (label: String, scale: CGFloat) {
        let cycle = t.truncatingRemainder(dividingBy: 8)
        let isInhale = cycle < 4
        // Progression douce 0 → 1 dans la demi-phase
        let progress = (cycle < 4 ? cycle : cycle - 4) / 4
        let eased = 0.5 - 0.5 * cos(progress * .pi)
        let scale = isInhale ? 0.72 + 0.28 * eased : 1.0 - 0.28 * eased
        return (isInhale ? "Inspire..." : "Expire...", scale)
    }

    var body: some View {
        ZStack {
            Color(red: 0x09 / 255, green: 0x09 / 255, blue: 0x0B / 255)
                .ignoresSafeArea()

            TimelineView(.animation(minimumInterval: 1.0 / 40.0)) { timeline in
                let t = timeline.date.timeIntervalSince(startDate)
                let phase = breathPhase(t)

                VStack(spacing: 40) {
                    VStack(spacing: 8) {
                        Text("Ancrage d'urgence")
                            .font(ZBTheme.font(24, .bold))
                            .foregroundStyle(.white)

                        Text("Respire avec le cercle. L'impulsion retombe en moins d'une minute.")
                            .font(ZBTheme.font(15, .medium))
                            .foregroundStyle(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding(.top, 60)

                    Spacer()

                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [ZBTheme.cyan.opacity(0.30), .clear],
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: 190
                                )
                            )
                            .frame(width: 340, height: 340)
                            .scaleEffect(phase.scale)

                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [ZBTheme.cyan, ZBTheme.violet],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2.5
                            )
                            .frame(width: 230, height: 230)
                            .scaleEffect(phase.scale)
                            .shadow(color: ZBTheme.cyan.opacity(0.4), radius: 24)

                        VStack(spacing: 8) {
                            Text(phase.label)
                                .font(ZBTheme.font(22, .semibold))
                                .foregroundStyle(.white)

                            Text("\(secondsLeft) s")
                                .font(ZBTheme.font(42, .bold))
                                .foregroundStyle(.white.opacity(0.85))
                                .monospacedDigit()
                        }
                    }

                    Spacer()

                    Button {
                        Haptics.tap()
                        dismiss()
                    } label: {
                        Text(secondsLeft == 0 ? "Je reprends le contrôle" : "Fermer")
                            .font(ZBTheme.font(16, .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background {
                                if secondsLeft == 0 {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: [ZBTheme.violet, ZBTheme.cyan],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                } else {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(.white.opacity(0.08))
                                }
                            }
                            .overlay {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .strokeBorder(.white.opacity(0.14), lineWidth: 1)
                            }
                    }
                    .buttonStyle(PressableButtonStyle())
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
        }
        .onAppear {
            startDate = Date()
        }
        .onReceive(timer) { _ in
            guard secondsLeft > 0 else { return }
            secondsLeft -= 1

            if secondsLeft % 4 == 0 {
                Haptics.tick()
            }
            if secondsLeft == 0 {
                Haptics.success()
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        DashboardHomeView()
    }
    .preferredColorScheme(.dark)
}
