// DateRangePickerView.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import SwiftUI

/// A date range picker component for selecting start and end dates.
struct DateRangePickerView: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    let onChanged: () -> Void

    @State private var selectedPreset: DatePreset = .week

    enum DatePreset: String, CaseIterable {
        case day = "24h"
        case week = "7d"
        case month = "30d"
        case custom = "Custom"
    }

    var body: some View {
        VStack(spacing: Theme.Spacing.medium) {
            // Preset buttons
            HStack(spacing: Theme.Spacing.small) {
                ForEach(DatePreset.allCases, id: \.self) { preset in
                    Button {
                        selectedPreset = preset
                        applyPreset(preset)
                    } label: {
                        Text(preset.rawValue)
                            .font(Theme.Typography.caption)
                            .padding(.horizontal, Theme.Spacing.medium)
                            .padding(.vertical, Theme.Spacing.xSmall)
                            .background(
                                selectedPreset == preset
                                    ? Theme.Colors.primaryFallback
                                    : Theme.Colors.secondaryBackground
                            )
                            .foregroundColor(
                                selectedPreset == preset
                                    ? .white
                                    : Theme.Colors.textPrimary
                            )
                            .cornerRadius(Theme.CornerRadius.small)
                    }
                }
            }

            // Custom date pickers (shown only when custom is selected)
            if selectedPreset == .custom {
                HStack {
                    VStack(alignment: .leading) {
                        Text("From")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textSecondary)
                        DatePicker(
                            "",
                            selection: $startDate,
                            in: ...endDate,
                            displayedComponents: .date
                        )
                        .labelsHidden()
                    }

                    Spacer()

                    VStack(alignment: .leading) {
                        Text("To")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textSecondary)
                        DatePicker(
                            "",
                            selection: $endDate,
                            in: startDate...Date(),
                            displayedComponents: .date
                        )
                        .labelsHidden()
                    }
                }
                .onChange(of: startDate) { _ in onChanged() }
                .onChange(of: endDate) { _ in onChanged() }
            }

            // Date range display
            Text("\(Formatters.displayDate.string(from: startDate)) - \(Formatters.displayDate.string(from: endDate))")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textTertiary)
        }
    }

    private func applyPreset(_ preset: DatePreset) {
        let calendar = Calendar.current
        endDate = Date()

        switch preset {
        case .day:
            startDate = calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        case .month:
            startDate = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        case .custom:
            return // Don't change dates for custom
        }

        onChanged()
    }
}

#if DEBUG
struct DateRangePickerView_Previews: PreviewProvider {
    static var previews: some View {
        DateRangePickerView(
            startDate: .constant(Date().addingTimeInterval(-604800)),
            endDate: .constant(Date()),
            onChanged: {}
        )
        .padding()
    }
}
#endif
