//
//  ShareEstimateView.swift
//  Base1
//
//  Created by Claude on 2026-02-19.
//

import SwiftUI
import SwiftData

/// A view for sharing project estimates via magic link.
/// Displays share options and link management.
struct ShareEstimateView: View {
    let project: Project
    
    @Environment(PortalService.self) private var portalService
    @Environment(\.dismiss) private var dismiss
    
    @State private var shareURL: URL?
    @State private var showCopiedFeedback = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "link.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.blue)
                
                Text("Share Estimate")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Send this link to your client so they can view and approve the estimate.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top)
            
            // Link display
            if let url = shareURL {
                VStack(spacing: 12) {
                    // URL display
                    Text(url.absoluteString)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    // Share buttons
                    HStack(spacing: 12) {
                        // Copy button
                        Button {
                            copyToClipboard(url)
                        } label: {
                            Label(showCopiedFeedback ? "Copied!" : "Copy Link", systemImage: showCopiedFeedback ? "checkmark" : "doc.on.doc")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(showCopiedFeedback ? .green : .blue)
                        
                        // Share sheet
                        ShareLink(item: url) {
                            Label("Share", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    
                    // Shared timestamp
                    if let sharedAt = project.estimateSharedAt {
                        Text("Link created \(sharedAt, style: .relative) ago")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
            } else {
                // Generate link button
                Button {
                    generateLink()
                } label: {
                    Label("Generate Link", systemImage: "link.badge.plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            
            Divider()
            
            // Actions
            VStack(spacing: 8) {
                if shareURL != nil {
                    Button(role: .destructive) {
                        revokeLink()
                    } label: {
                        Label("Revoke Link", systemImage: "trash")
                            .font(.subheadline)
                    }
                    .buttonStyle(.borderless)
                }
                
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .buttonStyle(.borderless)
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            loadExistingLink()
        }
    }
    
    // MARK: - Actions
    
    private func loadExistingLink() {
        shareURL = portalService.getEstimateLink(for: project)
    }
    
    private func generateLink() {
        shareURL = portalService.generateEstimateLink(for: project)
    }
    
    private func revokeLink() {
        portalService.revokeEstimateLink(for: project)
        shareURL = nil
    }
    
    private func copyToClipboard(_ url: URL) {
        UIPasteboard.general.string = url.absoluteString
        
        withAnimation {
            showCopiedFeedback = true
        }
        
        // Reset feedback after delay
        Task {
            try? await Task.sleep(for: .seconds(2))
            withAnimation {
                showCopiedFeedback = false
            }
        }
    }
}
