//
//  SettingsView.swift
//  mindfulness
//
//  Created by leo on 31/8/2568 BE.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("selectedAppearance") private var selectedAppearance = AppearanceMode.automatic
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("dailyReminderTime") private var dailyReminderTime = Date()
    @AppStorage("streakReminders") private var streakReminders = true
    @AppStorage("hasProSubscription") private var hasProSubscription = false
    
    @State private var showingDeleteAccountAlert = false
    @State private var showingSubscriptionManagement = false
    @State private var showingNotificationPermission = false
    
    var body: some View {
        NavigationView {
            List {
                // Profile Section
                Section {
                    HStack {
                        Circle()
                            .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 50, height: 50)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(.white)
                                    .font(.title2)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Mindful User")
                                .font(.headline)
                                .fontWeight(.medium)
                            
                            if hasProSubscription {
                                HStack {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                        .font(.caption)
                                    Text("Pro Member")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            } else {
                                Text("Free Plan")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                // Subscription Section
                Section("Subscription") {
                    if hasProSubscription {
                        SettingsRow(
                            icon: "star.fill",
                            iconColor: .yellow,
                            title: "Manage Subscription",
                            subtitle: "View and modify your Pro subscription"
                        ) {
                            showingSubscriptionManagement = true
                        }
                        
                        SettingsRow(
                            icon: "arrow.clockwise.circle.fill",
                            iconColor: .blue,
                            title: "Restore Purchases",
                            subtitle: "Restore your previous purchases"
                        ) {
                            Task {
                                await restorePurchases()
                            }
                        }
                    } else {
                        SettingsRow(
                            icon: "star.circle.fill",
                            iconColor: .purple,
                            title: "Upgrade to Pro",
                            subtitle: "Unlimited meditations, advanced features"
                        ) {
                            // Handle Pro upgrade
                        }
                    }
                }
                
                // Appearance Section
                Section("Appearance") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "paintbrush.fill")
                                .foregroundColor(.orange)
                                .frame(width: 24)
                            Text("Theme")
                                .font(.body)
                            Spacer()
                        }
                        
                        HStack(spacing: 12) {
                            ForEach(AppearanceMode.allCases, id: \.self) { appearance in
                                AppearanceButton(
                                    appearance: appearance,
                                    isSelected: selectedAppearance == appearance
                                ) {
                                    selectedAppearance = appearance
                                    applyAppearance(appearance)
                                }
                            }
                            Spacer()
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // Notifications Section
                Section("Notifications") {
                    SettingsToggle(
                        icon: "bell.fill",
                        iconColor: .blue,
                        title: "Daily Meditation Reminders",
                        subtitle: "Daily notification at your chosen time",
                        isOn: $notificationsEnabled
                    ) {
                        if notificationsEnabled {
                            requestNotificationPermission()
                        }
                    }
                    
                    if notificationsEnabled {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Daily Reminder Time")
                                    .font(.body)
                                Text("When to send your daily meditation reminder")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            DatePicker("", selection: $dailyReminderTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                        }
                        .padding(.vertical, 4)
                        
                        SettingsToggle(
                            icon: "flame.fill",
                            iconColor: .orange,
                            title: "Streak Protection Alerts",
                            subtitle: "Smart reminders when your streak is at risk",
                            isOn: $streakReminders
                        )
                        
                        if streakReminders {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(.orange)
                                        .font(.caption)
                                    
                                    Text("Streak alerts are sent intelligently:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text("•")
                                            .foregroundColor(.orange)
                                        Text("Late in the day if you haven't meditated")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    HStack {
                                        Text("•")
                                            .foregroundColor(.orange)
                                        Text("When you've missed your usual meditation time")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    HStack {
                                        Text("•")
                                            .foregroundColor(.orange)
                                        Text("Before midnight if your streak is at risk")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.leading, 28)
                            .padding(.top, 4)
                        }
                    }
                }
                
                // Support & Legal Section
                Section("Support & Legal") {
                    SettingsRow(
                        icon: "questionmark.circle.fill",
                        iconColor: .blue,
                        title: "Help & Support",
                        subtitle: "Get help or contact support"
                    ) {
                        if let url = URL(string: "mailto:support@mindfulness-app.com") {
                            UIApplication.shared.open(url)
                        }
                    }
                    
                    SettingsRow(
                        icon: "doc.text.fill",
                        iconColor: .gray,
                        title: "Privacy Policy",
                        subtitle: "How we handle your data"
                    ) {
                        if let url = URL(string: "https://mindfulness-app.com/privacy") {
                            UIApplication.shared.open(url)
                        }
                    }
                    
                    SettingsRow(
                        icon: "doc.plaintext.fill",
                        iconColor: .gray,
                        title: "Terms of Service",
                        subtitle: "Terms and conditions"
                    ) {
                        if let url = URL(string: "https://mindfulness-app.com/terms") {
                            UIApplication.shared.open(url)
                        }
                    }
                    
                    SettingsRow(
                        icon: "star.fill",
                        iconColor: .yellow,
                        title: "Rate This App",
                        subtitle: "Share your experience on the App Store"
                    ) {
                        requestAppStoreReview()
                    }
                }
                
                // Account Management Section
                Section("Account") {
                    SettingsRow(
                        icon: "icloud.and.arrow.up.fill",
                        iconColor: .blue,
                        title: "Export Data",
                        subtitle: "Download your meditation data"
                    ) {
                        // Handle data export
                    }
                    
                    SettingsRow(
                        icon: "trash.fill",
                        iconColor: .red,
                        title: "Delete Account",
                        subtitle: "Permanently delete your account and data"
                    ) {
                        showingDeleteAccountAlert = true
                    }
                }
                
                // App Info Section
                Section("About") {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Version")
                                .font(.body)
                            Text("1.0.0 (Build 1)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(
                trailing: Button("Done") {
                    dismiss()
                }
            )
        }
        .sheet(isPresented: $showingSubscriptionManagement) {
            SubscriptionManagementView()
        }
        .alert("Delete Account", isPresented: $showingDeleteAccountAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("This will permanently delete your account and all meditation data. This action cannot be undone.")
        }
        .alert("Notifications", isPresented: $showingNotificationPermission) {
            Button("Cancel", role: .cancel) {
                notificationsEnabled = false
            }
            Button("Settings") {
                openNotificationSettings()
            }
        } message: {
            Text("To receive meditation reminders, please enable notifications in Settings.")
        }
    }
    
    private func applyAppearance(_ appearance: AppearanceMode) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            switch appearance {
            case .light:
                window.overrideUserInterfaceStyle = .light
            case .dark:
                window.overrideUserInterfaceStyle = .dark
            case .automatic:
                window.overrideUserInterfaceStyle = .unspecified
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if !granted {
                    showingNotificationPermission = true
                }
            }
        }
    }
    
    private func openNotificationSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func requestAppStoreReview() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            if #available(iOS 18.0, *) {
                AppStore.requestReview(in: scene)
            } else {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }
    
    private func restorePurchases() async {
        // Handle purchase restoration
        do {
            try await AppStore.sync()
        } catch {
            print("Failed to restore purchases: \(error)")
        }
    }
    
    private func deleteAccount() {
        // Handle account deletion
        // Clear all user data, revoke subscriptions, etc.
        
        // Clear UserDefaults
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
        
        // Clear Core Data / SwiftData
        // This would delete all meditation sessions, user profile, etc.
        
        // Show confirmation and potentially close app or return to onboarding
    }
}

// MARK: - Supporting Views

struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.body)
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingsToggle: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    let onChange: (() -> Void)?
    
    init(icon: String, iconColor: Color, title: String, subtitle: String, isOn: Binding<Bool>, onChange: (() -> Void)? = nil) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self._isOn = isOn
        self.onChange = onChange
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .onChange(of: isOn) {
                    onChange?()
                }
        }
        .padding(.vertical, 4)
    }
}

