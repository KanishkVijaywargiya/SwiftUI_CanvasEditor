//
//  CanvasViewModel.swift
//  Canvas Editor
//
//  Created by Kanishk Vijaywargiya on 14/05/22.
//

import Foundation
import SwiftUI

// MARK: Holds all the canvas data
class CanvasViewModel: NSObject, ObservableObject {
    //MARK: Canvas stack
    @Published var stack: [CanvasModel] = []
    
    // MARK: Image picker properties
    @Published var showImagePicker: Bool = false
    @Published var imageData: Data = .init(count: 0)
    
    // MARK: Error properties
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    // MARK: Delete Alert
    @Published var currentlyTappedItem: CanvasModel?
    @Published var showDeleteAlert: Bool = false
    
    // MARK: Adding images to stack
    func addImageToStack(image: UIImage) {
        // MARK: Creating SwiftUI Image View & Apending into the stack
        let imageView = Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 150, height: 150)
        
        stack.append(CanvasModel(view: AnyView(imageView)))
    }
    
    // MARK: Saving Canvas Image
    func saveCanvasImage<Content: View>(height: CGFloat, @ViewBuilder content: @escaping () -> Content) {
        // That's happening bcoz of SafeArea top value
        // It is pushing view to bottom
        // removing SafeArea Top value
        let uiView = UIHostingController(rootView: content().padding(.top, -safeArea().top))
        let frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: height))
        uiView.view.frame = frame
        
        // MARK: Drawing image
        // If you require higher quality of image then adjust the scaling to 2-3 etc...
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
        uiView.view.drawHierarchy(in: frame, afterScreenUpdates: true)
        
        // retrieving current drawn image
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // closing context
        UIGraphicsEndImageContext()
        
        if let newImage = newImage {
            writeToAlbum(image: newImage)
        }
    }
    
    // MARK: Writing to album
    func writeToAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompletion(_:didFInishSavingWithError:contextInfo:)), nil)
    }
    
    @objc
    func saveCompletion(_ image: UIImage, didFInishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            self.errorMessage = error.localizedDescription
            self.showError.toggle()
        } else {
            self.errorMessage = "Saved Successfully !"
            self.showError.toggle()
        }
    }
    
    func safeArea() -> UIEdgeInsets {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return .zero }
        guard let safeArea = screen.windows.first?.safeAreaInsets else { return .zero }
        return safeArea
    }
}
