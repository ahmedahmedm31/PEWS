// CSVExportView.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import SwiftUI
import UniformTypeIdentifiers

/// A sheet view for previewing and sharing exported CSV data.
struct CSVExportView: View {
    let csvContent: String
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false

    var body: some View {
        NavigationStack {
            VStack(spacing: Theme.Spacing.standard) {
                // Preview header
                HStack {
                    Image(systemName: "doc.text")
                        .font(.title2)
                        .foregroundColor(Theme.Colors.primaryFallback)

                    VStack(alignment: .leading) {
                        Text("Weather Data Export")
                            .font(Theme.Typography.headline)
                        Text("\(lineCount) records")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }

                    Spacer()
                }
                .padding()

                // CSV Preview
                ScrollView([.horizontal, .vertical]) {
                    Text(csvContent)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(Theme.Colors.textPrimary)
                        .padding()
                }
                .background(Theme.Colors.secondaryBackground)
                .cornerRadius(Theme.CornerRadius.medium)
                .padding(.horizontal)

                Spacer()

                // Share button
                Button {
                    showShareSheet = true
                } label: {
                    Label("Share CSV", systemImage: "square.and.arrow.up")
                        .font(Theme.Typography.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.Colors.primaryFallback)
                        .foregroundColor(.white)
                        .cornerRadius(Theme.CornerRadius.medium)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Export Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(items: [csvContent])
            }
        }
    }

    private var lineCount: Int {
        csvContent.components(separatedBy: "\n").count - 2 // Subtract header and trailing newline
    }
}

/// UIKit share sheet wrapper for SwiftUI.
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#if DEBUG
struct CSVExportView_Previews: PreviewProvider {
    static var previews: some View {
        CSVExportView(csvContent: "Date,Temperature,Humidity\n2026-01-01,15.5,72\n2026-01-02,16.2,68\n")
    }
}
#endif
