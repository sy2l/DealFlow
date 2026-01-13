//
//  PDFExporter.swift
//  DealFlow
//
//  Service de génération de rapports PDF
//

import UIKit
import PDFKit

struct PDFExporter {
    
    // MARK: - Configuration
    
    private static let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842) // A4
    private static let padding: CGFloat = 40
    private static let lineHeight: CGFloat = 20
    
    // MARK: - Export principal
    
    /// Génère un rapport PDF de visite
    /// - Parameters:
    ///   - visitTitle: Titre de la visite
    ///   - summaryLines: Lignes de résumé (KPIs)
    ///   - images: Images à inclure (max 4 pour MVP)
    ///   - watermark: Texte du watermark (nil pour version Pro)
    /// - Returns: URL du fichier PDF généré
    /// - Throws: Erreur si la génération échoue
    static func exportVisitReport(
        visitTitle: String,
        summaryLines: [String],
        images: [UIImage],
        watermark: String?
    ) throws -> URL {
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        
        let data = renderer.pdfData { context in
            // Page 1: Résumé
            context.beginPage()
            var y = drawHeader(visitTitle: visitTitle, in: context)
            y = drawSummary(lines: summaryLines, startY: y, in: context)
            
            // Watermark si version gratuite
            if let watermark = watermark {
                drawWatermark(text: watermark, in: context)
            }
            
            // Page 2: Photos (si disponibles)
            if !images.isEmpty {
                context.beginPage()
                drawPhotosPage(images: images, in: context)
                
                if let watermark = watermark {
                    drawWatermark(text: watermark, in: context)
                }
            }
        }
        
        // Sauvegarde dans le répertoire temporaire
        let fileName = "DealFlow-\(UUID().uuidString).pdf"
        let outURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try data.write(to: outURL, options: .atomic)
        
        return outURL
    }
    
    // MARK: - Dessin des sections
    
    private static func drawHeader(visitTitle: String, in context: UIGraphicsPDFRendererContext) -> CGFloat {
        var y = padding
        
        // Logo / Titre de l'app
        let appTitleAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .medium),
            .foregroundColor: UIColor.systemGray
        ]
        ("DealFlow - Rapport de visite" as NSString).draw(
            at: CGPoint(x: padding, y: y),
            withAttributes: appTitleAttr
        )
        y += 24
        
        // Titre de la visite
        let titleAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24, weight: .bold),
            .foregroundColor: UIColor.black
        ]
        (visitTitle as NSString).draw(
            at: CGPoint(x: padding, y: y),
            withAttributes: titleAttr
        )
        y += 36
        
        // Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.locale = Locale(identifier: "fr_FR")
        let dateStr = "Généré le \(dateFormatter.string(from: Date()))"
        
        let dateAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11),
            .foregroundColor: UIColor.systemGray
        ]
        (dateStr as NSString).draw(
            at: CGPoint(x: padding, y: y),
            withAttributes: dateAttr
        )
        y += 32
        
        // Ligne de séparation
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: padding, y: y))
        linePath.addLine(to: CGPoint(x: pageRect.width - padding, y: y))
        UIColor.systemGray4.setStroke()
        linePath.lineWidth = 1
        linePath.stroke()
        y += 24
        
        return y
    }
    
    private static func drawSummary(lines: [String], startY: CGFloat, in context: UIGraphicsPDFRendererContext) -> CGFloat {
        var y = startY
        
        // Titre de section
        let sectionTitleAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
            .foregroundColor: UIColor.black
        ]
        ("Résumé financier" as NSString).draw(
            at: CGPoint(x: padding, y: y),
            withAttributes: sectionTitleAttr
        )
        y += 28
        
        // Lignes de résumé
        let bodyAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13),
            .foregroundColor: UIColor.darkGray
        ]
        
        for line in lines {
            if y > pageRect.height - 100 { break }
            
            (line as NSString).draw(
                at: CGPoint(x: padding, y: y),
                withAttributes: bodyAttr
            )
            y += lineHeight
        }
        
        return y
    }
    
    private static func drawPhotosPage(images: [UIImage], in context: UIGraphicsPDFRendererContext) {
        var y = padding
        
        // Titre de section
        let sectionTitleAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
            .foregroundColor: UIColor.black
        ]
        ("Photos de la visite" as NSString).draw(
            at: CGPoint(x: padding, y: y),
            withAttributes: sectionTitleAttr
        )
        y += 28
        
        // Grille 2x2 pour les photos
        let photoWidth = (pageRect.width - padding * 3) / 2
        let photoHeight = photoWidth * 0.75
        
        for (index, image) in images.prefix(4).enumerated() {
            let col = index % 2
            let row = index / 2
            
            let x = padding + CGFloat(col) * (photoWidth + padding)
            let photoY = y + CGFloat(row) * (photoHeight + 16)
            
            let rect = CGRect(x: x, y: photoY, width: photoWidth, height: photoHeight)
            
            // Dessiner l'image en conservant le ratio
            let imageRect = AVMakeRect(aspectRatio: image.size, insideRect: rect)
            image.draw(in: imageRect)
            
            // Bordure
            UIColor.systemGray4.setStroke()
            let borderPath = UIBezierPath(roundedRect: imageRect, cornerRadius: 4)
            borderPath.lineWidth = 1
            borderPath.stroke()
        }
    }
    
    private static func drawWatermark(text: String, in context: UIGraphicsPDFRendererContext) {
        let watermarkAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 48, weight: .bold),
            .foregroundColor: UIColor(white: 0.9, alpha: 0.5)
        ]
        
        let textSize = (text as NSString).size(withAttributes: watermarkAttr)
        let x = (pageRect.width - textSize.width) / 2
        let y = (pageRect.height - textSize.height) / 2
        
        // Rotation pour effet diagonal
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.saveGState()
        ctx?.translateBy(x: pageRect.width / 2, y: pageRect.height / 2)
        ctx?.rotate(by: -.pi / 6)
        ctx?.translateBy(x: -pageRect.width / 2, y: -pageRect.height / 2)
        
        (text as NSString).draw(
            at: CGPoint(x: x, y: y),
            withAttributes: watermarkAttr
        )
        
        ctx?.restoreGState()
    }
}

// MARK: - Helper pour le ratio d'image

import AVFoundation
