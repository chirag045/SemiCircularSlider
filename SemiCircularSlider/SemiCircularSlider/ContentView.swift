//
//  ContentView.swift
//  SemiCircularSlider
//
//  Created by Chirag Gujarati on 25/10/25.
//

import SwiftUI

struct ContentView: View {
    @State var sliderCurrentValue : Double = 20
    @State var sliderMinValue : Int = 0
    @State var sliderMaxValue : Int = 100

    var body: some View {
        HStack {
            Spacer()
            
            SemiCircularSlider(progressValue: $sliderCurrentValue)
                .onChangedValue { newValue in
                    sliderCurrentValue = newValue
                }
                .setInsideCircleView {
                    VStack {
                        Text("Value")
                            .foregroundStyle(.black)
                            .padding(.top, 20)
                        
                        Text("\(String.init(format: "%.0f", sliderCurrentValue))")
                            .fontWeight(.bold)
                            .foregroundStyle(.blue)
                        
                        Spacer()
                    }
                    .frame(alignment: .top)
                }
                .setLeftView{
                    Text("\(sliderMinValue)")
                        .foregroundStyle(.black)
                        .rotationEffect(.init(degrees: 180))
                }
                .setRightView {
                    Text("\(sliderMaxValue)")
                        .foregroundStyle(.black)
                        .rotationEffect(.init(degrees: 180))
                }
                .setMinValue(Double(sliderMinValue))
                .setMaxValue(Double(sliderMaxValue))
            
            Spacer()
        }
        .offset(y: 50)
    }
}

#Preview {
    ContentView()
}
