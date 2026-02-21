import SwiftUI
import AuthenticationServices

/// Authentication view with Sign in with Apple
struct AuthView: View {
    @Environment(AuthService.self) private var authService
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.15),
                    Color(red: 0.05, green: 0.05, blue: 0.1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // App branding
                VStack(spacing: 16) {
                    Image(systemName: "building.2.crop.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.white)
                    
                    Text("Base1")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    
                    Text("Business Management")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Features preview
                VStack(spacing: 16) {
                    FeatureRow(
                        icon: "person.3.fill",
                        title: "Team Collaboration",
                        description: "Invite staff and assign roles"
                    )
                    
                    FeatureRow(
                        icon: "doc.text.fill",
                        title: "Professional Estimates",
                        description: "Create and share project quotes"
                    )
                    
                    FeatureRow(
                        icon: "calendar",
                        title: "Schedule Management",
                        description: "Track appointments and milestones"
                    )
                    
                    FeatureRow(
                        icon: "chart.bar.fill",
                        title: "Resource Tracking",
                        description: "Manage equipment and materials"
                    )
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Sign in button
                VStack(spacing: 16) {
                    SignInWithAppleButton(
                        onRequest: { request in
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: { result in
                            switch result {
                            case .success(let authorization):
                                authService.handleAuthorization(authorization)
                            case .failure(let error):
                                authService.handleAuthorizationError(error)
                            }
                        }
                    )
                    .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                    .frame(height: 50)
                    .frame(maxWidth: 280)
                    .cornerRadius(8)
                    
                    Text("Sign in to sync across devices")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                    
                    #if DEBUG
                    Button {
                        authService.signInAsTestUser()
                    } label: {
                        HStack {
                            Image(systemName: "hammer.fill")
                            Text("Continue as Test User")
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.black)
                        .frame(height: 44)
                        .frame(maxWidth: 280)
                        .background(.yellow)
                        .cornerRadius(8)
                    }
                    .padding(.top, 8)
                    #endif
                }
                .padding(.bottom, 60)
            }
            
            // Error display
            if let error = authService.error {
                VStack {
                    Spacer()
                    
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.yellow)
                        Text(error.localizedDescription)
                            .font(.subheadline)
                            .foregroundStyle(.white)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.bottom, 140)
                }
            }
            
            // Loading overlay
            if authService.isLoading {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
            }
        }
    }
}

// MARK: - Feature Row

private struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }
            
            Spacer()
        }
    }
}

#Preview {
    AuthView()
        .environment(AuthService())
}
