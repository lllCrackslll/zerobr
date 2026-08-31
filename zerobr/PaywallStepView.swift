//
//  PaywallStepView.swift
//  zerobr
//
//  Created by Rayane Batil on 31/08/2026.
//

import SwiftUI

// MARK: - Étape 15 : Hard Paywall

struct PaywallStepView: View {
    @Environment(OnboardingModel.self) private var model

    @State private var didConfirm = false
    @State private var burstDate: Date?

    private var ctaTitle: String {
        model.selectedPlan == .annual
            ? "Déverrouiller mon accès (7 jours gratuits)"
            : "Déverrouiller mon accès"
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    Text("Ton Protocole 90 Jours est calibré.")
                        .font(ZBTheme.font(30, .bold))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 28)

                    VStack(spacing: 12) {
                        PaywallFeatureRow(
                            icon: "light.beacon.max.fill",
                            text: "Bouton d'urgence miroir activé"
                        )
                        PaywallFeatureRow(
                            icon: "book.closed.fill",
                            text: "Journal des déclencheurs"
                        )
                        PaywallFeatureRow(
                            icon: "brain.head.profile",
                            text: "Coach IA 24/7"
                        )
                    }

                    VStack(spacing: 14) {
                        PlanCard(
                            plan: .annual,
                            title: "Abonnement Annuel",
                            price: "59,99 €/an",
                            detail: "soit 4,99 €/mois",
                            trialBadge: "7 JOURS D'ESSAI GRATUIT",
                            popularBadge: "POPULAIRE",
                            isSelected: model.selectedPlan == .annual
                        ) {
                            model.selectedPlan = .annual
                        }

                        PlanCard(
                            plan: .monthly,
                            title: "Abonnement Mensuel",
                            price: "12,99 €/mois",
                            detail: "sans essai",
                            trialBadge: nil,
                            popularBadge: nil,
                            isSelected: model.selectedPlan == .monthly
                        ) {
                            model.selectedPlan = .monthly
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }

            VStack(spacing: 12) {
                Button {
                    guard !didConfirm else { return }
                    Haptics.success()
                    withAnimation(.spring(duration: 0.4)) {
                        didConfirm = true
                    }
                    burstDate = Date()
                    Task {
                        try? await Task.sleep(for: .milliseconds(1400))
                        model.unlock()
                    }
                } label: {
                    HStack(spacing: 10) {
                        if didConfirm {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20, weight: .bold))
                        }
                        Text(didConfirm ? "Accès déverrouillé" : ctaTitle)
                            .font(ZBTheme.font(17, .bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(ZBTheme.accentGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: ZBTheme.violet.opacity(0.5), radius: 16, y: 6)
                }
                .buttonStyle(PressableButtonStyle())

                Text("Sans engagement • Annulable en 1 clic dans l'App Store • Aucune mention explicite sur ton relevé bancaire")
                    .font(ZBTheme.font(11, .regular))
                    .foregroundStyle(.white.opacity(0.4))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 16)
            .background {
                Rectangle()
                    .fill(ZBTheme.background)
                    .shadow(color: .black.opacity(0.6), radius: 18, y: -10)
                    .ignoresSafeArea()
            }
        }
        .overlay {
            if let burstDate {
                NeonConfettiBurst(startDate: burstDate)
            }
        }
    }
}

// MARK: - Explosion de confettis néon

private struct NeonConfettiBurst: View {
    let startDate: Date

    private static let palette: [Color] = [
        ZBTheme.violet, ZBTheme.cyan, ZBTheme.pink, ZBTheme.flameOrange, .white
    ]

    private func fract(_ value: Double) -> Double {
        value - floor(value)
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { timeline in
            let t = timeline.date.timeIntervalSince(startDate)

            Canvas { context, size in
                guard t > 0, t < 1.6 else { return }

                let origin = CGPoint(x: size.width / 2, y: size.height * 0.72)
                let progress = min(1, t / 1.6)
                let eased = 1 - pow(1 - progress, 2.4)

                for index in 0..<90 {
                    let fi = Double(index)
                    let angle = fract(sin(fi * 12.9898) * 43758.5453) * 2 * .pi
                    let speed = 180 + 320 * fract(sin(fi * 78.233) * 12543.21)
                    let colorIndex = index % Self.palette.count

                    let x = origin.x + cos(angle) * speed * eased
                    let y = origin.y + sin(angle) * speed * eased + 190 * progress * progress

                    let radius = 2.0 + 3.0 * fract(sin(fi * 7.77) * 111.13)
                    let alpha = (1 - progress) * 0.95

                    let rect = CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)
                    context.fill(
                        Path(ellipseIn: rect),
                        with: .color(Self.palette[colorIndex].opacity(alpha))
                    )
                }
            }
            .blendMode(.plusLighter)
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}

// MARK: - Ligne de fonctionnalité

private struct PaywallFeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(ZBTheme.accentGradient)
                .frame(width: 40, height: 40)
                .glassCard(cornerRadius: 12)

            Text(text)
                .font(ZBTheme.font(16, .semibold))
                .foregroundStyle(.white)

            Spacer(minLength: 0)

            Image(systemName: "checkmark")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(ZBTheme.blue)
        }
    }
}

// MARK: - Carte d'offre

private struct PlanCard: View {
    let plan: PaywallPlan
    let title: String
    let price: String
    let detail: String
    let trialBadge: String?
    let popularBadge: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(title)
                        .font(ZBTheme.font(15, .semibold))
                        .foregroundStyle(ZBTheme.textSecondary)

                    Spacer()

                    Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(isSelected ? ZBTheme.violet : Color.white.opacity(0.25))
                }

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(price)
                        .font(ZBTheme.font(24, .bold))
                        .foregroundStyle(.white)

                    Text(detail)
                        .font(ZBTheme.font(14, .medium))
                        .foregroundStyle(ZBTheme.textSecondary)
                }

                if let trialBadge {
                    Text(trialBadge)
                        .font(ZBTheme.font(11, .bold))
                        .tracking(0.6)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(ZBTheme.blue)
                        .clipShape(Capsule())
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassCard(
                cornerRadius: 18,
                borderColor: isSelected ? .clear : ZBTheme.cardBorder,
                borderWidth: 1
            )
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(ZBTheme.accentGradient, lineWidth: 1.6)
                }
            }
            .shadow(color: isSelected ? ZBTheme.violet.opacity(0.35) : .clear, radius: 14, y: 4)
            .overlay(alignment: .topTrailing) {
                if let popularBadge {
                    Text(popularBadge)
                        .font(ZBTheme.font(11, .bold))
                        .tracking(1)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(ZBTheme.violet)
                        .clipShape(Capsule())
                        .offset(x: -14, y: -12)
                }
            }
        }
        .buttonStyle(PressableButtonStyle())
        .animation(.easeOut(duration: 0.18), value: isSelected)
    }
}
