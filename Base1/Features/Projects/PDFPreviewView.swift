//
//  PDFPreviewView.swift
//  Base1
//
//  Created by Antigravity on 2026-02-12.
//

import SwiftUI
import SwiftData
import PDFKit

struct PDFPreviewView: View {
    let project: Project
    let business: Business?
    
    @Environment(\.dismissDrawer) private var dismiss
    @Environment(DrawerRouter.self) private var drawerRouter
    @State private var pdfURL: URL?
    @State private var isLoading = true
    
    var body: some View {
        VStack(spacing: 0) {
            DrawerHeader(
                title: "Project Estimate",
                leadingText: "Close",
                leadingAction: { dismiss() },
                trailingText: nil,
                trailingAction: nil
            )
            
            ZStack {
                if let url = pdfURL {
                    VStack(spacing: 12) {
                        PDFKitView(url: url)
                        
                        HStack(spacing: 12) {
                            // Share PDF file
                            ShareLink(
                                item: url,
                                preview: SharePreview(
                                    "\(project.title) Estimate",
                                    image: Image(systemName: "doc.fill")
                                )
                            ) {
                                Label("Share PDF", systemImage: "square.and.arrow.up")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.glass)
                            
                            // Share magic link for client portal
                            Button {
                                drawerRouter.present(.shareEstimate(project.persistentModelID))
                            } label: {
                                Label("Share Link", systemImage: "link")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.glass)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                } else if isLoading {
                    ProgressView("Generating Estimate...")
                } else {
                    ContentUnavailableView(
                        "Generation Failed",
                        systemImage: "exclamationmark.triangle",
                        description: Text("Could not generate the PDF estimate.")
                    )
                }
            }
        }
        .task {
            await generatePDF()
        }
    }
    
    // Capture snapshot on @MainActor (ImageRenderer requirement),
    // then write the PDF file off the main thread.
    private func generatePDF() async {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("Estimate-\(project.title).pdf")

        // Step 1 — render snapshot on main actor
        let snapshot: CGImage? = await MainActor.run {
            let renderer = ImageRenderer(
                content: ProjectEstimatePDFView(project: project, business: business)
            )
            renderer.proposedSize = ProposedViewSize(width: 612, height: 792)
            renderer.scale = 2.0
            return renderer.cgImage
        }

        // Step 2 — write PDF file off main thread
        let success = await Task.detached(priority: .userInitiated) {
            guard let image = snapshot else { return false }
            var box = CGRect(x: 0, y: 0, width: 612, height: 792)
            guard let ctx = CGContext(url as CFURL, mediaBox: &box, nil) else { return false }
            ctx.beginPDFPage(nil)
            ctx.draw(image, in: box)
            ctx.endPDFPage()
            ctx.closePDF()
            return true
        }.value

        pdfURL = success ? url : nil
        isLoading = false
    }
}

struct PDFKitView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: url)
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = PDFDocument(url: url)
    }
}
