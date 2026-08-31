//
//  StepViews.swift
//  zerobr
//
//  Created by Rayane Batil on 31/08/2026.
//

import Combine
import SwiftUI

// MARK: - Étape 1 : Splash

struct SplashStepView: View {
    @Environment(OnboardingModel.self) private var model

    private let tagline = "La version de toi-même que tu deviens est déjà là."

    @State private var revealedCount = 0
    @State private var showHint = false
    @State private var appeared = false

    private let timer = Timer.publish(every: 0.045, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Emblème flamme animé
            TimelineView(.animation(minimumInterval: 1.0 / 40.0)) { timeline in
                let t = timeline.date.timeIntervalSinceReferenceDate

                ZStack {
                    Circle()
                        .stroke(ZBTheme.pink.opacity(0.22), lineWidth: 1)
                        .frame(width: 134, height: 134)
                        .scaleEffect(1 + 0.04 * sin(t * 1.5))

                    Circle()
                        .trim(from: 0, to: 0.32)
                        .stroke(
                            LinearGradient(
                                colors: [ZBTheme.pink, .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 2, lineCap: .round)
                        )
                        .frame(width: 116, height: 116)
                        .rotationEffect(.degrees(t * 42))

                    Image(systemName: "flame.fill")
                        .font(.system(size: 42, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [ZBTheme.pink, ZBTheme.violet],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .scaleEffect(1 + 0.045 * sin(t * 2.3))
                        .shadow(color: ZBTheme.pink.opacity(0.45), radius: 16)
                }
            }
            .frame(width: 150, height: 150)
            .padding(.bottom, 26)
            .scaleEffect(appeared ? 1 : 0.8)
            .opacity(appeared ? 1 : 0)

            Text("ZeroBR")
                .font(ZBTheme.font(56, .bold))
                .foregroundStyle(.white)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 14)

            ZStack(alignment: .top) {
                Text(tagline).hidden()
                Text(String(tagline.prefix(revealedCount)))
            }
            .font(ZBTheme.font(17, .medium))
            .foregroundStyle(ZBTheme.textSecondary)
            .multilineTextAlignment(.center)
            .lineSpacing(4)
            .padding(.horizontal, 40)
            .padding(.top, 18)

            Spacer()

            // Badges de réassurance
            HStack(spacing: 10) {
                SplashPill(icon: "lock.fill", label: "100 % anonyme")
                SplashPill(icon: "brain.head.profile", label: "Neurosciences")
                SplashPill(icon: "calendar", label: "90 jours")
            }
            .padding(.bottom, 26)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 16)

            Text("Touche l'écran pour continuer")
                .font(ZBTheme.font(13, .medium))
                .foregroundStyle(.white.opacity(0.35))
                .opacity(showHint ? 1 : 0)
                .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            Haptics.tap()
            model.next()
        }
        .onAppear {
            withAnimation(.spring(duration: 0.9, bounce: 0.25).delay(0.15)) {
                appeared = true
            }
        }
        .onReceive(timer) { _ in
            guard revealedCount < tagline.count else {
                if !showHint {
                    withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                        showHint = true
                    }
                }
                return
            }
            revealedCount += 1
        }
    }
}

private struct SplashPill: View {
    let icon: String
    let label: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(ZBTheme.pink)

            Text(label)
                .font(ZBTheme.font(12, .semibold))
                .foregroundStyle(.white.opacity(0.75))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.white.opacity(0.06))
        .clipShape(Capsule())
        .overlay {
            Capsule().stroke(.white.opacity(0.12), lineWidth: 1)
        }
    }
}

// MARK: - Étape 2 : Accueil

struct WelcomeStepView: View {
    @Environment(OnboardingModel.self) private var model

