// AlertsView.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import SwiftUI

/// View displaying the alert history with filtering, management, and threshold configuration.
struct AlertsView: View {
    @StateObject var viewModel: AlertsViewModel

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .idle, .loading:
                    LoadingView(message: "Loading alerts...")

                case .loaded:
                    alertsContent

                case .empty:
                    EmptyStateView(
                        icon: "bell.slash",
                        title: "No Alerts",
                        message: "No weather alerts have been triggered. Alerts appear when risk scores exceed your threshold."
                    )

                case .error(let message):
                    ErrorView(message: message) {
                        await viewModel.loadAlerts()
                    }
                }
            }
            .navigationTitle("Alerts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            viewModel.showThresholdEditor = true
                        } label: {
                            Label("Threshold Settings", systemImage: "slider.horizontal.3")
                        }

                        Button(role: .destructive) {
                            Task { await viewModel.deleteAll() }
                        } label: {
                            Label("Clear All", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showThresholdEditor) {
                ThresholdEditorView(
                    threshold: $viewModel.alertThreshold,
                    onSave: { viewModel.updateThreshold() }
                )
            }
            .task {
                await viewModel.loadAlerts()
            }
        }
    }

    // MARK: - Content

    private var alertsContent: some View {
        VStack(spacing: 0) {
            // Filter bar
            filterBar

            // Alert list
            List {
                ForEach(viewModel.filteredAlerts) { alert in
                    AlertRowView(alert: alert)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                Task { await viewModel.delete(alert) }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }

                            if !alert.isAcknowledged {
                                Button {
                                    Task { await viewModel.acknowledge(alert) }
                                } label: {
                                    Label("Acknowledge", systemImage: "checkmark")
                                }
                                .tint(Theme.Colors.primaryFallback)
                            }
                        }
                        .swipeActions(edge: .leading) {
                            if !alert.isRead {
                                Button {
                                    Task { await viewModel.markAsRead(alert) }
                                } label: {
                                    Label("Read", systemImage: "envelope.open")
                                }
                                .tint(.blue)
                            }
                        }
                }
            }
            .listStyle(.plain)
            .refreshable {
                await viewModel.loadAlerts()
            }
        }
    }

    // MARK: - Filter Bar

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.small) {
                ForEach(AlertsViewModel.AlertFilter.allCases, id: \.self) { filter in
                    Button {
                        viewModel.filterOption = filter
                        Task { await viewModel.applyCurrentFilter() }
                    } label: {
                        Text(filter.rawValue)
                            .font(Theme.Typography.caption)
                            .padding(.horizontal, Theme.Spacing.medium)
                            .padding(.vertical, Theme.Spacing.xSmall)
                            .background(
                                viewModel.filterOption == filter
                                    ? Theme.Colors.primaryFallback
                                    : Theme.Colors.secondaryBackground
                            )
                            .foregroundColor(
                                viewModel.filterOption == filter
                                    ? .white
                                    : Theme.Colors.textPrimary
                            )
                            .cornerRadius(Theme.CornerRadius.small)
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.standard)
            .padding(.vertical, Theme.Spacing.small)
        }
    }
}

// MARK: - Alert Row

/// A row displaying a single alert with risk level indicator and details.
struct AlertRowView: View {
    let alert: Alert

    var body: some View {
        HStack(spacing: Theme.Spacing.medium) {
            // Risk level indicator
            Circle()
                .fill(alert.riskLevel.color)
                .frame(width: 12, height: 12)
                .overlay(
                    Circle()
                        .stroke(alert.riskLevel.color.opacity(0.3), lineWidth: 3)
                )

            VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                HStack {
                    Text(alert.title)
                        .font(alert.isRead ? Theme.Typography.subheadline : Theme.Typography.headline)
                        .foregroundColor(Theme.Colors.textPrimary)

                    Spacer()

                    Text(alert.relativeTime)
                        .font(Theme.Typography.caption2)
                        .foregroundColor(Theme.Colors.textTertiary)
                }

                Text(alert.message)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .lineLimit(2)

                HStack(spacing: Theme.Spacing.small) {
                    Label("\(alert.riskScore)", systemImage: alert.riskLevel.iconName)
                        .font(Theme.Typography.caption2)
                        .foregroundColor(alert.riskLevel.color)

                    if alert.isAcknowledged {
                        Label("Acknowledged", systemImage: "checkmark.circle.fill")
                            .font(Theme.Typography.caption2)
                            .foregroundColor(Theme.Colors.riskLow)
                    }
                }
            }
        }
        .padding(.vertical, Theme.Spacing.xSmall)
        .opacity(alert.isRead ? 0.8 : 1.0)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(alert.riskLevel.displayName) alert: \(alert.title). \(alert.message)")
    }
}

// MARK: - Threshold Editor

/// A sheet for editing the alert risk threshold.
struct ThresholdEditorView: View {
    @Binding var threshold: Double
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: Theme.Spacing.xLarge) {
                VStack(spacing: Theme.Spacing.medium) {
                    Text("Alert Threshold")
                        .font(Theme.Typography.title2)

                    Text("Alerts trigger when the risk score exceeds this value.")
                        .font(Theme.Typography.subheadline)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }

                // Threshold display
                Text("\(Int(threshold))")
                    .font(Theme.Typography.riskScore)
                    .foregroundColor(RiskLevel.fromScore(Int(threshold)).color)

                // Slider
                VStack(spacing: Theme.Spacing.small) {
                    Slider(value: $threshold, in: 10...90, step: 5) {
                        Text("Threshold")
                    }
                    .tint(RiskLevel.fromScore(Int(threshold)).color)

                    HStack {
                        Text("Low (10)")
                            .font(Theme.Typography.caption2)
                            .foregroundColor(Theme.Colors.textTertiary)
                        Spacer()
                        Text("High (90)")
                            .font(Theme.Typography.caption2)
                            .foregroundColor(Theme.Colors.textTertiary)
                    }
                }
                .padding(.horizontal, Theme.Spacing.xLarge)

                // Risk level description
                Text(RiskLevel.fromScore(Int(threshold)).description)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()
            }
            .padding(.top, Theme.Spacing.xLarge)
            .navigationTitle("Threshold")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
