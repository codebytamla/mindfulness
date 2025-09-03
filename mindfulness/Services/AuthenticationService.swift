//
//  AuthenticationService.swift
//  mindfulness
//
//  Created by leo on 31/8/2568 BE.
//

import Foundation
import Supabase
import Auth

@MainActor
class AuthenticationService: ObservableObject {
    static let shared = AuthenticationService()
    
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var authError: AuthError?
    
    private let supabase = SupabaseManager.shared.client
    
    private init() {
        isLoading = true
        
        // Check for existing session on startup with timeout
        Task {
            await checkExistingSessionWithTimeout()
        }
        
        // Listen for auth state changes
        setupAuthStateListener()
    }
    
    // MARK: - Session Management
    
    private func checkExistingSessionWithTimeout() async {
        await MainActor.run {
            isLoading = true
        }
        
        // Create timeout task
        let timeoutTask = Task {
            try? await Task.sleep(nanoseconds: 10_000_000_000) // 10 seconds
            await MainActor.run {
                if isLoading {
                    print("⚠️ Authentication timeout - setting to not authenticated")
                    updateAuthState(user: nil, isAuthenticated: false)
                    isLoading = false
                }
            }
        }
        
        // Check for existing session
        do {
            let session = try await supabase.auth.session
            timeoutTask.cancel() // Cancel timeout since we got a response
            print("✅ Found existing session for user: \(session.user.id.uuidString)")
            await MainActor.run {
                updateAuthState(user: session.user, isAuthenticated: true)
                // isLoading is now set to false in updateAuthState
            }
        } catch {
            timeoutTask.cancel() // Cancel timeout since we got a response  
            print("❌ No existing session found: \(error)")
            await MainActor.run {
                updateAuthState(user: nil, isAuthenticated: false)
                // isLoading is now set to false in updateAuthState
            }
        }
    }
    
    private func setupAuthStateListener() {
        Task {
            for await state in supabase.auth.authStateChanges {
                await MainActor.run {
                    print("🔐 Auth state changed: \(state.event)")
                    switch state.event {
                    case .signedIn:
                        print("✅ User signed in: \(state.session?.user.id.uuidString ?? "unknown")")
                        updateAuthState(user: state.session?.user, isAuthenticated: true)
                    case .signedOut:
                        print("❌ User signed out")
                        updateAuthState(user: nil, isAuthenticated: false)
                    case .tokenRefreshed:
                        print("🔄 Token refreshed for user: \(state.session?.user.id.uuidString ?? "unknown")")
                        updateAuthState(user: state.session?.user, isAuthenticated: true)
                    case .initialSession:
                        print("🔄 Initial session found: \(state.session?.user.id.uuidString ?? "unknown")")
                        if let user = state.session?.user {
                            updateAuthState(user: user, isAuthenticated: true)
                        } else {
                            updateAuthState(user: nil, isAuthenticated: false)
                        }
                    default:
                        print("🔐 Other auth event: \(state.event)")
                        break
                    }
                }
            }
        }
    }
    
    private func updateAuthState(user: User?, isAuthenticated: Bool) {
        print("🔄 Updating auth state - isAuthenticated: \(isAuthenticated), user: \(user?.id.uuidString ?? "nil"), isLoading: \(isLoading)")
        self.currentUser = user
        self.isAuthenticated = isAuthenticated
        self.authError = nil
        
        // Ensure loading is set to false when we have a definitive auth state
        if self.isLoading {
            self.isLoading = false
            print("✅ Set isLoading to false after auth state update")
        }
    }
    
    // MARK: - Apple Sign In
    
    func signInWithApple(
        userIdentifier: String,
        email: String?,
        fullName: PersonNameComponents?,
        identityToken: String?,
        authorizationCode: String?
    ) async -> Result<User, AuthError> {
        isLoading = true
        authError = nil
        
        do {
            let session: Session
            
            #if targetEnvironment(simulator)
            // For simulator, use anonymous auth instead of Apple Sign In JWT
            print("Using anonymous auth for simulator Apple Sign In mock")
            session = try await supabase.auth.signInAnonymously()
            #else
            // For real device, use Apple Sign In with JWT
            guard let identityToken = identityToken else {
                let error = AuthError.invalidCredentials
                self.authError = error
                isLoading = false
                return .failure(error)
            }
            
            session = try await supabase.auth.signInWithIdToken(
                credentials: .init(
                    provider: .apple,
                    idToken: identityToken
                )
            )
            #endif
            
            let user = session.user
            
            // Update user metadata with Apple information
            if let email = email, let fullName = fullName {
                try await supabase.auth.update(
                    user: UserAttributes(
                        data: [
                            "provider": .string("apple"),
                            "apple_user_id": .string(userIdentifier),
                            "display_name": .string(fullName.formatted(.name(style: .long))),
                            "first_name": .string(fullName.givenName ?? ""),
                            "last_name": .string(fullName.familyName ?? ""),
                            "email": .string(email)
                        ]
                    )
                )
            }
            
            // Create initial user profile data
            await createInitialUserProfile(for: user)
            
            isLoading = false
            return .success(user)
            
        } catch let error as AuthError {
            isLoading = false
            self.authError = error
            return .failure(error)
        } catch {
            isLoading = false
            let authError = AuthError.unknown(error.localizedDescription)
            self.authError = authError
            return .failure(authError)
        }
    }
    
