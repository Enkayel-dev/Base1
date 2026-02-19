//
//  ProjectEstimatePDFView.swift
//  Base1
//
//  Created by Antigravity on 2026-02-12.
//

import SwiftUI

struct ProjectEstimatePDFView: View {
    let project: Project
    let business: Business?
    
    // Letter Size: 8.5" x 11" @ 72 DPI = 612 x 792 points
    private let pageWidth: CGFloat = 612
    private let pageHeight: CGFloat = 792
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header: Business Info (Left) & Client Info (Right)
            HStack(alignment: .top) {
                // Business Info
                VStack(alignment: .leading, spacing: 4) {
                    if let business = business {
                        Text(business.name)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.primary)
                        
                        Group {
                            if let address = business.address { Text(address) }
                            if let email = business.email { Text(email) }
                            if let phone = business.phone { Text(phone) }
                            if let tax = business.taxNumber { Text("Tax ID: \(tax)") }
                        }
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                    } else {
                        Text("Business Name")
                            .font(.system(size: 24, weight: .bold))
                    }
                }
                
                Spacer()
                
                // Client Info
                VStack(alignment: .trailing, spacing: 4) {
                    Text("ESTIMATE")
                        .font(.system(size: 32, weight: .black))
                        .foregroundStyle(.blue)
                    
                    Spacer()
                        .frame(height: 10)
                    
                    if let client = project.client {
                        Text("FOR:")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.secondary)
                        
                        Text(client.name)
                            .font(.system(size: 14, weight: .bold))
                        
                        if let company = client.companyName {
                            Text(company)
                                .font(.system(size: 12))
                        }
                        
                        if let address = client.address {
                            Text(address)
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding(.bottom, 20)
            
            Divider()
            
            // Project Details
            VStack(alignment: .leading, spacing: 8) {
                Text(project.title)
                    .font(.system(size: 18, weight: .bold))
                
                if let desc = project.projectDescription {
                    Text(desc)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Date: \(Date(), style: .date)")
                    Spacer()
                    if let jobType = project.jobType {
                        Text("Project Type: \(jobType.name)")
                    }
                }
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
            }
            .padding(.vertical, 10)
            
            // Itemized Table
            VStack(spacing: 0) {
                // Table Header
                HStack {
                    Text("Description").frame(maxWidth: .infinity, alignment: .leading)
                    Text("Quantity").frame(width: 80, alignment: .center)
                    Text("Labor").frame(width: 80, alignment: .trailing)
                    Text("Total").frame(width: 100, alignment: .trailing)
                }
                .font(.system(size: 10, weight: .bold))
                .padding(.vertical, 8)
                .padding(.horizontal, 4)
                .background(Color.secondary.opacity(0.1))
                
                // Table Rows
                ForEach(project.scopeItems) { item in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.displayName)
                                .font(.system(size: 11, weight: .semibold))
                            if let desc = item.itemDescription {
                                Text(desc)
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if let firstResource = item.scopeItemResources.first {
                            Text("\(firstResource.quantity as NSDecimalNumber) \(firstResource.unit.abbreviation)")
                                .font(.system(size: 11))
                                .frame(width: 80, alignment: .center)
                        } else {
                            Text("-")
                                .font(.system(size: 11))
                                .frame(width: 80, alignment: .center)
                        }
                        
                        Text("\((item.laborHours ?? 0) as NSDecimalNumber)h")
                            .font(.system(size: 11))
                            .frame(width: 80, alignment: .trailing)
                        
                        Text(formatCurrency(item.estimatedCost))
                            .font(.system(size: 11, weight: .semibold))
                            .frame(width: 100, alignment: .trailing)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 4)
                    
                    Divider()
                }
            }
            
            Spacer()
            
            // Totals
            HStack {
                Spacer()
                VStack(alignment: .trailing, spacing: 6) {
                    summaryRow(label: "Material Cost:", value: formatCurrency(project.totalMaterialCost))
                    summaryRow(label: "Labor Cost:", value: formatCurrency(project.totalLaborCost))
                    if project.totalFixedCost > 0 {
                        summaryRow(label: "Fixed Costs:", value: formatCurrency(project.totalFixedCost))
                    }
                    
                    Divider()
                        .frame(width: 200)
                    
                    HStack {
                        Text("ESTIMATED TOTAL")
                            .font(.system(size: 14, weight: .black))
                        Spacer()
                        Text(formatCurrency(project.totalScopeCost))
                            .font(.system(size: 18, weight: .black))
                            .foregroundStyle(.blue)
                    }
                    .frame(width: 250)
                }
            }
            .padding(.top, 20)
            
            // Footer / Signature Area
            VStack(alignment: .leading, spacing: 20) {
                Text("NOTES")
                    .font(.system(size: 10, weight: .bold))
                
                Text("This estimate is valid for 30 days. Final pricing may vary based on site conditions or changes in scope.")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 40) {
                    VStack(alignment: .leading) {
                        Divider().frame(width: 200)
                        Text("Client Signature").font(.system(size: 8))
                    }
                    
                    VStack(alignment: .leading) {
                        Divider().frame(width: 200)
                        Text("Date").font(.system(size: 8))
                    }
                }
                .padding(.top, 40)
            }
        }
        .padding(40) // Standard margins
        .frame(width: pageWidth, height: pageHeight)
        .background(Color.white)
    }
    
    private func summaryRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 11, weight: .medium))
        }
        .frame(width: 200)
    }
    
    private func formatCurrency(_ value: Decimal) -> String {
        value.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD"))
    }
}
