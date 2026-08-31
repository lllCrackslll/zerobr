//
//  InsightStepViews.swift
//  zerobr
//
//  Created by Rayane Batil on 31/08/2026.
//

import SwiftUI

// MARK: - Écran 11 : Analyse comparative du profil

struct ProfileAnalysisStepView: View {
    @Environment(OnboardingModel.self) private var model

    @State private var barsAppeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            StepTitleView(
                title: "Ton profil comparatif.",
                subtitle: "Basé sur tes réponses au diagnostic"
            )

            VStack(spacing: 20) {
                MetricBarRow(
                    label: "Tolérance Dopaminergique",
                    value: 0.78,
                    display: "78 %",
                    note: "Élevé • Moyenne nationale : 45 %",
                    color: ZBTheme.violet,
                    averageMarker: 0.45,
                    appeared: barsAppeared,
                    delay: 0.15
                )

                MetricBarRow(
                    label: "Risque de rechute sous stress",
                    value: 0.82,
                    display: "82 %",
                    note: "Critique",
                    color: ZBTheme.amber,
                    averageMarker: nil,
                    appeared: barsAppeared,
                    delay: 0.45
                )

                MetricBarRow(
                    label: "Potentiel de récupération cognitive",
                    value: 0.94,
                    display: "94 %",
                    note: "Excellent avec le protocole 90 jours",
                    color: ZBTheme.blue,
                    averageMarker: nil,
                    appeared: barsAppeared,
                    delay: 0.75
                )
            }
            .padding(20)
            .glassCard(cornerRadius: 24)

            Text("Tes réponses révèlent un niveau de dépendance comportementale supérieur à la moyenne des hommes de ta tranche d'âge. Mais ta réceptivité à une détox guidée est maximale.")
                .font(ZBTheme.font(15, .medium))
                .foregroundStyle(ZBTheme.textSecondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
                .padding(16)
                .glassCard(cornerRadius: 16)

            Spacer()

            PrimaryButton(title: "Continuer") {
                model.next()
            }
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .onAppear {
            barsAppeared = false
            Task {
                try? await Task.sleep(for: .milliseconds(250))
                barsAppeared = true
            }
        }
    }
}

private struct MetricBarRow: View {
    let label: String
    let value: Double
    let display: String
    let note: String
    let color: Color
    let averageMarker: Double?
    let appeared: Bool
    let delay: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(ZBTheme.font(14, .semibold))
                    .foregroundStyle(.white)

                Spacer()

                Text(display)
                    .font(ZBTheme.font(15, .bold))
                    .foregroundStyle(color)
                    .monospacedDigit()
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.08))

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.7), color],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: appeared ? proxy.size.width * value : 0)
                        .shadow(color: color.opacity(0.5), radius: 6)
                        .animation(.spring(duration: 0.9).delay(delay), value: appeared)

                    if let averageMarker {
                        Rectangle()
                            .fill(Color.white.opacity(0.6))
                            .frame(width: 2, height: 16)
                            .position(x: proxy.size.width * averageMarker, y: 5)
                    }
                }
            }
            .frame(height: 10)

            Text(note)
                .font(ZBTheme.font(12, .medium))
                .foregroundStyle(ZBTheme.textSecondary)
        }
    }
}

// MARK: - Écran 10 : Carrousel de sensibilisation

struct AwarenessCarouselStepView: View {
    @Environment(OnboardingModel.self) private var model

    @State private var page = 0

    private enum IconMotion {
        case pulse
        case heartbeat
        case drift
        case sparkle
    }

    private struct Slide {
        let icon: String
        let tint: Color
        let motion: IconMotion
        let title: String
        let text: String
    }

