//
//  EvolvingBackground.swift
//  zerobr
//
//  Created by Rayane Batil on 31/08/2026.
//

import SwiftUI

// MARK: - Phases du tunnel

enum OnboardingPhase: Equatable {
    /// Écrans 1-6 : découverte / diagnostic — brume violette sombre
    case discovery
    /// Écrans 7-12 : prise de conscience — indigo / bleu nuit pulsant
    case awareness
    /// Écrans 13-18 : motivation / déclic — lueurs ambrées + violet
    case motivation
    /// Écrans 19-20 : preview dashboard + paywall — onyx premium
    case premium

    var baseColors: [Color] {
        switch self {
        case .discovery:
            return [.black, .black, .black]
        case .awareness:
            return [.black, Color(red: 0x0F / 255, green: 0x17 / 255, blue: 0x2A / 255), Color(red: 0x1E / 255, green: 0x1B / 255, blue: 0x4B / 255)]
        case .motivation:
            return [.black, Color(red: 0x1C / 255, green: 0x0E / 255, blue: 0x2E / 255), Color(red: 0x24 / 255, green: 0x10 / 255, blue: 0x0A / 255)]
        case .premium:
            return [.black, Color(red: 0x0B / 255, green: 0x0B / 255, blue: 0x10 / 255), .black]
        }
    }

    var fogColors: [Color] {
        switch self {
        case .discovery:
            return [
                Color(red: 0x64 / 255, green: 0x07 / 255, blue: 0x38 / 255),
                Color(red: 0x28 / 255, green: 0x07 / 255, blue: 0x16 / 255),
                ZBTheme.pink.opacity(0.35)
            ]
        case .awareness:
            return [
                Color(red: 0x1E / 255, green: 0x1B / 255, blue: 0x4B / 255),
                ZBTheme.blue.opacity(0.45),
                Color(red: 0x31 / 255, green: 0x2E / 255, blue: 0x81 / 255)
            ]
        case .motivation:
            return [
                ZBTheme.amber.opacity(0.42),
                ZBTheme.violet.opacity(0.5),
                Color(red: 0x3B / 255, green: 0x07 / 255, blue: 0x64 / 255)
            ]
        case .premium:
            return [
                Color(red: 0x1A / 255, green: 0x1A / 255, blue: 0x22 / 255),
                ZBTheme.violet.opacity(0.16),
                Color(red: 0x12 / 255, green: 0x12 / 255, blue: 0x18 / 255)
            ]
        }
    }

    var fogOpacity: Double {
        switch self {
        case .discovery: return 0
        case .awareness: return 0.6
        case .motivation: return 0.6
        case .premium: return 0.32
        }
    }

    var pulseColor: Color? {
        switch self {
        case .discovery: return nil
        case .awareness: return ZBTheme.blue
        case .motivation: return ZBTheme.amber
        case .premium: return nil
        }
    }

    var particleColor: Color {
        switch self {
        case .discovery: return ZBTheme.pink
        case .awareness: return ZBTheme.blue
        case .motivation: return ZBTheme.amber
        case .premium: return .white
        }
    }

    var particleIntensity: Double {
        switch self {
        case .discovery: return 0.7
        case .awareness: return 0.85
        case .motivation: return 1.0
        case .premium: return 0.35
        }
    }
}

// MARK: - Fond évolutif

struct EvolvingBackground: View {
    let phase: OnboardingPhase

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: false)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate

            ZStack {
                LinearGradient(
                    colors: phase.baseColors,
                    startPoint: .top,
                    endPoint: .bottom
                )

                if phase.fogOpacity > 0 {
                    LiquidFogLayer(time: time, colors: phase.fogColors)
                        .opacity(phase.fogOpacity)
                }

                if phase == .discovery {
                    DiscoveryBackdrop(time: time)
                }

                if let pulseColor = phase.pulseColor {
                    PulseGlow(time: time, color: pulseColor)
                }

                if phase == .premium {
                    MetallicSheen(time: time)
                }

                ParticleField(
                    time: time,
                    color: phase.particleColor,
                    intensity: phase.particleIntensity
                )
            }
            .animation(.easeInOut(duration: 1.4), value: phase)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Décor phase découverte (voûte étoilée + horizon discret)

private struct DiscoveryBackdrop: View {
    let time: TimeInterval

    private func fract(_ value: Double) -> Double {
        value - floor(value)
    }

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height

