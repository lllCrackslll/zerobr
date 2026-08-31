//
//  DashboardView.swift
//  zerobr
//
//  Created by Rayane Batil on 31/08/2026.
//

import SwiftUI

// MARK: - Onglets

enum DashboardTab: CaseIterable {
    case home
    case circle
    case profile

    var icon: String {
        switch self {
        case .home: return "flame.fill"
        case .circle: return "trophy.fill"
        case .profile: return "person.fill"
        }
    }

    var label: String {
        switch self {
        case .home: return "Accueil"
        case .circle: return "Cercle"
        case .profile: return "Profil"
        }
    }

    var tint: Color {
        switch self {
        case .home: return ZBTheme.flameOrange
        case .circle: return ZBTheme.cyan
        case .profile: return ZBTheme.violet
        }
    }
}

// MARK: - Racine du dashboard

struct DashboardView: View {
    @State private var tab: DashboardTab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            DashboardBackground()

            Group {
                switch tab {
                case .home: DashboardHomeView()
                case .circle: DashboardCircleView()
                case .profile: DashboardProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .id(tab)
            .transition(.opacity)

            FloatingTabBar(selection: $tab)
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Fond noir profond + halos ambiants discrets

private struct DashboardBackground: View {
    var body: some View {
        ZStack {
            Color(red: 0x09 / 255, green: 0x09 / 255, blue: 0x0B / 255)

            GeometryReader { proxy in
                let w = proxy.size.width
                let h = proxy.size.height

                ZStack {
                    Ellipse()
                        .fill(ZBTheme.violet.opacity(0.10))
                        .frame(width: w * 1.2, height: h * 0.4)
                        .position(x: w * 0.2, y: -h * 0.05)
                        .blur(radius: 90)

                    Ellipse()
                        .fill(ZBTheme.cyan.opacity(0.06))
                        .frame(width: w, height: h * 0.35)
                        .position(x: w * 0.9, y: h * 1.02)
                        .blur(radius: 90)
                }
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Barre de navigation flottante Liquid Glass

private struct FloatingTabBar: View {
    @Binding var selection: DashboardTab

    var body: some View {
        HStack(spacing: 4) {
            ForEach(DashboardTab.allCases, id: \.self) { tab in
                tabButton(tab)
            }
        }
        .padding(4)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.black.opacity(0.45))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(.white.opacity(0.15), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.55), radius: 16, y: 6)
        .padding(.horizontal, 28)
        .padding(.bottom, 16)
    }

    private func tabButton(_ tab: DashboardTab) -> some View {
        let isActive = selection == tab

        return Button {
            guard selection != tab else { return }
            Haptics.tap()
            withAnimation(.spring(duration: 0.35)) {
                selection = tab
            }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: tab.icon)
                    .font(.system(size: 14, weight: .semibold))

                if isActive {
                    Text(tab.label)
                        .font(ZBTheme.font(12, .semibold))
                        .transition(.opacity)
                }
            }
            .foregroundStyle(isActive ? tab.tint : .white.opacity(0.45))
            .padding(.horizontal, isActive ? 12 : 10)
            .frame(height: 36)
            .background {
                if isActive {
                    Capsule()
                        .fill(tab.tint.opacity(0.16))
                        .overlay {
                            Capsule().strokeBorder(tab.tint.opacity(0.35), lineWidth: 1)
                        }
                        .shadow(color: tab.tint.opacity(0.45), radius: 8)
                }
            }
        }
        .buttonStyle(PressableButtonStyle())
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Carte Liquid Glass du dashboard

struct DashboardCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 24
    var borderColor: Color = .white.opacity(0.10)

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.white.opacity(0.05))
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: 1)
            }
    }
}

extension View {
    func dashboardCard(cornerRadius: CGFloat = 24, borderColor: Color = .white.opacity(0.10)) -> some View {
        modifier(DashboardCardModifier(cornerRadius: cornerRadius, borderColor: borderColor))
    }
}

#Preview {
    DashboardView()
}
