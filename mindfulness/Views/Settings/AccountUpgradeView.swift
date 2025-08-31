//
//  AccountUpgradeView.swift
//  mindfulness
//
//  Created by leo on 31/8/2568 BE.
//

import SwiftUI

struct AccountUpgradeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authService: AuthenticationService
    
    @State private var displayName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @State private var isUpgrading = false
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    private var isFormValid: Bool {
        !displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        isValidEmail(email) &&
        password.count >= 8 &&
        password == confirmPassword
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 50, weight: .light))
                            .foregroundColor(.blue)
                        
                        VStack(spacing: 8) {
                            Text("Upgrade Your Account")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Add your email and name to sync your meditation data across devices and never lose your progress")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Form
                    VStack(spacing: 20) {
                        // Display Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Display Name")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Enter your name", text: $displayName)
                                .textFieldStyle(.roundedBorder)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.words)
                        }
                        
                        // Email
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email Address")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Enter your email", text: $email)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.emailAddress)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                        }
                        
                        // Password
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            SecureField("Create a password (min 8 characters)", text: $password)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        // Confirm Password
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            SecureField("Confirm your password", text: $confirmPassword)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        // Password validation feedback
                        if !password.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                PasswordRequirementRow(
                                    text: "At least 8 characters",
                                    isValid: password.count >= 8
                                )
                                
                                if !confirmPassword.isEmpty {
                                    PasswordRequirementRow(
                                        text: "Passwords match",
                                        isValid: password == confirmPassword
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Benefits section
                    VStack(spacing: 16) {
                        Text("Benefits of upgrading:")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 12) {
                            BenefitRow(
                                icon: "icloud",
                                title: "Cloud Sync",
                                description: "Access your data on any device"
                            )
                            
                            BenefitRow(
                                icon: "chart.line.uptrend.xyaxis",
                                title: "Advanced Analytics",
                                description: "Detailed insights into your progress"
                            )
                            
                            BenefitRow(
                                icon: "shield.checkered",
                                title: "Backup Protection",
                                description: "Never lose your meditation journey"
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    
                    // Upgrade button
                    Button(action: upgradeAccount) {
                        HStack {
                            if isUpgrading {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                
                                Text("Upgrading...")
                            } else {
                                Image(systemName: "arrow.up.circle.fill")
                                Text("Upgrade Account")
                            }
                        }
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid && !isUpgrading ? Color.blue : Color.gray)
                        .cornerRadius(12)
                    }
                    .disabled(!isFormValid || isUpgrading)
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 50)
                }
            }
            .navigationTitle("Upgrade Account")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
            )
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    @MainActor
    private func upgradeAccount() {
        guard isFormValid else { return }
        
        isUpgrading = true
        
        Task {
            let result = await authService.upgradeAccount(
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password,
                displayName: displayName.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            
            switch result {
            case .success(let user):
                alertTitle = "Success!"
                alertMessage = "Your account has been upgraded successfully. Welcome \(authService.userDisplayName)!"
                showingAlert = true
                
                // Delay dismiss to show success message
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    dismiss()
                }
                
            case .failure(let error):
                alertTitle = "Upgrade Failed"
                alertMessage = error.localizedDescription
                showingAlert = true
            }
            
            isUpgrading = false
        }
    }
}

struct PasswordRequirementRow: View {
    let text: String
    let isValid: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.caption)
                .foregroundColor(isValid ? .green : .red)
            
            Text(text)
                .font(.caption)
                .foregroundColor(isValid ? .green : .secondary)
        }
    }
}

struct BenefitRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    AccountUpgradeView()
        .environmentObject(AuthenticationService.shared)
}