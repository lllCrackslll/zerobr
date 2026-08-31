//
//  QuizComponents.swift
//  zerobr
//
//  Created by Rayane Batil on 31/08/2026.
//

import SwiftUI

// MARK: - En-tête d'étape

struct StepTitleView: View {
    let title: String
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(ZBTheme.font(28, .bold))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)

            if let subtitle {
                Text(subtitle)
                    .font(ZBTheme.font(15, .medium))
                    .foregroundStyle(ZBTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Carte sélectionnable

struct SelectableCard: View {
    let label: String
    let isSelected: Bool
    var showsCheckbox = false
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            HStack(spacing: 14) {
                Text(label)
                    .font(ZBTheme.font(16, .semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)

                if showsCheckbox {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(isSelected ? ZBTheme.violet : Color.white.opacity(0.25))
                } else if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(ZBTheme.violet)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassCard(
                cornerRadius: 16,
                borderColor: isSelected ? ZBTheme.violet : ZBTheme.cardBorder,
                borderWidth: isSelected ? 1.5 : 1
            )
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(ZBTheme.violet.opacity(0.10))
                        .allowsHitTesting(false)
                }
            }
            .shadow(color: isSelected ? ZBTheme.violet.opacity(0.35) : .clear, radius: 12, y: 4)
        }
        .buttonStyle(PressableButtonStyle())
        .animation(.easeOut(duration: 0.18), value: isSelected)
    }
}

// MARK: - Encart de feedback contextuel

struct FeedbackBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(ZBTheme.font(14, .medium))
            .foregroundStyle(.white.opacity(0.88))
            .lineSpacing(3)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassCard(cornerRadius: 14, borderColor: ZBTheme.violet.opacity(0.55))
            .overlay(alignment: .leading) {
                UnevenRoundedRectangle(
                    topLeadingRadius: 14,
                    bottomLeadingRadius: 14,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 0
                )
                .fill(ZBTheme.accentGradient)
                .frame(width: 3)
            }
            .transition(.asymmetric(
                insertion: .move(edge: .bottom).combined(with: .opacity).combined(with: .scale(scale: 0.96)),
                removal: .opacity
            ))
    }
}

// MARK: - Quiz à sélection unique (avance automatiquement)

struct SingleQuizStepView: View {
    @Environment(OnboardingModel.self) private var model

    let stepIndex: Int
    let title: String
    let options: [String]
    var feedbackText: String?

    @State private var isAdvancing = false
    @State private var showFeedback = false

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            StepTitleView(title: title)

            VStack(spacing: 12) {
                ForEach(options, id: \.self) { option in
                    SelectableCard(
                        label: option,
                        isSelected: model.singleAnswers[stepIndex] == option
                    ) {
                        guard !isAdvancing else { return }
                        isAdvancing = true
                        model.selectSingle(step: stepIndex, answer: option)

                        if feedbackText != nil {
                            withAnimation(.spring(duration: 0.45)) {
                                showFeedback = true
                            }
                            Haptics.tick()
                        }

                        Task {
                            let delay: Duration = feedbackText == nil
                                ? .milliseconds(380)
                                : .milliseconds(1500)
                            try? await Task.sleep(for: delay)
                            model.next()
                            isAdvancing = false
                        }
                    }
                }
            }

            if let feedbackText, showFeedback {
                FeedbackBadge(text: feedbackText)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }
}

// MARK: - Quiz à sélection multiple (bouton Continuer)

struct MultiQuizStepView: View {
    @Environment(OnboardingModel.self) private var model

    let stepIndex: Int
    let title: String
    var subtitle: String?
    let options: [String]
    var feedbackText: String?

    private var selection: Set<String> {
        model.multiAnswers[stepIndex] ?? []
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            StepTitleView(title: title, subtitle: subtitle)

            VStack(spacing: 12) {
                ForEach(options, id: \.self) { option in
                    SelectableCard(
                        label: option,
                        isSelected: selection.contains(option),
                        showsCheckbox: true
                    ) {
                        model.toggleMulti(step: stepIndex, answer: option)
                    }
                }
            }

            if let feedbackText, !selection.isEmpty {
                FeedbackBadge(text: feedbackText)
            }

            Spacer()

            PrimaryButton(title: "Continuer", isEnabled: !selection.isEmpty) {
                model.next()
            }
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .animation(.spring(duration: 0.45), value: selection.isEmpty)
    }
}
