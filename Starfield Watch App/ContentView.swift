import SwiftUI
struct Star: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: Double
    var angle: Double
    var speed: Double
}

struct ContentView: View {
    @State private var stars: [Star] = []
    @State private var rotation: Double = 0
    @State private var currentTime = Date()
    @State private var isActive = true
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let starUpdateTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Starfield
                ForEach(stars) { star in
                    Circle()
                        .fill(Color.white)
                        .frame(width: star.size, height: star.size)
                        .position(x: star.x, y: star.y)
                        .opacity(star.opacity)
                }
                
                // Digital Clock
                Text(timeString(from: currentTime))
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .background(Color.black)
            .rotationEffect(Angle(degrees: rotation))
            .animation(.linear(duration: 0.1), value: rotation)
            .focusable()
            .digitalCrownRotation($rotation, from: -Double.infinity, through: Double.infinity, by: 1, sensitivity: .high, isContinuous: true, isHapticFeedbackEnabled: true)
            .opacity(isActive ? 1.0 : 0.5)
            .onAppear {
                createStars(in: geometry.size)
            }
            .onChange(of: WKExtension.shared().applicationState) { _, newValue in
                isActive = (newValue == .active)
            }
            .onReceive(timer) { input in
                currentTime = input
            }
            .onReceive(starUpdateTimer) { _ in
                if isActive {
                    updateStars(in: geometry.size)
                }
            }
        }
    }
    
    func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
    
    func createStars(in size: CGSize) {
        let centerX = size.width / 2
        let centerY = size.height / 2
        
        for _ in 0..<50 {
            let angle = Double.random(in: 0...(2 * .pi))
            let speed = Double.random(in: 0.5...2.0)
            stars.append(Star(x: centerX, y: centerY, size: CGFloat.random(in: 1...3), opacity: 0, angle: angle, speed: speed))
        }
    }
    
    func updateStars(in size: CGSize) {
        let centerX = size.width / 2
        let centerY = size.height / 2
        
        for i in 0..<stars.count {
            var star = stars[i]
            let dx = cos(star.angle) * star.speed
            let dy = sin(star.angle) * star.speed
            
            star.x += CGFloat(dx)
            star.y += CGFloat(dy)
            
            let distanceFromCenter = hypot(star.x - centerX, star.y - centerY)
            let maxDistance = hypot(size.width / 2, size.height / 2)
            
            if distanceFromCenter > maxDistance {
                star.x = centerX
                star.y = centerY
                star.opacity = 0
            } else {
                star.opacity = Double(distanceFromCenter / maxDistance)
            }
            
            stars[i] = star
        }
    }
    }

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