    var body: some View {
        VStack(spacing: 0) {
            Text("ZeroBR")
                .font(ZBTheme.font(24, .bold))
                .foregroundStyle(.white)
                .padding(.top, 24)

            Spacer()

            VStack(spacing: 16) {
                Text("Reprends le contrôle de ton attention.")
                    .font(ZBTheme.font(34, .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Un diagnostic de 2 minutes pour construire ton protocole personnalisé.")
                    .font(ZBTheme.font(16, .medium))
                    .foregroundStyle(ZBTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 28)

            Spacer()

            VStack(spacing: 8) {
                PrimaryButton(title: "Démarrer mon diagnostic") {
                    model.next()
                }

                SecondaryButton(title: "J'ai déjà un compte") {
                    model.next()
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }
}

// MARK: - Étape 5 : Statistique d'impact

struct ImpactStatStepView: View {
    @Environment(OnboardingModel.self) private var model

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(alignment: .leading, spacing: 20) {
                Text("IMPACT RÉEL")
                    .font(ZBTheme.font(12, .bold))
                    .tracking(1.5)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(ZBTheme.pink)
                    .clipShape(Capsule())

                Text("73 %")
                    .font(ZBTheme.font(64, .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [ZBTheme.pink, .white],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Text("des personnes exposées avant 15 ans subissent une perte d'énergie chronique.")
                    .font(ZBTheme.font(18, .semibold))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)

                Divider()
                    .overlay(.white.opacity(0.18))

                Text("Tu n'es pas brisé, ton cerveau est juste surstimulé.")
                    .font(ZBTheme.font(16, .medium))
                    .foregroundStyle(.white.opacity(0.72))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(28)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                ZBTheme.pink.opacity(0.32),
                                ZBTheme.violet.opacity(0.22),
                                Color.black.opacity(0.55)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [ZBTheme.pink.opacity(0.6), ZBTheme.violet.opacity(0.35)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            }
            .shadow(color: ZBTheme.pink.opacity(0.25), radius: 22, y: 6)
            .padding(.horizontal, 24)

            Spacer()

            PrimaryButton(title: "Continuer") {
                model.next()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }
}

// MARK: - Étape 7 : Calculateur de temps perdu

struct TimeLostStepView: View {
    @Environment(OnboardingModel.self) private var model

    @State private var startDate = Date()
    @State private var isDone = false

    private let targetHours = 180.0
    private let countDuration = 2.2

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 18) {
                Text("Tu perds environ")
                    .font(ZBTheme.font(18, .medium))
                    .foregroundStyle(ZBTheme.textSecondary)

                TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: isDone)) { timeline in
                    let elapsed = timeline.date.timeIntervalSince(startDate)
                    let t = min(1, elapsed / countDuration)
                    let eased = 1 - pow(1 - t, 3)
                    let hours = Int(targetHours * eased)

                    Text("\(hours) heures")
                        .font(ZBTheme.font(58, .bold))
                        .foregroundStyle(ZBTheme.accentGradient)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                }

                Text("par an")
                    .font(ZBTheme.font(18, .medium))
                    .foregroundStyle(ZBTheme.textSecondary)

                Text("C'est l'équivalent de 7,5 jours complets effacés de ton année.")
                    .font(ZBTheme.font(17, .semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 12)
                    .padding(.horizontal, 32)
                    .opacity(isDone ? 1 : 0)
                    .offset(y: isDone ? 0 : 12)
            }

            Spacer()

            PrimaryButton(title: "Continuer") {
                model.next()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            .opacity(isDone ? 1 : 0)
        }
        .onAppear {
            startDate = Date()
            Task {
                try? await Task.sleep(for: .seconds(countDuration + 0.15))
                withAnimation(.spring(duration: 0.6)) {
                    isDone = true
                }
            }
        }
    }
}

// MARK: - Étape 10 : Graphique neurosciences

struct NeuroscienceStepView: View {
    @Environment(OnboardingModel.self) private var model

    @State private var drawProgress: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            StepTitleView(
                title: "Ton cerveau peut se réparer.",
                subtitle: "Restauration des récepteurs de dopamine sur 90 jours"
            )

            VStack(alignment: .leading, spacing: 16) {
                chart
                    .frame(height: 220)

                HStack {
                    ForEach(["Jour 0", "Jour 30", "Jour 60", "Jour 90"], id: \.self) { label in
                        Text(label)
                            .font(ZBTheme.font(12, .medium))
                            .foregroundStyle(ZBTheme.textSecondary)
                        if label != "Jour 90" { Spacer() }
                    }
                }
            }
            .padding(20)
            .glassCard(cornerRadius: 24)

            Spacer()

            PrimaryButton(title: "Continuer") {
                model.next()
            }

            Text("ZeroBR est un protocole d'auto-discipline et ne remplace pas un accompagnement médical.")
                .font(ZBTheme.font(11, .regular))
                .foregroundStyle(.white.opacity(0.35))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 16)
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .onAppear {
            drawProgress = 0
            withAnimation(.easeInOut(duration: 1.4).delay(0.25)) {
                drawProgress = 1
            }
        }
    }

    private var chart: some View {
        ZStack {
            // Grille horizontale subtile
            VStack(spacing: 0) {
                ForEach(0..<4, id: \.self) { _ in
                    Divider().overlay(Color.white.opacity(0.06))
                    Spacer()
                }
                Divider().overlay(Color.white.opacity(0.06))
            }

            // Aire sous la courbe
            RecoveryCurveShape(closed: true)
                .fill(
                    LinearGradient(
                        colors: [ZBTheme.violet.opacity(0.35), ZBTheme.blue.opacity(0.02)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .opacity(Double(drawProgress))

            // Courbe
            RecoveryCurveShape(closed: false)
                .trim(from: 0, to: drawProgress)
                .stroke(
                    LinearGradient(
                        colors: [ZBTheme.violet, ZBTheme.blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 3.5, lineCap: .round)
                )
                .shadow(color: ZBTheme.violet.opacity(0.5), radius: 8)
        }
    }
}

/// Courbe de récupération : croissance logistique de ~15 % à ~98 %.
struct RecoveryCurveShape: Shape {
    var closed: Bool

    func path(in rect: CGRect) -> Path {
        let points: [CGPoint] = [
            CGPoint(x: 0.00, y: 0.85),
            CGPoint(x: 0.22, y: 0.72),
            CGPoint(x: 0.50, y: 0.42),
            CGPoint(x: 0.75, y: 0.16),
            CGPoint(x: 1.00, y: 0.05)
        ].map { CGPoint(x: rect.minX + $0.x * rect.width, y: rect.minY + $0.y * rect.height) }

        var path = Path()
        path.move(to: points[0])

        for index in 1..<points.count {
            let previous = points[index - 1]
            let current = points[index]
            let controlX = (previous.x + current.x) / 2
            path.addCurve(
                to: current,
                control1: CGPoint(x: controlX, y: previous.y),
                control2: CGPoint(x: controlX, y: current.y)
            )
        }

        if closed {
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
        }

        return path
    }
}

// MARK: - Étape 13 : Génération du profil

struct ProfileLoaderStepView: View {
    @Environment(OnboardingModel.self) private var model

    @State private var progress: Double = 0
    @State private var hasFinished = false

    private let messages = [
        "Analyse de tes déclencheurs...",
        "Création de ton plan de réinitialisation...",
        "Protocole 90 jours prêt."
    ]

    private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    private var messageIndex: Int {
        if progress < 0.38 { return 0 }
        if progress < 0.78 { return 1 }
        return 2
    }

    var body: some View {
        VStack(spacing: 44) {
            Spacer()

            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: 10)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        ZBTheme.accentGradient,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .shadow(color: ZBTheme.violet.opacity(0.5), radius: 10)

                Text("\(Int(progress * 100)) %")
                    .font(ZBTheme.font(40, .bold))
                    .foregroundStyle(.white)
                    .monospacedDigit()
            }
            .frame(width: 180, height: 180)

            Text(messages[messageIndex])
                .font(ZBTheme.font(17, .semibold))
                .foregroundStyle(ZBTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .id(messageIndex)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .animation(.easeOut(duration: 0.35), value: messageIndex)

            Spacer()
            Spacer()
        }
        .onReceive(timer) { _ in
            guard !hasFinished else { return }

            progress = min(1, progress + 0.011)

            if progress >= 1 {
                hasFinished = true
                Haptics.success()
                Task {
                    try? await Task.sleep(for: .milliseconds(650))
                    model.next()
                }
            }
        }
    }
}

// MARK: - Étape 14 : Pacte d'engagement

struct CommitmentStepView: View {
    @Environment(OnboardingModel.self) private var model

    @State private var holdProgress: Double = 0
    @State private var isPressing = false
    @State private var hasCompleted = false
    @State private var tickCounter = 0

    private let holdDuration = 2.0
    private let timer = Timer.publish(every: 1.0 / 30.0, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                StepTitleView(title: "Scelle ton engagement.")

                Text("À partir d'aujourd'hui, je choisis de reprendre le contrôle de mon attention, de mon énergie et de mon temps. Chaque jour compte.")
                    .font(ZBTheme.font(16, .medium))
                    .foregroundStyle(ZBTheme.textSecondary)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            Spacer()

            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: 8)

                Circle()
                    .trim(from: 0, to: holdProgress)
                    .stroke(
                        ZBTheme.accentGradient,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .shadow(color: ZBTheme.violet.opacity(0.6), radius: 12)

                Circle()
                    .fill(ZBTheme.card)
                    .overlay {
                        Circle().stroke(ZBTheme.cardBorder, lineWidth: 1)
                    }
                    .padding(18)
                    .scaleEffect(isPressing ? 0.94 : 1)

                VStack(spacing: 6) {
                    Image(systemName: hasCompleted ? "checkmark" : "hand.raised.fill")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(hasCompleted ? ZBTheme.blue : ZBTheme.violet)

                    Text(hasCompleted ? "Engagement scellé" : "Maintiens appuyé\n2 secondes")
                        .font(ZBTheme.font(14, .semibold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(width: 210, height: 210)
            .animation(.easeOut(duration: 0.2), value: isPressing)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressing && !hasCompleted {
                            isPressing = true
                            Haptics.tap()
                        }
                    }
                    .onEnded { _ in
                        isPressing = false
                    }
            )

            Spacer()
            Spacer()
        }
        .onReceive(timer) { _ in
            guard !hasCompleted else { return }

            if isPressing {
                holdProgress = min(1, holdProgress + 1.0 / (30.0 * holdDuration))

                tickCounter += 1
                if tickCounter % 4 == 0 {
                    Haptics.tick()
                }

                if holdProgress >= 1 {
                    hasCompleted = true
                    isPressing = false
                    Haptics.success()
                    Task {
                        try? await Task.sleep(for: .milliseconds(700))
                        model.next()
                    }
                }
            } else if holdProgress > 0 {
                holdProgress = max(0, holdProgress - 0.06)
            }
        }
    }
}
