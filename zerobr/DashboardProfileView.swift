//
//  DashboardProfileView.swift
//  zerobr
//
//  Created by Rayane Batil on 31/08/2026.
//

import SwiftUI

// MARK: - Onglet Profil

struct DashboardProfileView: View {
    @State private var faceIDEnabled = true
    @State private var anonymousMode = false
    @State private var eveningReminder = true

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                identityCard
                recoveryCard
                settingsCard
                reassuranceSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 120)
        }
    }

    // MARK: Identité

    private var identityCard: some View {
        HStack(spacing: 16) {
            // Avatar néon géométrique
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        AngularGradient(
                            colors: [ZBTheme.violet, ZBTheme.cyan, ZBTheme.indigo, ZBTheme.violet],
                            center: .center
                        )
                    )
                    .frame(width: 64, height: 64)

                Image(systemName: "hexagon.fill")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white.opacity(0.9))
                    .rotationEffect(.degrees(12))
            }
            .shadow(color: ZBTheme.violet.opacity(0.45), radius: 12)

            VStack(alignment: .leading, spacing: 6) {
                Text("Alexandre_94")
                    .font(ZBTheme.font(20, .bold))
                    .foregroundStyle(.white)

                Text("Membre Pro • Essai actif (J-7)")
                    .font(ZBTheme.font(12, .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        LinearGradient(
                            colors: [ZBTheme.violet, ZBTheme.indigo],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
            }

            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .dashboardCard()
        .padding(.top, 8)
    }

    // MARK: Projection de récupération

    private var recoveryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Récupération cérébrale")
                    .font(ZBTheme.font(17, .bold))
                    .foregroundStyle(.white)

                Text("Objectif Clarté Totale : 30 Novembre")
                    .font(ZBTheme.font(13, .medium))
                    .foregroundStyle(ZBTheme.cyan)
            }

            ZStack(alignment: .topLeading) {
                RecoveryCurveShape(closed: true)
                    .fill(
                        LinearGradient(
                            colors: [ZBTheme.cyan.opacity(0.30), ZBTheme.violet.opacity(0.02)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                RecoveryCurveShape(closed: false)
                    .stroke(
                        LinearGradient(
                            colors: [ZBTheme.violet, ZBTheme.cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .shadow(color: ZBTheme.cyan.opacity(0.5), radius: 8)

                // Marqueur de position actuelle (Jour 1)
                GeometryReader { proxy in
                    Circle()
                        .fill(.white)
                        .frame(width: 10, height: 10)
                        .overlay {
                            Circle()
                                .stroke(ZBTheme.violet, lineWidth: 3)
                        }
                        .shadow(color: ZBTheme.violet.opacity(0.8), radius: 6)
                        .position(x: proxy.size.width * 0.015, y: proxy.size.height * 0.85)
                }
            }
            .frame(height: 150)

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Jour 1")
                        .font(ZBTheme.font(13, .bold))
                        .foregroundStyle(.white)
                    Text("Aujourd'hui")
                        .font(ZBTheme.font(11, .medium))
                        .foregroundStyle(.white.opacity(0.45))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Jour 90")
                        .font(ZBTheme.font(13, .bold))
                        .foregroundStyle(ZBTheme.cyan)
                    Text("30 Novembre")
                        .font(ZBTheme.font(11, .medium))
                        .foregroundStyle(.white.opacity(0.45))
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .dashboardCard()
    }

    // MARK: Réglages

    private var settingsCard: some View {
        VStack(spacing: 0) {
            SettingToggleRow(
                icon: "faceid",
                tint: ZBTheme.cyan,
                title: "Verrouillage Face ID / Code secret",
                subtitle: "Protège l'accès à l'application",
                isOn: $faceIDEnabled
            )

            Divider().overlay(.white.opacity(0.07))

            SettingToggleRow(
                icon: "eye.slash.fill",
                tint: ZBTheme.violet,
                title: "Mode 100 % Anonyme",
                subtitle: "Masquer mon nom sur le classement",
                isOn: $anonymousMode
            )

            Divider().overlay(.white.opacity(0.07))

            SettingToggleRow(
                icon: "moon.stars.fill",
                tint: ZBTheme.indigo,
                title: "Notifications d'ancrage du soir",
                subtitle: "Actif à 22h30",
                isOn: $eveningReminder
            )
        }
        .padding(.vertical, 6)
        .dashboardCard()
    }

    // MARK: Réassurance

    private var reassuranceSection: some View {
        VStack(spacing: 14) {
            Button {
                Haptics.tap()
            } label: {
                Text("Gérer mon abonnement (App Store)")
                    .font(ZBTheme.font(15, .semibold))
                    .foregroundStyle(.white.opacity(0.8))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .dashboardCard(cornerRadius: 16)
            }
            .buttonStyle(PressableButtonStyle())

            Text("ZeroBR v1.0.0 • Données chiffrées de bout en bout")
                .font(ZBTheme.font(11, .medium))
                .foregroundStyle(.white.opacity(0.35))
        }
    }
}

// MARK: - Ligne de réglage avec toggle

private struct SettingToggleRow: View {
    let icon: String
    let tint: Color
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 36, height: 36)
                .background(tint.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(ZBTheme.font(14, .semibold))
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(ZBTheme.font(12, .medium))
                    .foregroundStyle(.white.opacity(0.45))
            }

            Spacer(minLength: 0)

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(tint)
                .onChange(of: isOn) {
                    Haptics.tick()
                }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        DashboardProfileView()
    }
    .preferredColorScheme(.dark)
}
