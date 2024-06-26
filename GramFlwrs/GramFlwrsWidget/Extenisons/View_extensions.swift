//
//  View_extensions.swift
//  GramFlwrs
//
//  Created by Aisultan Askarov on 26.06.2024.
//

import SwiftUI

struct WidgetBackgroundModifier: ViewModifier {
    var backgroundView: AnyView

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .containerBackground(for: .widget) {
                    backgroundView
                }
        } else {
            content
                .background(backgroundView)
        }
    }
}

import SwiftUI

struct ContentMarginsModifier: ViewModifier {
    var margin: CGFloat

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .contentMargins(margin)
        } else {
            content
                .padding(margin)
        }
    }
}

extension View {
    func widgetBackground<Background: View>(_ backgroundView: Background) -> some View {
        self.modifier(WidgetBackgroundModifier(backgroundView: AnyView(backgroundView)))
    }
    
    func widgetContentMargins(_ margin: CGFloat) -> some View {
        self.modifier(ContentMarginsModifier(margin: margin))
    }
}