            ZStack {
                // Champ d'étoiles fixes qui scintillent doucement
                Canvas { context, size in
                    for index in 0..<46 {
                        let fi = Double(index)
                        let x = fract(sin(fi * 91.17) * 4375.85) * size.width
                        let y = fract(sin(fi * 41.923) * 2531.21) * size.height
                        let seed = fract(sin(fi * 13.31) * 771.3)

                        let radius = 0.5 + 1.0 * seed
                        let twinkle = 0.5 + 0.5 * sin(time * (0.4 + 0.6 * seed) + fi * 3.1)
                        let alpha = 0.05 + 0.22 * twinkle

                        let rect = CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)
                        context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(alpha)))
                    }
                }
                .blendMode(.plusLighter)

                // Fin halo d'horizon rose, très discret, tout en bas
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [ZBTheme.pink.opacity(0.13), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: w * 0.8
                        )
                    )
                    .frame(width: w * 1.7, height: h * 0.42)
                    .position(x: w / 2, y: h * 1.12)
                    .blendMode(.plusLighter)

                // Vignette pour donner de la profondeur au noir
                RadialGradient(
                    colors: [.clear, .black.opacity(0.5)],
                    center: UnitPoint(x: 0.5, y: 0.42),
                    startRadius: h * 0.22,
                    endRadius: h * 0.85
                )
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Brume liquide

private struct LiquidFogLayer: View {
    let time: TimeInterval
    let colors: [Color]

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height

            ZStack {
                Ellipse()
                    .fill(colors[0])
                    .frame(width: w * 1.1, height: h * 0.5)
                    .position(
                        x: w * 0.3 + 40 * sin(time * 0.05),
                        y: h * 0.22 + 30 * cos(time * 0.041)
                    )

                Ellipse()
                    .fill(colors[1])
                    .frame(width: w * 0.9, height: h * 0.45)
                    .position(
                        x: w * 0.75 + 50 * sin(time * 0.037 + 2.1),
                        y: h * 0.55 + 36 * cos(time * 0.049 + 1.2)
                    )

                Ellipse()
                    .fill(colors[2])
                    .frame(width: w * 0.8, height: h * 0.4)
                    .position(
                        x: w * 0.45 + 44 * sin(time * 0.043 + 4.2),
                        y: h * 0.85 + 28 * cos(time * 0.035 + 3.0)
                    )
            }
            .blur(radius: 85)
            .blendMode(.plusLighter)
        }
    }
}

// MARK: - Pulsation lumineuse (derrière les cartes)

private struct PulseGlow: View {
    let time: TimeInterval
    let color: Color

    var body: some View {
        GeometryReader { proxy in
            let pulse = 0.5 + 0.5 * sin(time * 0.55)

            RadialGradient(
                colors: [color.opacity(0.10 + 0.10 * pulse), .clear],
                center: .center,
                startRadius: 20,
                endRadius: proxy.size.width * (0.55 + 0.06 * pulse)
            )
            .position(x: proxy.size.width / 2, y: proxy.size.height * 0.42)
            .frame(width: proxy.size.width, height: proxy.size.height)
            .blendMode(.plusLighter)
        }
    }
}

// MARK: - Reflet métallique (phase premium)

private struct MetallicSheen: View {
    let time: TimeInterval

    var body: some View {
        GeometryReader { proxy in
            let sweep = sin(time * 0.12)

            LinearGradient(
                colors: [.clear, .white.opacity(0.05), .clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(width: proxy.size.width * 0.9)
            .rotationEffect(.degrees(18))
            .offset(x: proxy.size.width * 0.6 * sweep)
            .blendMode(.plusLighter)
        }
    }
}

// MARK: - Particules lentes

private struct ParticleField: View {
    let time: TimeInterval
    let color: Color
    let intensity: Double

    private func fract(_ value: Double) -> Double {
        value - floor(value)
    }

    var body: some View {
        Canvas { context, size in
            for index in 0..<22 {
                let fi = Double(index)
                let seedX = fract(sin(fi * 12.9898) * 43758.5453)
                let seedY = fract(sin(fi * 78.233) * 12543.21)
                let seedR = fract(sin(fi * 7.77) * 111.13)
                let speed = 0.006 + 0.012 * fract(sin(fi * 3.71) * 999.7)

                let x = seedX * size.width + 10 * sin(time * 0.1 + fi * 1.7)
                let yFraction = fract(seedY + time * speed)
                let y = (1 - yFraction) * size.height

                let radius = 1.2 + 1.8 * seedR
                let twinkle = 0.5 + 0.5 * sin(time * 0.7 + fi * 2.3)
                let alpha = (0.10 + 0.20 * twinkle) * intensity

                let rect = CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)
                context.fill(Path(ellipseIn: rect), with: .color(color.opacity(alpha)))
            }
        }
        .blendMode(.plusLighter)
        .allowsHitTesting(false)
    }
}

#Preview("Phase 1 — Découverte") {
    EvolvingBackground(phase: .discovery)
}

#Preview("Phase 2 — Analyse") {
    EvolvingBackground(phase: .awareness)
}

#Preview("Phase 3 — Motivation") {
    EvolvingBackground(phase: .motivation)
}

#Preview("Phase 4 — Premium") {
    EvolvingBackground(phase: .premium)
}