    // MARK: - Anonymous Authentication
    
    func signInAnonymously() async -> Result<User, AuthError> {
        isLoading = true
        authError = nil
        
        do {
            let session = try await supabase.auth.signInAnonymously()
            
            // Create initial user profile data
            let user = session.user
            await createInitialUserProfile(for: user)
            return .success(user)
            
        } catch let error as AuthError {
            self.authError = error
            return .failure(error)
        } catch {
            let authError = AuthError.unknown(error.localizedDescription)
            self.authError = authError
            return .failure(authError)
        }
    }
    
    // MARK: - Account Upgrade
    
    func upgradeAccount(email: String, password: String, displayName: String) async -> Result<User, AuthError> {
        guard currentUser != nil else {
            let error = AuthError.notAuthenticated
            self.authError = error
            return .failure(error)
        }
        
        isLoading = true
        authError = nil
        
        do {
            // Update user with email and password
            let updatedUser = try await supabase.auth.update(
                user: UserAttributes(
                    email: email,
                    password: password,
                    data: [
                        "display_name": .string(displayName),
                        "upgraded_at": .string(ISO8601DateFormatter().string(from: Date()))
                    ]
                )
            )
            
            // Update user profile in database
            await updateUserProfile(displayName: displayName, email: email)
            
            isLoading = false
            return .success(updatedUser)
            
        } catch let error as AuthError {
            isLoading = false
            self.authError = error
            return .failure(error)
        } catch {
            isLoading = false
            let authError = AuthError.unknown(error.localizedDescription)
            self.authError = authError
            return .failure(authError)
        }
    }
    
    // MARK: - Profile Management
    
    private func createInitialUserProfile(for user: User) async {
        // This would typically involve creating a user profile in your database
        // For now, we'll just log the creation
        print("Created initial profile for user: \(user.id.uuidString)")
        
        // You could extend this to create a UserProfile record in SwiftData
        // or sync with a Supabase table for user profiles
    }
    
    private func updateUserProfile(displayName: String, email: String) async {
        guard let currentUser = currentUser else { return }
        
        // Update user profile with new information
        print("Updated profile for user \(currentUser.id.uuidString): \(displayName), \(email)")
        
        // Extend this to update your SwiftData UserProfile model
        // or sync with Supabase user profiles table
    }
    
    // MARK: - Sign Out
    
    func signOut() async -> Result<Void, AuthError> {
        isLoading = true
        authError = nil
        
        do {
            try await supabase.auth.signOut()
            isLoading = false
            return .success(())
        } catch let error as AuthError {
            isLoading = false
            self.authError = error
            return .failure(error)
        } catch {
            isLoading = false
            let authError = AuthError.unknown(error.localizedDescription)
            self.authError = authError
            return .failure(authError)
        }
    }
    
    // MARK: - Utility Methods
    
    var isAnonymousUser: Bool {
        guard let user = currentUser else { return false }
        return user.email == nil || user.email?.isEmpty == true
    }
    
    var userDisplayName: String {
        guard let user = currentUser else { return "Guest" }
        
        // Check custom display_name first
        if let displayName = user.userMetadata["display_name"]?.stringValue,
           !displayName.isEmpty {
            return displayName
        }
        
        // Check first name from Apple Sign In
        if let firstName = user.userMetadata["first_name"]?.stringValue,
           !firstName.isEmpty {
            return firstName
        }
        
        // Fallback to email if available
        if let email = user.email, !email.isEmpty {
            return email
        }
        
        return "User"
    }
    
    func refreshSession() async {
        do {
            _ = try await supabase.auth.refreshSession()
        } catch {
            print("Failed to refresh session: \(error)")
        }
    }
}

// MARK: - Auth Error Types

enum AuthError: LocalizedError, Equatable {
    case notAuthenticated
    case invalidCredentials
    case emailAlreadyExists
    case weakPassword
    case invalidEmail
    case networkError
    case unexpectedResponse
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "User is not authenticated"
        case .invalidCredentials:
            return "Invalid email or password"
        case .emailAlreadyExists:
            return "An account with this email already exists"
        case .weakPassword:
            return "Password is too weak. Please use at least 8 characters"
        case .invalidEmail:
            return "Please enter a valid email address"
        case .networkError:
            return "Network connection error. Please try again"
        case .unexpectedResponse:
            return "Unexpected response from server"
        case .unknown(let message):
            return message
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .notAuthenticated:
            return "Please sign in to continue"
        case .invalidCredentials:
            return "Please check your email and password and try again"
        case .emailAlreadyExists:
            return "Try signing in with this email instead"
        case .weakPassword:
            return "Use a combination of letters, numbers, and symbols"
        case .invalidEmail:
            return "Please enter a valid email address"
        case .networkError:
            return "Check your internet connection and try again"
        default:
            return "Please try again or contact support"
        }
    }
}