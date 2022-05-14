//
//  Canvas.swift
//  Canvas Editor
//
//  Created by Kanishk Vijaywargiya on 14/05/22.
//

import SwiftUI

struct Canvas: View {
    var height: CGFloat = 250
    @EnvironmentObject var vm: CanvasViewModel
    
    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            
            ZStack {
                Color.white
                ForEach($vm.stack) {$stackItem in
                    CanvasSubView(stackItem: $stackItem) {
                        stackItem.view
                    } moveFront: {
                        moveViewToFront(stackItem: stackItem)
                    } onDelete: {
                        // MARK: Showing alert if mistakenly tapped
                        vm.currentlyTappedItem = stackItem
                        vm.showDeleteAlert.toggle()
                    }
                }
            }
            .frame(width: size.width, height: size.height)
        }
        // MARK: Your desired height
        .frame(height: height)
        .clipped()
        .alert("Are you sure to delete View?", isPresented: $vm.showDeleteAlert) {
            Button(role: .destructive) {
                if let item = vm.currentlyTappedItem {
                    let index = getIndex(stackItem: item)
                    vm.stack.remove(at: index)
                }
            } label: {
                Text("Yes")
            }
            
        }
    }
    
    func getIndex(stackItem: CanvasModel) -> Int {
        return vm.stack.firstIndex { item in
            return item.id == stackItem.id
        } ?? 0
    }
    
    func moveViewToFront(stackItem: CanvasModel) {
        // finding index & moving to last
        // since in ZStack last item will show on first
        let currentIndex = getIndex(stackItem: stackItem)
        let lastIndex = vm.stack.count - 1
        
        // simple swapping
        vm.stack.insert(vm.stack.remove(at: currentIndex), at: lastIndex)
    }
}

struct Canvas_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}

// MARK: Canvas sub view
struct CanvasSubView<Content: View>: View {
    var content: Content
    @Binding var stackItem: CanvasModel
    @State var hapticScale: CGFloat = 1 // MARK: Haptic Animation
    var moveFront: ()->()
    var onDelete: ()->()
    
    init(stackItem: Binding<CanvasModel>, @ViewBuilder content: @escaping ()-> Content, moveFront: @escaping ()->(), onDelete: @escaping ()->()) {
        self.content = content()
        self._stackItem = stackItem
        self.moveFront = moveFront
        self.onDelete = onDelete
    }
    
    var body: some View {
        content
            .rotationEffect(stackItem.rotation)
            .scaleEffect(stackItem.scale < 0.4 ? 0.4 : stackItem.scale) // Safe scaling
            .scaleEffect(hapticScale)
            .offset(stackItem.offset)
            .gesture(
                TapGesture(count: 2)
                    .onEnded({ _ in
                        onDelete()
                    })
                    .simultaneously(with:
                                        LongPressGesture(minimumDuration: 0.3)
                        .onEnded({ _ in
                            // For Haptic Feedback & little scaling animation while moving view to front
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            withAnimation(.easeInOut) {
                                hapticScale = 1.2
                            }
                            withAnimation(.easeInOut.delay(0.1)) {
                                hapticScale = 1
                            }
                            moveFront()
                        })
                                   )
            )
            .gesture(
                DragGesture()
                    .onChanged({ value in
                        stackItem.offset = CGSize(
                            width: stackItem.lastOffset.width + value.translation.width,
                            height: stackItem.lastOffset.height + value.translation.height)
                    })
                    .onEnded({ value in
                        stackItem.lastOffset = stackItem.offset
                    })
            ) // MARK: Drag gesture
            .gesture(
                MagnificationGesture()
                    .onChanged({ value in
                        // MARK: It starts with existing scaling which is 1
                        // Removing that to retrieve exact scaling
                        stackItem.scale = stackItem.lastScale + (value - 1)
                    })
                    .onEnded({ value in
                        stackItem.lastScale = stackItem.scale
                    })
                    .simultaneously(with:
                                        RotationGesture()
                        .onChanged({ value in
                            stackItem.rotation = stackItem.lastRotation + value
                        })
                            .onEnded({ value in
                                stackItem.lastRotation = stackItem.rotation
                            })
                                   )// MARK: Rotation gesture
            ) // MARK: Magnification gesture
    }
}
