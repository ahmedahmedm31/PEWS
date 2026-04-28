// LocationSearchView.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import SwiftUI

/// View for searching and adding new monitored locations.
struct LocationSearchView: View {
    @StateObject var viewModel: LocationSearchViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Theme.Colors.textTertiary)

                    TextField("Search city or location...", text: $viewModel.searchQuery)
                        .textFieldStyle(.plain)
                        .autocorrectionDisabled()
                        .onSubmit {
                            Task { await viewModel.search() }
                        }

                    if !viewModel.searchQuery.isEmpty {
                        Button {
                            viewModel.searchQuery = ""
                            viewModel.searchResults = []
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Theme.Colors.textTertiary)
                        }
                    }
                }
                .padding()
                .background(Theme.Colors.secondaryBackground)
                .cornerRadius(Theme.CornerRadius.medium)
                .padding()

                // Results
                if viewModel.isSearching {
                    LoadingView(message: "Searching...")
                } else if viewModel.searchResults.isEmpty && !viewModel.searchQuery.isEmpty {
                    EmptyStateView(
                        icon: "mappin.slash",
                        title: "No Results",
                        message: "No locations found matching your search."
                    )
                } else {
                    List(viewModel.searchResults) { location in
                        Button {
                            Task {
                                await viewModel.addLocation(location)
                                dismiss()
                            }
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                                    Text(location.name)
                                        .font(Theme.Typography.headline)
                                        .foregroundColor(Theme.Colors.textPrimary)

                                    Text(location.fullDisplayName)
                                        .font(Theme.Typography.caption)
                                        .foregroundColor(Theme.Colors.textSecondary)
                                }

                                Spacer()

                                Image(systemName: "plus.circle")
                                    .foregroundColor(Theme.Colors.primaryFallback)
                            }
                        }
                    }
                    .listStyle(.plain)
                }

                Spacer()
            }
            .navigationTitle("Add Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onChange(of: viewModel.searchQuery) { _ in
                viewModel.debounceSearch()
            }
        }
    }
}

/// ViewModel for the location search screen.
@MainActor
final class LocationSearchViewModel: ObservableObject {
    @Published var searchQuery = ""
    @Published var searchResults: [Location] = []
    @Published var isSearching = false
    @Published var errorMessage: String?

    private let weatherAPIService: WeatherAPIServiceProtocol
    private let addLocationUseCase: AddLocationUseCase
    private let debouncer = Debouncer(delay: 0.5)

    init(
        weatherAPIService: WeatherAPIServiceProtocol,
        addLocationUseCase: AddLocationUseCase
    ) {
        self.weatherAPIService = weatherAPIService
        self.addLocationUseCase = addLocationUseCase
    }

    func debounceSearch() {
        debouncer.debounce { [weak self] in
            Task { @MainActor in
                await self?.search()
            }
        }
    }

    func search() async {
        guard searchQuery.count >= 2 else {
            searchResults = []
            return
        }

        isSearching = true
        errorMessage = nil

        do {
            let dtos = try await weatherAPIService.searchLocations(query: searchQuery)
            searchResults = LocationMapper.mapToDomain(dtos)
        } catch {
            errorMessage = error.localizedDescription
            searchResults = []
        }

        isSearching = false
    }

    func addLocation(_ location: Location) async {
        do {
            try await addLocationUseCase.execute(location: location)
            Logger.ui("Location added: \(location.name)")
        } catch {
            errorMessage = error.localizedDescription
            Logger.error("Failed to add location", error: error)
        }
    }
}
