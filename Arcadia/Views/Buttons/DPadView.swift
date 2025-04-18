//
//  ArrowButtonView.swift
//  Arcadia
//
//  Created by Davide Andreoli on 17/05/24.
//

import SwiftUI
import ArcadiaCore

struct DPadView: View {
    
    @AppStorage("useAdvancedDPad") private var useAdvancedDPad = false
    @AppStorage("directionPadButtonScale") private var buttonScale: Double = 1
    @AppStorage("directionPadButtonSpacing") private var directionPadButtonSpacing: Double = 5
    
    var body: some View {
        if useAdvancedDPad {
            VStack(spacing: CGFloat(directionPadButtonSpacing)) {
            
                HStack(spacing: CGFloat(directionPadButtonSpacing)) {
                    CircleButtonView(arcadiaCoreButton: .joypadUpLeft, size:50*buttonScale)
                    CircleButtonView(arcadiaCoreButton: .joypadUp, size:50*buttonScale)
                    CircleButtonView(arcadiaCoreButton: .joypadUpRight, size:50*buttonScale)
                }
                        HStack(spacing: CGFloat(directionPadButtonSpacing)) {
                            CircleButtonView(arcadiaCoreButton: .joypadLeft, size:50*buttonScale)
                            EmptyButtonView(size: 50*buttonScale)
                            CircleButtonView(arcadiaCoreButton: .joypadRight, size:50*buttonScale)
                            
                        }
                HStack(spacing: CGFloat(directionPadButtonSpacing)) {
                    CircleButtonView(arcadiaCoreButton: .joypadDownLeft, size:50*buttonScale)
                    CircleButtonView(arcadiaCoreButton: .joypadDown, size:50*buttonScale)
                    CircleButtonView(arcadiaCoreButton: .joypadDownRight, size:50*buttonScale)
                }
                    }
        } else {
            VStack(spacing: CGFloat(directionPadButtonSpacing)) {
            
                CircleButtonView(arcadiaCoreButton: .joypadUp, size:50*buttonScale)
                        HStack(spacing: CGFloat(directionPadButtonSpacing)) {
                            CircleButtonView(arcadiaCoreButton: .joypadLeft, size:50*buttonScale)
                            EmptyButtonView(size: 50*buttonScale)
                            CircleButtonView(arcadiaCoreButton: .joypadRight, size:50*buttonScale)
                            
                        }
                CircleButtonView(arcadiaCoreButton: .joypadDown, size:50*buttonScale)
                    }
        }
 
    }
}

#Preview {
    HStack {
        Spacer()
        DPadView()
            .environment(ArcadiaCoreEmulationState.sharedInstance)
            .environment(InputController.shared)
        Spacer()
    }
    .frame(width: 50, height: 300)
}

