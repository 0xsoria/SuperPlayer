//
//  ProgressBar.swift
//  SuperPlayer
//
//  Created by Gabriel Soria Souza on 29/08/20.
//

import SwiftUI

struct ProgressBar: View {
	
	var value: Float
	
    var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .leading) {
				Rectangle().frame(width: geometry.size.width,
								  height: geometry.size.height)
					.opacity(0.3)
					.foregroundColor(Color(UIColor.systemTeal))
				Rectangle().frame(width: min(CGFloat(self.value) * geometry.size.width, geometry.size.width),
								  height: geometry.size.height)
					.foregroundColor(Color(UIColor.systemBlue))
					.animation(.linear)
			}.cornerRadius(45.0)
		}
    }
}

struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
		Text("")
    }
}
