// RefreshableScrollView.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import SwiftUI

/// A scroll view wrapper that supports pull-to-refresh with async action.
struct RefreshableScrollView<Content: View>: View {
    let showsIndicators: Bool
    let onRefresh: () async -> Void
    @ViewBuilder let content: () -> Content

    init(
        showsIndicators: Bool = true,
        onRefresh: @escaping () async -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.showsIndicators = showsIndicators
        self.onRefresh = onRefresh
        self.content = content
    }

    var body: some View {
        ScrollView(showsIndicators: showsIndicators) {
            content()
        }
        .refreshable {
            await onRefresh()
        }
    }
}

#if DEBUG
struct RefreshableScrollView_Previews: PreviewProvider {
    static var previews: some View {
        RefreshableScrollView(onRefresh: { }) {
            VStack {
                ForEach(0..<10, id: \.self) { index in
                    Text("Item \(index)")
                        .padding()
                        .cardStyle()
                }
            }
            .padding()
        }
    }
}
#endif