    private let slides: [Slide] = [
        Slide(
            icon: "brain.head.profile",
            tint: ZBTheme.violet,
            motion: .pulse,
            title: "Une drogue invisible",
            text: "La surstimulation numérique active les mêmes zones de récompense que certaines substances addictives en épuisant tes récepteurs D2."
        ),
        Slide(
            icon: "heart.slash.fill",
            tint: ZBTheme.pink,
            motion: .heartbeat,
            title: "L'impact sur tes relations",
            text: "Elle déforme la perception du plaisir réel, crée de l'anxiété de performance et installe une distance émotionnelle invisible."
        ),
        Slide(
            icon: "cloud.fog.fill",
            tint: ZBTheme.blue,
            motion: .drift,
            title: "Le voleur de vitalité",
            text: "Le fameux « brouillard mental » du lendemain et la procrastination ne sont que la conséquence directe du crash dopaminergique."
        ),
        Slide(
            icon: "sparkles",
            tint: ZBTheme.amber,
            motion: .sparkle,
            title: "Un sevrage complet est possible",
            text: "Grâce à la neuroplasticité, 90 jours de protocole suffisent pour réinitialiser totalement ta sensibilité au monde réel."
        )
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            StepTitleView(
                title: "Ce que la science révèle.",
                subtitle: "Fais défiler pour comprendre l'enjeu"
            )
            .padding(.horizontal, 24)

            TabView(selection: $page) {
                ForEach(Array(slides.enumerated()), id: \.offset) { index, slide in
                    SlideCard(slide: slide)
                        .padding(.horizontal, 24)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onChange(of: page) {
                Haptics.tick()
            }

            HStack(spacing: 8) {
                ForEach(slides.indices, id: \.self) { index in
                    Capsule()
                        .fill(index == page ? slides[page].tint : Color.white.opacity(0.18))
                        .frame(width: index == page ? 22 : 7, height: 7)
                        .animation(.spring(duration: 0.35), value: page)
                }
            }
            .frame(maxWidth: .infinity)

            PrimaryButton(title: page == slides.count - 1 ? "Continuer" : "J'ai compris, continuer") {
                model.next()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .padding(.top, 16)
    }

    private struct SlideCard: View {
        let slide: Slide

        var body: some View {
            VStack(spacing: 22) {
                AnimatedSlideIcon(icon: slide.icon, tint: slide.tint, motion: slide.motion)
                    .frame(width: 108, height: 108)
                    .background {
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(Color.black.opacity(0.35))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .strokeBorder(slide.tint.opacity(0.5), lineWidth: 1)
                    }
                    .shadow(color: slide.tint.opacity(0.4), radius: 18)
                    .frame(maxWidth: .infinity)

                Text(slide.title)
                    .font(ZBTheme.font(23, .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(slide.text)
                    .font(ZBTheme.font(15, .medium))
                    .foregroundStyle(.white.opacity(0.72))
                    .lineSpacing(5)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)
            }
            .padding(26)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                slide.tint.opacity(0.38),
                                slide.tint.opacity(0.14),
                                Color.black.opacity(0.55)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .strokeBorder(slide.tint.opacity(0.45), lineWidth: 1.2)
            }
            .padding(.vertical, 8)
        }
    }

    // MARK: Icône animée par slide

    private struct AnimatedSlideIcon: View {
        let icon: String
        let tint: Color
        let motion: IconMotion

        var body: some View {
            TimelineView(.animation(minimumInterval: 1.0 / 40.0)) { timeline in
                let t = timeline.date.timeIntervalSinceReferenceDate

                ZStack {
                    switch motion {
                    case .pulse:
                        // Halo dopaminergique qui respire derrière le cerveau
                        Circle()
                            .fill(tint.opacity(0.25 + 0.15 * sin(t * 2.2)))
                            .frame(width: 74 + 10 * sin(t * 2.2), height: 74 + 10 * sin(t * 2.2))
                            .blur(radius: 16)

                        Image(systemName: icon)
                            .font(.system(size: 48, weight: .semibold))
                            .foregroundStyle(tint)
                            .scaleEffect(1 + 0.05 * sin(t * 2.2))

                    case .heartbeat:
                        // Double battement cardiaque
                        let beat = pow(max(0, sin(t * 3.4)), 6) + 0.5 * pow(max(0, sin(t * 3.4 + 0.6)), 6)

                        Image(systemName: icon)
                            .font(.system(size: 48, weight: .semibold))
                            .foregroundStyle(tint)
                            .scaleEffect(1 + 0.14 * beat)
                            .shadow(color: tint.opacity(0.3 + 0.5 * beat), radius: 14)

                    case .drift:
                        // Nappes de brouillard qui dérivent
                        Image(systemName: icon)
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundStyle(tint.opacity(0.35))
                            .offset(x: 18 * sin(t * 0.7 + 2), y: -22)
                            .blur(radius: 2)

                        Image(systemName: icon)
                            .font(.system(size: 48, weight: .semibold))
                            .foregroundStyle(tint)
                            .offset(x: 10 * sin(t * 0.55))

                    case .sparkle:
                        // Étoiles qui scintillent et orbitent
                        ForEach(0..<3, id: \.self) { index in
                            let angle = t * 0.8 + Double(index) * 2.1
                            Image(systemName: "sparkle")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(tint.opacity(0.5 + 0.5 * sin(t * 3 + Double(index) * 2)))
                                .offset(x: 38 * cos(angle), y: 34 * sin(angle))
                        }

                        Image(systemName: icon)
                            .font(.system(size: 48, weight: .semibold))
                            .foregroundStyle(tint)
                            .scaleEffect(1 + 0.06 * sin(t * 2.6))
                            .rotationEffect(.degrees(6 * sin(t * 0.9)))
                    }
                }
            }
        }
    }
}

// MARK: - Écrans 13 & 16 : Intermèdes motivationnels

struct InterludeStepView: View {
    @Environment(OnboardingModel.self) private var model

    let headline: String
    let subline: String
    let gradient: LinearGradient

    @State private var appeared = false
    @State private var showHint = false

    var body: some View {
        VStack(spacing: 26) {
            Spacer()

            Text(headline)
                .font(ZBTheme.font(46, .bold))
                .foregroundStyle(gradient)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .scaleEffect(appeared ? 1 : 0.72)
                .opacity(appeared ? 1 : 0)
                .blur(radius: appeared ? 0 : 8)

            Text(subline)
                .font(ZBTheme.font(17, .medium))
                .foregroundStyle(.white.opacity(0.75))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 18)

            Spacer()

            Text("Touche l'écran pour continuer")
                .font(ZBTheme.font(13, .medium))
                .foregroundStyle(.white.opacity(0.35))
                .opacity(showHint ? 1 : 0)
                .padding(.bottom, 40)
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            Haptics.tap()
            model.next()
        }
        .onAppear {
            Haptics.success()
            withAnimation(.spring(duration: 0.65, bounce: 0.35)) {
                appeared = true
            }
            Task {
                try? await Task.sleep(for: .milliseconds(1200))
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    showHint = true
                }
            }
        }
    }
}

// MARK: - Écran 19 : Prévisualisation du Streak

struct StreakPreviewStepView: View {
    @Environment(OnboardingModel.self) private var model

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            StepTitleView(
                title: "Ton tableau de bord t'attend.",
                subtitle: "Aperçu de ton compteur de sobriété"
            )
            .padding(.horizontal, 24)
            .padding(.top, 16)

