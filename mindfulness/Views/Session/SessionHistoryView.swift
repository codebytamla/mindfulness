//
//  SessionHistoryView.swift
//  mindfulness
//
//  Created by leo on 31/8/2568 BE.
//

import SwiftUI
import SwiftData

struct SessionHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \MeditationSession.timestamp, order: .reverse) private var sessions: [MeditationSession]
    
    @State private var searchText = ""
    @State private var selectedFilter: SessionFilter = .all
    
    private var filteredSessions: [MeditationSession] {
        let baseFiltered = sessions.filter { session in
            if searchText.isEmpty {
                return true
            }
            return session.emotion.rawValue.localizedCaseInsensitiveContains(searchText) ||
                   session.meditationType.rawValue.localizedCaseInsensitiveContains(searchText) ||
                   (session.situationDescription?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
        
        switch selectedFilter {
        case .all:
            return baseFiltered
        case .thisWeek:
            let weekAgo = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
            return baseFiltered.filter { $0.timestamp >= weekAgo }
        case .thisMonth:
            let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
            return baseFiltered.filter { $0.timestamp >= monthAgo }
        case .highRated:
            return baseFiltered.filter { ($0.rating ?? 0) >= 4 }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and filter section
                VStack(spacing: 15) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search sessions...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    
                    // Filter tabs
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(SessionFilter.allCases, id: \.self) { filter in
                                FilterChip(
                                    title: filter.displayName,
                                    isSelected: selectedFilter == filter
                                ) {
                                    selectedFilter = filter
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                
                Divider()
                
                // Sessions list
                if filteredSessions.isEmpty {
                    EmptyStateView(
                        icon: "brain.head.profile",
                        title: sessions.isEmpty ? "No Sessions Yet" : "No Matching Sessions",
                        subtitle: sessions.isEmpty ? 
                            "Start your first meditation to see it here" :
                            "Try adjusting your search or filter"
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(groupedSessions, id: \.key) { group in
                                SessionGroupView(
                                    date: group.key,
                                    sessions: group.value
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Session History")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                leading: Button("Close") {
                    dismiss()
                }
            )
        }
    }
    
    private var groupedSessions: [(key: String, value: [MeditationSession])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredSessions) { session in
            if calendar.isDateInToday(session.timestamp) {
                return "Today"
            } else if calendar.isDateInYesterday(session.timestamp) {
                return "Yesterday"
            } else {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                return formatter.string(from: session.timestamp)
            }
        }
        
        let sortedKeys = grouped.keys.sorted { key1, key2 in
            if key1 == "Today" { return true }
            if key2 == "Today" { return false }
            if key1 == "Yesterday" { return true }
            if key2 == "Yesterday" { return false }
            
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            let date1 = formatter.date(from: key1) ?? Date.distantPast
            let date2 = formatter.date(from: key2) ?? Date.distantPast
            return date1 > date2
        }
        
        return sortedKeys.map { key in
            (key: key, value: grouped[key]!.sorted(by: { $0.timestamp > $1.timestamp }))
        }
    }
}

struct SessionGroupView: View {
    let date: String
    let sessions: [MeditationSession]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(date)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.horizontal, 4)
            
            ForEach(sessions, id: \.id) { session in
                JourneyMemoryCard(session: session)
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(UIColor.systemGray5))
                .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(subtitle)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
}

enum SessionFilter: CaseIterable {
    case all
    case thisWeek
    case thisMonth
    case highRated
    
    var displayName: String {
        switch self {
        case .all:
            return "All"
        case .thisWeek:
            return "This Week"
        case .thisMonth:
            return "This Month"
        case .highRated:
            return "Top Rated"
        }
    }
}

#Preview {
    SessionHistoryView()
        .modelContainer(for: MeditationSession.self, inMemory: true)
}