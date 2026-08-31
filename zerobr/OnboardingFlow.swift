//
//  OnboardingFlow.swift
//  zerobr
//
//  Created by Rayane Batil on 31/08/2026.
//

import SwiftUI

// MARK: - Modèle du parcours

@Observable
@MainActor
final class OnboardingModel {
    static let totalSteps = 20

    private(set) var step = 1
    private(set) var isMovingForward = true
    private(set) var hasUnlocked = false

    var singleAnswers: [Int: String] = [:]
    var multiAnswers: [Int: Set<String>] = [:]
    var selectedPlan: PaywallPlan = .annual

    var progress: Double {
        Double(step) / Double(Self.totalSteps)
    }

    /// Phase visuelle du tunnel — pilote le fond animé évolutif.
    var phase: OnboardingPhase {
        switch step {
        case ...6: return .discovery
        case 7...12: return .awareness
        case 13...18: return .motivation
        default: return .premium
        }
    }

    /// Barre de progression + flèche retour visibles à partir de l'étape 3.
    /// Masquées sur le paywall final (hard paywall : pas de retour possible).
    var showsTopBar: Bool {
        step >= 3 && step < Self.totalSteps
    }

    func next() {
        guard step < Self.totalSteps else { return }
        isMovingForward = true
        withAnimation(.spring(duration: 0.45)) {
            step += 1
        }
    }

    func back() {
        guard step > 1 else { return }
        isMovingForward = false
        withAnimation(.spring(duration: 0.45)) {
            step -= 1
        }
    }

    /// Validé depuis le paywall : bascule vers le dashboard.
    func unlock() {
        withAnimation(.easeInOut(duration: 0.6)) {
            hasUnlocked = true
        }
    }

    func selectSingle(step stepIndex: Int, answer: String) {
        singleAnswers[stepIndex] = answer
    }

    func toggleMulti(step stepIndex: Int, answer: String) {
        var set = multiAnswers[stepIndex] ?? []
        if set.contains(answer) {
            set.remove(answer)
        } else {
            set.insert(answer)
        }
        multiAnswers[stepIndex] = set
    }
}

enum PaywallPlan {
    case annual
    case monthly
}

// MARK: - Conteneur principal

struct OnboardingFlow: View {
    @State private var model = OnboardingModel()

    var body: some View {
        ZStack {
            if model.hasUnlocked {
                DashboardView()
                    .transition(.opacity.combined(with: .scale(scale: 1.04)))
            } else {
                onboardingContent
                    .transition(.opacity)
            }
        }
        .environment(model)
        .preferredColorScheme(.dark)
    }

    private var onboardingContent: some View {
        ZStack(alignment: .top) {
            EvolvingBackground(phase: model.phase)

            currentStep
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, model.showsTopBar ? 64 : 0)
                .id(model.step)
                .transition(.asymmetric(
                    insertion: .move(edge: model.isMovingForward ? .trailing : .leading)
                        .combined(with: .opacity),
                    removal: .move(edge: model.isMovingForward ? .leading : .trailing)
                        .combined(with: .opacity)
                ))

            if model.showsTopBar {
                topBar
                    .transition(.opacity)
            }
        }
    }

    @ViewBuilder
    private var currentStep: some View {
        switch model.step {
        case 1: SplashStepView()
        case 2: WelcomeStepView()
        case 3:
            SingleQuizStepView(
                stepIndex: 3,
                title: "Combien de fois par semaine cèdes-tu à une pulsion ?",
                options: ["1 à 2 fois", "3 à 5 fois", "Tous les jours", "Plusieurs fois par jour"],
                feedbackText: "⚠️ Cette fréquence indique une habitude ancrée dans tes circuits dopaminergiques, pas un manque de force mentale."
            )
        case 4:
            SingleQuizStepView(
                stepIndex: 4,
                title: "À quel âge as-tu été exposé pour la première fois ?",
                options: ["< 12 ans", "12 - 15 ans", "16 - 19 ans", "20 ans et +"]
            )
        case 5: ImpactStatStepView()
        case 6:
            SingleQuizStepView(
                stepIndex: 6,
                title: "Combien de temps dure une session en moyenne ?",
                options: ["Moins de 15 min", "15 à 45 min", "45 min à 2h", "+ de 2 heures"],
                feedbackText: "⏳ Le cerveau s'habitue à l'escalade visuelle pour compenser la tolérance à la dopamine."
            )
        case 7: TimeLostStepView()
        case 8:
            MultiQuizStepView(
                stepIndex: 8,
                title: "Quels sont tes moments les plus vulnérables ?",
                subtitle: "Plusieurs réponses possibles",
                options: ["Tard le soir au lit", "Période de stress / fatigue", "Ennui et solitude", "Scroll sur les réseaux"],
                feedbackText: "💡 84 % des rechutes surviennent précisément dans ces moments de baisse de vigilance cognitive."
            )
        case 9:
            MultiQuizStepView(
                stepIndex: 9,
                title: "Qu'est-ce qui t'impacte le plus au quotidien ?",
                subtitle: "Plusieurs réponses possibles",
                options: ["Brouillard mental (Brain fog)", "Baisse de motivation", "Anxiété / Culpabilité", "Impact sur mes relations"]
            )
        case 10: AwarenessCarouselStepView()
        case 11: ProfileAnalysisStepView()
        case 12: NeuroscienceStepView()
        case 13:
            InterludeStepView(
                headline: "REPRENDS LES COMMANDES.",
                subline: "Tout ce que tu veux atteindre se trouve de l'autre côté de cette discipline.",
                gradient: ZBTheme.accentGradient
            )
        case 14:
            SingleQuizStepView(
                stepIndex: 14,
                title: "As-tu déjà essayé d'arrêter seul ?",
                options: ["Première tentative", "J'ai tenu quelques jours", "J'ai rechuté après plusieurs semaines"]
            )
        case 15:
            SingleQuizStepView(
                stepIndex: 15,
                title: "Quelle est ta priorité absolue ?",
                options: ["Retrouver une clarté mentale totale", "Reprendre confiance en moi", "Supprimer définitivement ce réflexe"]
            )
        case 16:
            InterludeStepView(
                headline: "LEVEL UP YOUR LIFE.",
                subline: "Ce n'est pas juste arrêter une habitude, c'est débloquer ta meilleure version.",
                gradient: ZBTheme.goldVioletGradient
            )
        case 17: ProfileLoaderStepView()
        case 18: CommitmentStepView()
        case 19: StreakPreviewStepView()
        default: PaywallStepView()
        }
    }

    private var topBar: some View {
        HStack(spacing: 16) {
            Button {
                Haptics.tick()
                model.back()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .glassCard(cornerRadius: 12)
            }
            .buttonStyle(PressableButtonStyle())

            ProgressBarView(progress: model.progress)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}

// MARK: - Barre de progression

struct ProgressBarView: View {
    let progress: Double

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.10))

                Capsule()
                    .fill(ZBTheme.accentGradient)
                    .frame(width: max(12, proxy.size.width * progress))
                    .animation(.spring(duration: 0.5), value: progress)
            }
        }
        .frame(height: 6)
    }
}

#Preview {
    OnboardingFlow()
}