            Spacer()

            VStack(spacing: 18) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.18), lineWidth: 7)

                    Circle()
                        .trim(from: 0, to: appeared ? 0.03 : 0)
                        .stroke(
                            ZBTheme.amber,
                            style: StrokeStyle(lineWidth: 7, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))

                    Image(systemName: "flame.fill")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(ZBTheme.amber)
                        .shadow(color: ZBTheme.amber.opacity(0.6), radius: 12)
                }
                .frame(width: 92, height: 92)

                VStack(spacing: 2) {
                    Text("0")
                        .font(ZBTheme.font(76, .bold))
                        .foregroundStyle(.white)
                        .monospacedDigit()
                        .scaleEffect(appeared ? 1 : 0.6)

                    Text("JOURS")
                        .font(ZBTheme.font(15, .bold))
                        .tracking(4)
                        .foregroundStyle(ZBTheme.textSecondary)
                }

                Text("Jour 1 • Début du protocole")
                    .font(ZBTheme.font(13, .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(.white.opacity(0.16))
                    .clipShape(Capsule())
                    .overlay {
                        Capsule().stroke(.white.opacity(0.25), lineWidth: 1)
                    }
            }
            .padding(.vertical, 36)
            .padding(.horizontal, 44)
            .background {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                ZBTheme.violet,
                                Color(red: 0x4C / 255, green: 0x1D / 255, blue: 0x95 / 255),
                                ZBTheme.blue.opacity(0.85)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .fill(
                                RadialGradient(
                                    colors: [.white.opacity(0.14), .clear],
                                    center: .topLeading,
                                    startRadius: 0,
                                    endRadius: 260
                                )
                            )
                    }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .strokeBorder(ZBTheme.accentGradient, lineWidth: 1.5)
            }
            .shadow(color: ZBTheme.violet.opacity(0.55), radius: 26, y: 8)
            .scaleEffect(appeared ? 1 : 0.92)
            .opacity(appeared ? 1 : 0)

            Text("Voici ta flamme. À partir d'aujourd'hui, nous comptons chaque victoire.")
                .font(ZBTheme.font(16, .medium))
                .foregroundStyle(ZBTheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 44)
                .padding(.top, 28)

            Spacer()

            PrimaryButton(title: "Voir mon protocole") {
                model.next()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .onAppear {
            appeared = false
            withAnimation(.spring(duration: 0.7, bounce: 0.3).delay(0.15)) {
                appeared = true
            }
        }
    }
}
