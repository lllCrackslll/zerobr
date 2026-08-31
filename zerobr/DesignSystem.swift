//
//  DesignSystem.swift
//  zerobr
//
//  Created by Rayane Batil on 31/08/2026.
//

import CoreText
import SwiftUI
import UIKit

// MARK: - Thème

enum ZBTheme {
    static let background = Color.black
    static let card = Color(red: 0x11 / 255, green: 0x11 / 255, blue: 0x16 / 255)
    static let cardBorder = Color(red: 0x22 / 255, green: 0x22 / 255, blue: 0x2E / 255)
    static let violet = Color(red: 0x7C / 255, green: 0x3A / 255, blue: 0xED / 255)
    static let blue = Color(red: 0x0E / 255, green: 0xA5 / 255, blue: 0xE9 / 255)
    static let amber = Color(red: 0xF5 / 255, green: 0x9E / 255, blue: 0x0B / 255)
    static let pink = Color(red: 0xEC / 255, green: 0x48 / 255, blue: 0x99 / 255)
    static let indigo = Color(red: 0x4F / 255, green: 0x46 / 255, blue: 0xE5 / 255)
    static let cyan = Color(red: 0x06 / 255, green: 0xB6 / 255, blue: 0xD4 / 255)
    static let flameOrange = Color(red: 0xF9 / 255, green: 0x73 / 255, blue: 0x16 / 255)
    static let textSecondary = Color.white.opacity(0.62)

    static let accentGradient = LinearGradient(
        colors: [violet, blue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let goldVioletGradient = LinearGradient(
        colors: [amber, violet],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: Police Inter Tight (enregistrée au lancement, fallback système)

    private static var fontsRegistered = false

    static func registerFontsIfNeeded() {
        guard !fontsRegistered else { return }
        fontsRegistered = true

        for name in ["InterTight-Regular", "InterTight-Medium", "InterTight-SemiBold", "InterTight-Bold"] {
            guard UIFont(name: name, size: 12) == nil,
                  let url = Bundle.main.url(forResource: name, withExtension: "ttf") else { continue }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }

    enum ZBWeight {
        case regular, medium, semibold, bold

        var postScriptName: String {
            switch self {
            case .regular: return "InterTight-Regular"
            case .medium: return "InterTight-Medium"
            case .semibold: return "InterTight-SemiBold"
            case .bold: return "InterTight-Bold"
            }
        }

        var systemWeight: Font.Weight {
            switch self {
            case .regular: return .regular
            case .medium: return .medium
            case .semibold: return .semibold
            case .bold: return .bold
            }
        }
    }

    static func font(_ size: CGFloat, _ weight: ZBWeight = .semibold) -> Font {
        registerFontsIfNeeded()
        if UIFont(name: weight.postScriptName, size: size) != nil {
            return .custom(weight.postScriptName, size: size)
        }
        return .system(size: size, weight: weight.systemWeight)
    }
}

// MARK: - Haptique

@MainActor
enum Haptics {
    private static let medium = UIImpactFeedbackGenerator(style: .medium)
    private static let light = UIImpactFeedbackGenerator(style: .light)
    private static let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private static let notification = UINotificationFeedbackGenerator()

    static func tap() {
        medium.impactOccurred()
    }

    static func heavy() {
        heavyGenerator.impactOccurred()
    }

    static func tick() {
        light.impactOccurred(intensity: 0.7)
    }

    static func success() {
        notification.notificationOccurred(.success)
    }
}

// MARK: - Carte Liquid Glass

struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 20
    var borderColor: Color = ZBTheme.cardBorder
    var borderWidth: CGFloat = 1

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(ZBTheme.card.opacity(0.82))
                    }
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(borderColor, lineWidth: borderWidth)
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

extension View {
    func glassCard(
        cornerRadius: CGFloat = 20,
        borderColor: Color = ZBTheme.cardBorder,
        borderWidth: CGFloat = 1
    ) -> some View {
        modifier(GlassCardModifier(
            cornerRadius: cornerRadius,
            borderColor: borderColor,
            borderWidth: borderWidth
        ))
    }
}

// MARK: - Boutons

struct PrimaryButton: View {
    let title: String
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            Text(title)
                .font(ZBTheme.font(17, .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(ZBTheme.accentGradient)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: ZBTheme.violet.opacity(0.45), radius: 14, y: 6)
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.4)
        .animation(.easeOut(duration: 0.2), value: isEnabled)
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.tick()
            action()
        } label: {
            Text(title)
                .font(ZBTheme.font(16, .medium))
                .foregroundStyle(ZBTheme.textSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
        }
        .buttonStyle(PressableButtonStyle())
    }
}

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
