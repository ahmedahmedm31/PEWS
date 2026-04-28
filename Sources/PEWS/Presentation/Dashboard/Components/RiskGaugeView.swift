// RiskGaugeView.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import SwiftUI

/// An animated gauge view displaying the current risk score and level.
struct RiskGaugeView: View {
    let riskScore: Int
    let riskLevel: RiskLevel

    @State private var animatedScore: Double = 0
    @State private var hasAppeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let gaugeSize: CGFloat = 200
    private let lineWidth: CGFloat = 20

    var body: some View {
        VStack(spacing: Theme.Spacing.medium) {
            ZStack {
                // Background track
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(
                        Theme.Colors.secondaryBackground,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .frame(width: gaugeSize, height: gaugeSize)
                    .rotationEffect(.degrees(135))

                // Filled arc
                Circle()
                    .trim(from: 0, to: animatedScore * 0.75 / 100)
                    .stroke(
                        riskLevel.color,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .frame(width: gaugeSize, height: gaugeSize)
                    .rotationEffect(.degrees(135))

                // Score display
                VStack(spacing: Theme.Spacing.xSmall) {
                    Text("\(Int(animatedScore))")
                        .font(Theme.Typography.riskScore)
                        .foregroundColor(riskLevel.color)
                        .contentTransition(.numericText())

                    Text(riskLevel.displayName)
                        .font(Theme.Typography.headline)
                        .foregroundColor(riskLevel.color)

                    Image(systemName: riskLevel.iconName)
                        .font(.title2)
                        .foregroundColor(riskLevel.color)
                }
            }
            .frame(height: gaugeSize * 0.85)

            // Risk level description
            Text(riskLevel.description)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.standard)
        }
        .onAppear {
            guard !hasAppeared else { return }
            hasAppeared = true
            if reduceMotion {
                animatedScore = Double(riskScore)
            } else {
                withAnimation(AnimationStyles.reveal) {
                    animatedScore = Double(riskScore)
                }
            }
        }
        .onChange(of: riskScore) { newScore in
            withAnimation(AnimationStyles.standard) {
                animatedScore = Double(newScore)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Risk score \(riskScore) out of 100, \(riskLevel.displayName) risk level")
        .accessibilityValue("\(riskLevel.description)")
    }
}

#if DEBUG
struct RiskGaugeView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            RiskGaugeView(riskScore: 15, riskLevel: .low)
            RiskGaugeView(riskScore: 45, riskLevel: .moderate)
            RiskGaugeView(riskScore: 68, riskLevel: .high)
            RiskGaugeView(riskScore: 92, riskLevel: .critical)
        }
        .padding()
    }
}
#endif
