//
//  SemiCircularSlider.swift
//  SemiCircularSlider
//
//  Created by Chirag Gujarati on 25/10/25.
//

import SwiftUI

struct SemiCircularSlider: View {
    private var sliderWidth : CGFloat = 300
    private var thumbSize : CGFloat = 30
    
    private var sliderColor : [Color] = [.pink, .mint, .pink, .white]
    private var thumbColor : Color = .green
    private var progressTextColor : Color = Color(hex: "#3C37CC")
    private var circleBackgroundColor : [Color] = [Color(hex: "#E5EAFF"), Color(hex: "#A1A9D1")]
    private var text : String = ""
    private var textColor : Color = Color(hex: "#1B1B1B")
    
    @Binding var progressValue : Double
    @State private var angle : Double = 0.0
    
    private var minValue: Double = 0
    private var maxValue: Double = 100
    private var step: Double = 1
    
    private var onChangeValue : ((Double) -> Void)? = nil
    
    private var insideCircleView: AnyView?
    private var leftView: AnyView?
    private var rightView: AnyView?
    
    init(progressValue: Binding<Double>) {
        _progressValue = progressValue
    }
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(.clear)
                    .frame(width: sliderWidth * (65/100), height: sliderWidth * (65/100))
                    .overlay {
                        insideCircleView
                    }
                    .rotationEffect(.init(degrees: 180))
                
                Circle()
                    .trim(from: 0,to: 0.5)
                    .stroke(Color(hex: "#F3FBFF"), style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .frame(width: sliderWidth, height: sliderWidth)
                
                Circle()
                    .trim(from: 0, to: angle / 360)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: sliderColor.reversed()),
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(180)
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: sliderWidth, height: sliderWidth)
                    .overlay {
                        leftView
                            .offset(x: sliderWidth / 2)
                        
                        rightView
                            .offset(x: -sliderWidth / 2)
                    }
                
                ZStack {
                    Circle()
                        .fill(thumbColor)
                        .frame(width: 40, height: 40)
                    
                    Circle()
                        .fill(.white)
                        .frame(width: 10, height: 10)
                }
                .frame(width: thumbSize,height: thumbSize)
                .offset(x : sliderWidth/2)
                .rotationEffect(.init(degrees: angle))
                .gesture(DragGesture()
                    .onChanged(onChange(value:))
                    .onChanged{_ in
                        onChangeValue?(progressValue)
                    }
                )
            }
            .rotationEffect(.init(degrees: 180))
            .onAppear {
                let snapped = snappedValue(progressValue)
                self.progressValue = snapped
                self.angle = angleFromProgress(snapped)
            }
        }
    }
    
    func onChange(value: DragGesture.Value){
        let vector = CGVector(dx: value.location.x, dy: value.location.y)
        let radians = atan2(vector.dy - 15, vector.dx - 15)
        let tempAngle = radians * 180 / .pi
        let angle = tempAngle < 0 ? 360 + tempAngle : tempAngle
        
        if angle <= 180 {
            let clampedAngle = min(max(angle, 0), 180)
            let range = maxValue - minValue
            let rawValue = (clampedAngle / 180.0) * range + minValue
            let snapped = snappedValue(rawValue)

            self.progressValue = snapped
            self.angle = angleFromProgress(snapped)
        }
    }
    
    private func snappedValue(_ value: Double) -> Double {
        let clamped = min(max(value, minValue), maxValue)
        let s = max(step, 1)
        let snapped = (clamped / s).rounded() * s
        return min(max(snapped, minValue), maxValue)
    }
}

extension SemiCircularSlider {
    
    func setWidth(_ width: CGFloat) -> Self {
        var copy = self
        copy.sliderWidth = width
        return copy
    }
    
    func setThumbSize(_ size: CGFloat) -> Self {
        var copy = self
        copy.thumbSize = size
        return copy
    }
    
    func setSliderColor(_ color : [Color]) -> Self {
        var copy = self
        copy.sliderColor = color
        return copy
    }
    
    func setThumbColor(_ color : Color) -> Self {
        var copy = self
        copy.thumbColor = color
        return copy
    }
    
    func setProgressTextColor(_ color : Color) -> Self {
        var copy = self
        copy.progressTextColor = color
        return copy
    }
    
    func setCircleBackgroundColor(_ color : [Color]) -> Self {
        var copy = self
        copy.circleBackgroundColor = color
        return copy
    }
    
    func setText(_ text : String) -> Self {
        var copy = self
        copy.text = text
        return copy
    }
    
    func setTextColor(_ color : Color) -> Self {
        var copy = self
        copy.textColor = color
        return copy
    }
    
    func setMinValue(_ value : Double) -> Self {
        var copy = self
        copy.minValue = value
        return copy
    }
    
    func setMaxValue(_ value : Double) -> Self {
        var copy = self
        copy.maxValue = value
        return copy
    }
    
    func setStep(_ value: Double) -> Self {
        var copy = self
        copy.step = max(1, value)
        return copy
    }
    
    func onChangedValue(_ value: ((Double)->Void)?) -> Self{
        var copy = self
        copy.onChangeValue = value
        return copy
    }
    
    func setInsideCircleView<T: View>(_ content: () -> T) -> Self {
        var copy = self
        copy.insideCircleView = AnyView(content())
        return copy
    }
    
    func setLeftView<T: View>(_ content: () -> T) -> Self {
        var copy = self
        copy.leftView = AnyView(content())
        return copy
    }
    
    func setRightView<T: View>(_ content: () -> T) -> Self {
        var copy = self
        copy.rightView = AnyView(content())
        return copy
    }
    
    func angleFromProgress(_ value: Double) -> Double {
        let range = maxValue - minValue
        guard range > 0 else { return 0 }
        let clamped = min(max(value, minValue), maxValue)
        let percent = (clamped - minValue) / range
        return percent * 180
    }
}


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    static let themeBlueColor: Color = .init(hex: "#033347")
    static var themeBGColor: Color = .init(hex: "#F3FBFF")
    static let secondaryPurple100: Color = .init(hex: "#FFE5E3FF")
}
