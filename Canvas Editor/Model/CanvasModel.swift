//
//  CanvasModel.swift
//  Canvas Editor
//
//  Created by Kanishk Vijaywargiya on 14/05/22.
//

import Foundation
import SwiftUI

// MARK: Holds each stack item view
struct CanvasModel: Identifiable {
    var id = UUID().uuidString
    var view: AnyView // MARK: AnyView for more customizations
    
    // MARK: Gesture properties
    // for dragging
    var offset: CGSize = .zero
    var lastOffset: CGSize = .zero
    // for scaling
    var scale: CGFloat = 1
    var lastScale: CGFloat = 1
    // for rotation
    var rotation: Angle = .zero
    var lastRotation: Angle = .zero
}