enum AppearanceMode: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    case automatic = "Automatic"
    
    var icon: String {
        switch self {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        case .automatic: return "circle.lefthalf.filled"
        }
    }
}

struct AppearanceButton: View {
    let appearance: AppearanceMode
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: appearance.icon)
                        .font(.title3)
                        .foregroundColor(isSelected ? .blue : .secondary)
                }
                
                Text(appearance.rawValue)
                    .font(.caption)
                    .foregroundColor(isSelected ? .blue : .secondary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SubscriptionManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("hasProSubscription") private var hasProSubscription = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Mindfulness Pro")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text("Active Subscription")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("$4.99/month")
                                .font(.headline)
                            Text("Renews Dec 1, 2025")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Manage Subscription") {
                    Button("View in App Store") {
                        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                            UIApplication.shared.open(url)
                        }
                    }
                    .foregroundColor(.blue)
                    
                    Button("Cancel Subscription") {
                        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                            UIApplication.shared.open(url)
                        }
                    }
                    .foregroundColor(.red)
                }
                
                Section("Features") {
                    FeatureRow(icon: "infinity", title: "Unlimited Meditations")
                    FeatureRow(icon: "wand.and.stars", title: "Advanced AI Personalization")
                    FeatureRow(icon: "cloud.fill", title: "iCloud Sync")
                    FeatureRow(icon: "chart.bar.fill", title: "Detailed Analytics")
                    FeatureRow(icon: "moon.stars.fill", title: "Premium Sleep Stories")
                }
            }
            .navigationTitle("Subscription")
            .navigationBarItems(
                trailing: Button("Done") {
                    dismiss()
                }
            )
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            Text(title)
            Spacer()
            Image(systemName: "checkmark")
                .foregroundColor(.green)
        }
    }
}

import UserNotifications

#Preview {
    SettingsView()
}