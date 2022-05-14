//
//  Home.swift
//  Canvas Editor
//
//  Created by Kanishk Vijaywargiya on 14/05/22.
//

import SwiftUI

struct Home: View {
    @StateObject var vm = CanvasViewModel()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // MARK: Canvas View
            Canvas().environmentObject(vm)
            
            // MARK: Canvas Actions
            HStack(spacing: 15) {
                Button(action: {}) {
                    Image(systemName: "xmark")
                        .font(.title3)
                }
                
                Spacer()
                
                Button(action: {
                    vm.showImagePicker.toggle()
                }) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.title3)
                }
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxHeight: .infinity, alignment: .top)
            
            // MARK: Save button
            Button(action: {
                // MARK; Saving canvas image
                vm.saveCanvasImage(height: 250) {
                    Canvas().environmentObject(vm)
                }
            }) {
                Image(systemName: "arrow.down.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.white)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        }
        .preferredColorScheme(.dark)
        .alert(vm.errorMessage, isPresented: $vm.showError) {}
        .sheet(isPresented: $vm.showImagePicker) {
            if let image = UIImage(data: vm.imageData) {
                vm.addImageToStack(image: image)
            }
        } content: {
            ImagePicker(showPicker: $vm.showImagePicker, imageData: $vm.imageData)
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
