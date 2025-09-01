//
//  AppleSignInView.swift
//  mindfulness
//
//  Created by leo on 1/9/2568 BE.
//

import SwiftUI
import AuthenticationServices
import Auth

struct AppleSignInView: View {
    @StateObject private var authService = AuthenticationService.shared
    @State private var isSigningIn = false
    @State private var signInError: String?
    
    let onSignInSuccess: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Welcome content
            VStack(spacing: 16) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("Welcome to Mindfulness")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Sign in to sync your meditation journey across devices")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            // Apple Sign In Button
            VStack(spacing: 16) {
                if isSigningIn {
                    ProgressView("Signing in...")
                        .frame(height: 50)
                } else {
                    SignInWithAppleButton(
                        onRequest: { request in
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: handleSignInWithApple
                    )
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)
                    .cornerRadius(8)
                }
                
                if let error = signInError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 32)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private func handleSignInWithApple(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            handleSuccessfulAppleSignIn(authorization)
        case .failure(let error):
            handleSignInError(error)
        }
    }
    
    private func handleSuccessfulAppleSignIn(_ authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            signInError = "Failed to get Apple ID credentials"
            return
        }
        
        isSigningIn = true
        signInError = nil
        
        // For simulator testing, use mock data
        #if targetEnvironment(simulator)
        handleMockAppleSignIn()
        #else
        handleRealAppleSignIn(appleIDCredential)
        #endif
    }
    
    private func handleMockAppleSignIn() {
        Task {
            // Create a more accurate mock JWT token for Apple Sign In
            let currentTime = Int(Date().timeIntervalSince1970)
            
            let mockJWTHeader = [
                "alg": "RS256",
                "typ": "JWT",
                "kid": "W6WcOKB"
            ] as [String : Any]
            
            let mockJWTPayload = [
                "iss": "https://appleid.apple.com",
                "aud": "com.company.mindfulness",
                "exp": currentTime + 3600,
                "iat": currentTime,
                "sub": "000123.abc456def789ghi012jkl345mno678pqr.0123",
                "c_hash": "mock_c_hash_value_123456789",
                "email": "testuser@privaterelay.appleid.com",
                "email_verified": "true",
                "auth_time": currentTime,
                "nonce_supported": true
            ] as [String : Any]
            
            // Create base64URL encoded JWT parts
            let headerData = try! JSONSerialization.data(withJSONObject: mockJWTHeader)
            let payloadData = try! JSONSerialization.data(withJSONObject: mockJWTPayload)
            
            // Use base64URL encoding (without padding)
            let headerB64 = headerData.base64EncodedString()
                .replacingOccurrences(of: "+", with: "-")
                .replacingOccurrences(of: "/", with: "_")
                .replacingOccurrences(of: "=", with: "")
            
            let payloadB64 = payloadData.base64EncodedString()
                .replacingOccurrences(of: "+", with: "-")
                .replacingOccurrences(of: "/", with: "_")
                .replacingOccurrences(of: "=", with: "")
            
            // Mock signature (base64URL encoded)
            let mockSignature = "RhxDK9jnKsHMPm6LgbPhKu4F-6wLT9vNrwxV4KKD5qGFhB6bI_XgT5z3lI8oU6nR7yTcAqM2vPj0S_v1xEw8LA"
            
            let mockIdentityToken = "\(headerB64).\(payloadB64).\(mockSignature)"
            
            let result = await authService.signInWithApple(
                userIdentifier: "000123.abc456def789ghi012jkl345mno678pqr.0123",
                email: "testuser@privaterelay.appleid.com",
                fullName: PersonNameComponents(givenName: "Test", familyName: "User"),
                identityToken: mockIdentityToken,
                authorizationCode: "c_mock_auth_code_\(currentTime)"
            )
            
            await handleAuthResult(result)
        }
    }
    
    private func handleRealAppleSignIn(_ credential: ASAuthorizationAppleIDCredential) {
        Task {
            var fullName: PersonNameComponents? = nil
            if let givenName = credential.fullName?.givenName,
               let familyName = credential.fullName?.familyName {
                fullName = PersonNameComponents(givenName: givenName, familyName: familyName)
            }
            
            let identityToken = credential.identityToken.flatMap { String(data: $0, encoding: .utf8) }
            let authorizationCode = credential.authorizationCode.flatMap { String(data: $0, encoding: .utf8) }
            
            let result = await authService.signInWithApple(
                userIdentifier: credential.user,
                email: credential.email,
                fullName: fullName,
                identityToken: identityToken,
                authorizationCode: authorizationCode
            )
            
            await handleAuthResult(result)
        }
    }
    
    @MainActor
    private func handleAuthResult(_ result: Result<User, AuthError>) {
        isSigningIn = false
        
        switch result {
        case .success:
            onSignInSuccess()
        case .failure(let error):
            signInError = error.localizedDescription
        }
    }
    
    private func handleSignInError(_ error: Error) {
        #if targetEnvironment(simulator)
        // In simulator, Apple Sign In will fail, so use mock authentication
        print("Apple Sign In failed in simulator (expected), using mock authentication...")
        handleMockAppleSignIn()
        return
        #else
        isSigningIn = false
        
        if let authError = error as? ASAuthorizationError {
            switch authError.code {
            case .canceled:
                // User canceled - don't show error
                signInError = nil
            case .failed:
                signInError = "Sign in failed. Please try again."
            case .invalidResponse:
                signInError = "Invalid response from Apple. Please try again."
            case .notHandled:
                signInError = "Sign in not handled. Please try again."
            case .unknown:
                signInError = "Unknown error occurred. Please try again."
            case .notInteractive:
                signInError = "Sign in requires user interaction. Please try again."
            @unknown default:
                signInError = "An unexpected error occurred. Please try again."
            }
        } else {
            signInError = error.localizedDescription
        }
        #endif
    }
}

#Preview {
    AppleSignInView {
        print("Sign in successful")
    }
}