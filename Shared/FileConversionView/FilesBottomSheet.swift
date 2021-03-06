//
//  BottomSheetView.swift
//  iOS
//
//  Created by Gabriel Soria Souza on 12/07/20.
//

import SwiftUI

fileprivate enum Constants {
	static let radius: CGFloat = 16
	static let indicatorHeight: CGFloat = 6
	static let indicatorWidth: CGFloat = 60
	static let snapRatio: CGFloat = 0.25
	static let minHeightRatio: CGFloat = 0.0
}

struct FilesBottomSheetView<Content: View>: View {
	@Binding var isOpen: Bool
	@GestureState private var translation: CGFloat = 0
	
	let maxHeight: CGFloat
	let minHeight: CGFloat
	let content: Content
	
	init(isOpen: Binding<Bool>, maxHeight: CGFloat, @ViewBuilder content: () -> Content) {
		self.minHeight = maxHeight * Constants.minHeightRatio
		self.maxHeight = maxHeight
		self.content = content()
		self._isOpen = isOpen
	}
	
	private var offset: CGFloat {
		isOpen ? 0 : maxHeight - minHeight
	}
	
	private var indicator: some View {
		RoundedRectangle(cornerRadius: Constants.radius)
			.fill(Color.secondary)
			.frame(
				width: Constants.indicatorWidth,
				height: Constants.indicatorHeight).onTapGesture {
				self.isOpen.toggle()
			}
	}
	
	var body: some View {
		GeometryReader { geometry in
			VStack(spacing: 0) {
				self.indicator.padding()
				self.content
			}
			.frame(width: geometry.size.width, height: self.maxHeight, alignment: .top)
			.background(Color(.secondarySystemBackground))
			.cornerRadius(Constants.radius)
			.frame(height: geometry.size.height, alignment: .bottom)
			.offset(y: max(self.offset + self.translation, 0))
			.animation(.interactiveSpring())
			.gesture(
				DragGesture().updating(self.$translation) { value, state, _ in
					state = value.translation.height
				}.onEnded { value in
					let snapDistance = self.maxHeight * Constants.snapRatio
					guard abs(value.translation.height) > snapDistance else {
						return
					}
					self.isOpen = value.translation.height < 0
				}
			)
		}
	}
}
