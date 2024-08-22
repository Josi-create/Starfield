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
    @State private var lastRotation: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(stars) { star in
                    Circle()
                        .fill(Color.white)
                        .frame(width: star.size, height: star.size)
                        .position(x: star.x, y: star.y)
                        .opacity(star.opacity)
                }
            }
            .background(Color.black)
            .rotationEffect(Angle(degrees: rotation * 10)) // Multiply by 10 for faster rotation
            .focusable()
            .digitalCrownRotation($rotation, from: 0, through: 360, by: 0.1, sensitivity: .medium, isContinuous: true, isHapticFeedbackEnabled: true)
            .onAppear {
                createStars(in: geometry.size)
            }
            .onReceive(Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()) { _ in
                updateStars(in: geometry.size)
                updateRotation()
            }
        }
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
            
            // Apply rotation to the star movement
            let rotationRadians = (rotation - lastRotation) * .pi / 180 * 10
            let rotatedDx = dx * cos(rotationRadians) - dy * sin(rotationRadians)
            let rotatedDy = dx * sin(rotationRadians) + dy * cos(rotationRadians)
            
            star.x += CGFloat(rotatedDx)
            star.y += CGFloat(rotatedDy)
            
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
    func updateRotation() {
        // Update lastRotation to keep track of the change in rotation
        lastRotation = rotation
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
