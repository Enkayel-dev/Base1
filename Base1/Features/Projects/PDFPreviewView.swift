//
//  PDFPreviewView.swift
//  Base1
//
//  Created by Antigravity on 2026-02-12.
//

import SwiftUI
import PDFKit

struct PDFPreviewView: View {
    let project: Project
    let business: Business?
    
    @Environment(\.dismissDrawer) private var dismiss
    @State private var pdfURL: URL?
    @State private var isLoading = true
    
    var body: some View {
        VStack(spacing: 0) {
            DrawerHeader(
                title: "Project Estimate",
                leadingText: "Close",
                leadingAction: { dismiss() },
                trailingText: "Share",
                trailingAction: {
                    if let url = pdfURL {
                        sharePDF(url: url)
                    }
                }
            )
            
            ZStack {
                if let url = pdfURL {
                    PDFKitView(url: url)
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
            generatePDF()
        }
    }
    
    @MainActor
    private func generatePDF() {
        let renderer = ImageRenderer(content: ProjectEstimatePDFView(project: project, business: business))
        
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("Estimate-\(project.title).pdf")
        
        renderer.render { size, context in
            var box = CGRect(origin: .zero, size: size)
            
            guard let pdfContext = CGContext(url as CFURL, mediaBox: &box, nil) else {
                isLoading = false
                return
            }
            
            pdfContext.beginPDFPage(nil)
            context(pdfContext)
            pdfContext.endPDFPage()
            pdfContext.closePDF()
            
            self.pdfURL = url
            self.isLoading = false
        }
    }
    
    private func sharePDF(url: URL) {
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            
            // For iPad
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = rootVC.view
                popover.sourceRect = CGRect(x: windowScene.screen.bounds.width / 2, y: windowScene.screen.bounds.height / 2, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            rootVC.present(activityVC, animated: true)
        }
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
