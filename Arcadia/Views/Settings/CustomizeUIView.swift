//
//  CustomizeUIView.swift
//  Arcadia
//
//  Created by Davide Andreoli on 06/10/24.
//

import SwiftUI
import ArcadiaCore

struct CustomizeUIView: View {
    @AppStorage("directionPadButtonScale") private var directionPadButtonScale: Double = 1
    @AppStorage("directionPadButtonSpacing") private var directionPadButtonSpacing: Double = 5
    @AppStorage("actionPadButtonScale") private var actionPadButtonScale: Double = 1
    @AppStorage("actionPadButtonSpacing") private var actionPadButtonSpacing: Double = 5
    @AppStorage("smallButtonScale") private var smallButtonScale: Double = 1
    @AppStorage("shoulderButtonScale") private var shoulderButtonScale: Double = 1
    @AppStorage("buttonOpacity") private var buttonOpacity: Double = 1
    @AppStorage("customizeGameViewBackgroundColor") private var customizeGameViewBackgroundColor: Bool = false
    @AppStorage("gameViewBackgroundColor") var gameViewBackgroundColor: Color = .black
    
    var body: some View {
        Form {
            Section(header: Text("Button size"), footer: Text("Use the sliders to adjust button scale, double tap a slider to restore its original value")) {
                VStack(alignment: .leading) {
                    Text("Direction Pad")
                        .font(.headline)
                    Slider(value: $directionPadButtonScale, in: 0.5...1.5, step: 0.1)
                    {
                        Text("Scale")
                    } minimumValueLabel: {
                        Text("0.5")
                    } maximumValueLabel: {
                        Text("1.5")
                    }
                    .onTapGesture(count: 2) {
                        directionPadButtonScale = 1
                    }
                    HStack {
                        Spacer()
                        DPadView()
                            .disabled(true)
                        Spacer()
                    }
                }
                VStack(alignment: .leading) {
                    Text("Action Pad")
                        .font(.headline)
                    Slider(value: $actionPadButtonScale, in: 0.5...1.5, step: 0.1)
                    {
                        Text("Scale")
                    } minimumValueLabel: {
                        Text("0.5")
                    } maximumValueLabel: {
                        Text("1.5")
                    }
                    .onTapGesture(count: 2) {
                        actionPadButtonScale = 1
                    }
                    HStack {
                        Spacer()
                        ActionButtonsView(numberOfButtons: 4)
                            .disabled(true)
                        Spacer()
                    }
                }
                VStack(alignment: .leading) {
                    Text("Small buttons")
                        .font(.headline)
                    Slider(value: $smallButtonScale, in: 0.5...1.5, step: 0.1)
                    {
                        Text("Scale")
                    } minimumValueLabel: {
                        Text("0.5")
                    } maximumValueLabel: {
                        Text("1.5")
                    }
                    .onTapGesture(count: 2) {
                        smallButtonScale = 1
                    }
                    HStack {
                        Spacer()
                        CircleButtonView(arcadiaCoreButton: .arcadiaButton, size: 35*smallButtonScale)
                            .disabled(true)
                        Spacer()
                    }
                }
                VStack(alignment: .leading) {
                    Text("Shoulder buttons")
                        .font(.headline)
                    Slider(value: $shoulderButtonScale, in: 0.5...1.5, step: 0.1)
                    {
                        Text("Scale")
                    } minimumValueLabel: {
                        Text("0.5")
                    } maximumValueLabel: {
                        Text("1.5")
                    }
                    .onTapGesture(count: 2) {
                        shoulderButtonScale = 1
                    }
                    HStack {
                        Spacer()
                        CircleButtonView(arcadiaCoreButton: .joypadR, height: 40*shoulderButtonScale, width: 70*shoulderButtonScale)
                            .disabled(true)
                        Spacer()
                    }
                }
            }
            Section(header: Text("Button spacing"), footer: Text("Use the sliders to adjust button spacing, double tap a slider to restore its original value")) {
                VStack(alignment: .leading) {
                    Text("Direction Pad")
                        .font(.headline)
                    Slider(value: $directionPadButtonSpacing, in: 1...10, step: 1.0)
                    {
                        Text("Spacing")
                    } minimumValueLabel: {
                        Text("1")
                    } maximumValueLabel: {
                        Text("10")
                    }
                    .onTapGesture(count: 2) {
                        directionPadButtonSpacing = 5
                    }
                    HStack {
                        Spacer()
                        DPadView()
                            .disabled(true)
                        Spacer()
                    }
                }
                VStack(alignment: .leading) {
                    Text("Action Pad")
                        .font(.headline)
                    Slider(value: $actionPadButtonSpacing, in: 1...10, step: 1.0)
                    {
                        Text("Spacing")
                    } minimumValueLabel: {
                        Text("1")
                    } maximumValueLabel: {
                        Text("10")
                    }
                    .onTapGesture(count: 2) {
                        actionPadButtonSpacing = 5
                    }
                    HStack {
                        Spacer()
                        ActionButtonsView(numberOfButtons: 4)
                            .disabled(true)
                        Spacer()
                    }
                }
            }
            Section(header: Text("Button opacity"), footer: Text("Use the slider to adjust button opacity, double tap the slider to restore its original value. A lower value means that the button will be more transparent.")) {
                VStack(alignment: .leading) {
                    Slider(value: $buttonOpacity, in: 0.3...1, step: 0.1)
                    {
                        Text("Opacity")
                    } minimumValueLabel: {
                        Text("0.3")
                    } maximumValueLabel: {
                        Text("1")
                    }
                    .onTapGesture(count: 2) {
                        buttonOpacity = 1
                    }
                    HStack {
                        Spacer()
                        CircleButtonView(arcadiaCoreButton: .joypadA, size: 50*actionPadButtonScale)
                            .disabled(true)
                        Spacer()
                    }
                }
            }
            
            Section(header: Text("Game view background color"), footer: Text("Use the toggle to turn on the customization, and pick a color using the slider. To go back to the default behaviour, simply turn off the toggle.")) {
                Toggle(isOn: $customizeGameViewBackgroundColor) {
                    Text("Customize background color")
                }
                ColorPicker("Game view background color", selection: $gameViewBackgroundColor, supportsOpacity: false)
            }
            
            Section(header: Text("Final preview")) {
                ZStack {
                    if customizeGameViewBackgroundColor {
                        Rectangle()
                            .fill(gameViewBackgroundColor)
                    }
                    VStack {
                        Spacer()
                        ArcadiaButtonLayout(layoutElements: [.dPad, .start, .select, .backButtonsFirstRow, .fourActionButtons])
                    }

                }
                .frame(minHeight: 300)
            }
        }
    }
}

#Preview {
    CustomizeUIView()
        .environment(ArcadiaCoreEmulationState.sharedInstance)
        .environment(InputController.shared)
}
