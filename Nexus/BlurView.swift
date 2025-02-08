
//
//  BlurView.swift
//  NexusApp
//

import SwiftUI
import UIKit

/// Обёртка над UIVisualEffectView для использования blur-эффекта в SwiftUI
struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
