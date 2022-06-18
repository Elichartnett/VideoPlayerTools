//
//  CustomSlider.swift
//  VideoPlayerTools
//
//  Created by Eli Hartnett on 6/17/22.
//

import SwiftUI
import Combine

// Operates based off seconds
struct CustomTimer: View {
    
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var updateTimeInterval = 0.1
    @State var isPlaying = false
    @State var wasPlayingBeforeScrub = false
    @State var currentSecond = 0.0
    let totalSeconds: Double
    @State var percentagePassed = 0.0
    @State var scrubberOffset = 0.0
    let scrubberDiameter = 25.0
    var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 2
        formatter.maximumFractionDigits = 0
        return formatter
    }
    
    var body: some View {
        
        // Slider
        GeometryReader { proxy in
            
            VStack {
                
                // Scrubber
                ZStack (alignment: .leading) {
                    
                    Capsule()
                        .fill(Color(uiColor: .gray))
                        .frame(height: 4)
                    
                    Capsule()
                        .fill(.blue)
                        .frame(width: scrubberOffset, height: 4)
                    
                    Circle()
                        .fill(.white)
                        .shadow(color: .black.opacity(0.5), radius: 3)
                        .frame(height: scrubberDiameter)
                        .offset(x: scrubberOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if isPlaying {
                                        wasPlayingBeforeScrub = true
                                    }
                                    isPlaying = false
                                    
                                    // Scrub from middle of scrubber, not leading edge
                                    let fingerPlacement = value.location.x - 10
                                    let maxValidWidth = proxy.size.width - scrubberDiameter
                                    
                                    // Calculate scrubber location based on drag
                                    scrubberOffset = calculateScrubberOffsetWithDrag(attemptedOffset: fingerPlacement, maxOffset: maxValidWidth)
                                    percentagePassed = scrubberOffset / maxValidWidth
                                    currentSecond = percentagePassed * totalSeconds
                                }
                                .onEnded { _ in
                                    isPlaying = wasPlayingBeforeScrub
                                    wasPlayingBeforeScrub = false
                                }
                        )
                        .onReceive(timer) { _ in
                            if isPlaying {
                                let maxValidWidth = proxy.size.width - scrubberDiameter
                                
                                // Calculate scrubber location based on time
                                currentSecond += min(updateTimeInterval, totalSeconds - currentSecond)
                                percentagePassed = currentSecond / totalSeconds
                                withAnimation(.linear(duration: updateTimeInterval)) {
                                    scrubberOffset = percentagePassed * maxValidWidth
                                }
                                
                                if timerIsFinished() {
                                    isPlaying = false
                                    cancelTimer(timer: timer)
                                    percentagePassed = 100
                                    currentSecond = totalSeconds
                                }
                            }
                            // Will receive once when app starts up
                            else {
                                cancelTimer(timer: timer)
                            }
                        }
                }
                
                // Tools
                HStack {
                    
                    Text(secondsToTime(seconds: currentSecond))
                        .frame(maxWidth: .infinity)
                    
                    HStack {
                        
                        Button {
                            let maxValidWidth = proxy.size.width - 20
                            
                            currentSecond = max(0, currentSecond - 15)
                            percentagePassed = currentSecond / totalSeconds
                            scrubberOffset = percentagePassed * maxValidWidth
                            
                        } label: {
                            Image(systemName: "arrowshape.turn.up.left")
                        }
                        
                        Button {
                            if !timerIsFinished() {
                                isPlaying.toggle()
                            }
                        } label: {
                            Image(systemName: isPlaying ? "pause.circle" : "play.circle")
                        }
                        .onChange(of: isPlaying) { _ in
                            if isPlaying {
                                timer = Timer.publish(every: updateTimeInterval, on: .main, in: .common).autoconnect()
                            }
                            else {
                                cancelTimer(timer: timer)
                            }
                        }
                        
                        Button {
                            let maxValidWidth = proxy.size.width - 20
                            
                            currentSecond = min(totalSeconds, currentSecond + 15)
                            percentagePassed = currentSecond / totalSeconds
                            scrubberOffset = percentagePassed * maxValidWidth
                        } label: {
                            Image(systemName: "arrowshape.turn.up.right")
                        }
                    }
                    
                    Text(secondsToTime(seconds: totalSeconds))
                        .frame(maxWidth: .infinity)
                }
            }
            .foregroundColor(.white)
            .font(.title2)
        }
        .frame(height: 50)
        .padding()
        .background(
            Rectangle()
                .fill(Material.ultraThin)
                .cornerRadius(10)
                .frame(height: 100)
        )
    }
    
    func calculateScrubberOffsetWithDrag(attemptedOffset: Double, maxOffset: Double) -> Double {
        if attemptedOffset < 0 {
            return 0
        }
        else if attemptedOffset > maxOffset {
            return maxOffset
        }
        else {
            return attemptedOffset
        }
    }
    
    func cancelTimer(timer: Publishers.Autoconnect<Timer.TimerPublisher>) {
        timer.upstream.connect().cancel()
    }
    
    func secondsToTime(seconds: Double) -> String {
        let minutes = Int((seconds / 60).rounded(.down))
        let seconds = seconds - Double(minutes * 60)
        
        return "\(numberFormatter.string(from: minutes as NSNumber)!):\(numberFormatter.string(from: seconds as NSNumber)!)"
    }
    
    func timerIsFinished() -> Bool {
        return currentSecond + updateTimeInterval >= totalSeconds
    }
}

struct CustomSlider_Previews: PreviewProvider {
    static var previews: some View {
        CustomTimer(totalSeconds: 100)
    }
}
