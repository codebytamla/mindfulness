//
//  MeditationAnimatedBackground.swift
//  mindfulness
//
//  Created by Claude on 2/9/2025.
//

import SwiftUI
import UIKit

extension UIColor {
    convenience init(_ color: Color) {
        let components = color.components
        self.init(red: components.r, green: components.g, blue: components.b, alpha: components.a)
    }
}

extension Color {
    var components: (r: Double, g: Double, b: Double, a: Double) {
        let uiColor = UIColor(self)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (Double(red), Double(green), Double(blue), Double(alpha))
    }
}

struct MeditationAnimatedBackground: View {
    @Environment(\.theme) var theme
    
    var body: some View {
        ZStack {
            // Core Animation background
            AnimatedBackgroundView(theme: theme)
                .ignoresSafeArea()
            
            // Breathing circle overlay
            BreathingCircleView(theme: theme)
        }
    }
}

// MARK: - Core Animation Background
struct AnimatedBackgroundView: UIViewRepresentable {
    let theme: ThemeColors
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        setupAnimatedBackground(in: view)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update background when theme changes
        uiView.layer.sublayers?.removeAll()
        setupAnimatedBackground(in: uiView)
    }
    
    private func setupAnimatedBackground(in view: UIView) {
        // 1. Animated gradient background
        setupGradientBackground(in: view)
        
        // 2. Floating particle system
        setupParticleSystem(in: view)
        
        // 3. Wave-like motion overlay
        setupWaveOverlay(in: view)
    }
    
    // MARK: - Gradient Background
    private func setupGradientBackground(in view: UIView) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = UIScreen.main.bounds
        
        // Use theme colors
        let color1 = UIColor(theme.bgGradientStart)
        let color2 = UIColor(theme.bgGradientEnd)
        let color3 = UIColor(theme.primary.opacity(0.3))
        let color4 = UIColor(theme.accent.opacity(0.2))
        
        gradientLayer.colors = [color1.cgColor, color2.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        // Animate gradient colors
        let colorAnimation = CAKeyframeAnimation(keyPath: "colors")
        colorAnimation.values = [
            [color1.cgColor, color2.cgColor],
            [color2.cgColor, color3.cgColor],
            [color3.cgColor, color4.cgColor],
            [color4.cgColor, color1.cgColor],
            [color1.cgColor, color2.cgColor]
        ]
        colorAnimation.duration = 20.0
        colorAnimation.repeatCount = .infinity
        colorAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        gradientLayer.add(colorAnimation, forKey: "colorShift")
        
        // Animate gradient position
        let positionAnimation = CAKeyframeAnimation(keyPath: "startPoint")
        positionAnimation.values = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 1, y: 0),
            CGPoint(x: 1, y: 1),
            CGPoint(x: 0, y: 1),
            CGPoint(x: 0, y: 0)
        ]
        positionAnimation.duration = 30.0
        positionAnimation.repeatCount = .infinity
        positionAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        gradientLayer.add(positionAnimation, forKey: "gradientPosition")
    }
    
    // MARK: - Particle System
    private func setupParticleSystem(in view: UIView) {
        let emitterLayer = CAEmitterLayer()
        emitterLayer.frame = view.bounds
        
        // Position emitter at top of screen
        emitterLayer.emitterPosition = CGPoint(x: view.bounds.width / 2, y: -50)
        emitterLayer.emitterSize = CGSize(width: view.bounds.width, height: 1)
        emitterLayer.emitterShape = .line
        
        // Create particle cell
        let particleCell = CAEmitterCell()
        particleCell.contents = createParticleImage().cgImage
        
        // Particle properties
        particleCell.birthRate = 0.5
        particleCell.lifetime = 25.0
        particleCell.lifetimeRange = 10.0
        
        // Movement
        particleCell.velocity = 20.0
        particleCell.velocityRange = 15.0
        particleCell.emissionRange = .pi / 4
        
        // Size
        particleCell.scale = 0.3
        particleCell.scaleRange = 0.2
        particleCell.scaleSpeed = -0.02
        
        // Color and opacity - use theme accent color
        particleCell.color = UIColor(theme.accent.opacity(0.6)).cgColor
        particleCell.alphaSpeed = -0.02
        particleCell.alphaRange = 0.2
        
        // Add gentle floating motion
        particleCell.xAcceleration = 5.0
        particleCell.yAcceleration = 15.0
        
        emitterLayer.emitterCells = [particleCell]
        view.layer.addSublayer(emitterLayer)
        
        // Animate emitter position for gentle sway
        let swayAnimation = CAKeyframeAnimation(keyPath: "emitterPosition.x")
        let centerX = view.bounds.width / 2
        swayAnimation.values = [
            centerX - 100,
            centerX,
            centerX + 100,
            centerX
        ]
        swayAnimation.duration = 15.0
        swayAnimation.repeatCount = .infinity
        swayAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        emitterLayer.add(swayAnimation, forKey: "emitterSway")
    }
    
    // MARK: - Wave Overlay
    private func setupWaveOverlay(in view: UIView) {
        let waveLayer = CAShapeLayer()
        waveLayer.frame = view.bounds
        
        // Create wave path
        let wavePath = createWavePath(in: view.bounds)
        waveLayer.path = wavePath.cgPath
        waveLayer.fillColor = UIColor.clear.cgColor
        waveLayer.strokeColor = UIColor(theme.accent.opacity(0.1)).cgColor
        waveLayer.lineWidth = 2.0
        
        view.layer.addSublayer(waveLayer)
        
        // Animate wave
        let waveAnimation = CAKeyframeAnimation(keyPath: "path")
        var wavePaths: [CGPath] = []
        
        for i in 0...60 {
            let phase = Double(i) * .pi / 30.0
            let path = createWavePath(in: view.bounds, phase: phase)
            wavePaths.append(path.cgPath)
        }
        
        waveAnimation.values = wavePaths
        waveAnimation.duration = 8.0
        waveAnimation.repeatCount = .infinity
        waveAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        
        waveLayer.add(waveAnimation, forKey: "waveMotion")
        
        // Add second wave layer for depth
        let waveLayer2 = CAShapeLayer()
        waveLayer2.frame = view.bounds
        waveLayer2.path = createWavePath(in: view.bounds, amplitude: 30, wavelength: 150).cgPath
        waveLayer2.fillColor = UIColor.clear.cgColor
        waveLayer2.strokeColor = UIColor(theme.primary.opacity(0.05)).cgColor
        waveLayer2.lineWidth = 1.5
        
        view.layer.addSublayer(waveLayer2)
        
        // Animate second wave (different speed for organic feel)
        let waveAnimation2 = CAKeyframeAnimation(keyPath: "path")
        var wavePaths2: [CGPath] = []
        
        for i in 0...40 {
            let phase = Double(i) * .pi / 20.0
            let path = createWavePath(in: view.bounds, amplitude: 30, wavelength: 150, phase: phase)
            wavePaths2.append(path.cgPath)
        }
        
        waveAnimation2.values = wavePaths2
        waveAnimation2.duration = 12.0
        waveAnimation2.repeatCount = .infinity
        waveAnimation2.timingFunction = CAMediaTimingFunction(name: .linear)
        
        waveLayer2.add(waveAnimation2, forKey: "waveMotion2")
    }
    
    // MARK: - Helper Functions
    private func createParticleImage() -> UIImage {
        let size = CGSize(width: 8, height: 8)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.white.cgColor)
        context.fillEllipse(in: CGRect(origin: .zero, size: size))
        
        // Add subtle glow
        context.setShadow(offset: .zero, blur: 3, color: UIColor.white.cgColor)
        context.fillEllipse(in: CGRect(origin: .zero, size: size))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
    
    private func createWavePath(in bounds: CGRect, amplitude: CGFloat = 40, wavelength: CGFloat = 200, phase: Double = 0) -> UIBezierPath {
        let path = UIBezierPath()
        let width = bounds.width
        let height = bounds.height
        let midY = height * 0.7 // Position wave in lower portion
        
        path.move(to: CGPoint(x: -wavelength, y: midY))
        
        for x in stride(from: -wavelength, through: width + wavelength, by: 2) {
            let relativeX = x / wavelength
            let sine = sin(relativeX * 2 * .pi + phase)
            let y = midY + amplitude * sine
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        return path
    }
}

// MARK: - Breathing Circle
struct BreathingCircleView: View {
    let theme: ThemeColors
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.3
    
    var body: some View {
        ZStack {
            // Outer breathing circle
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            theme.accent.opacity(0.3),
                            theme.primary.opacity(0.4),
                            theme.accent.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
                .frame(width: 200, height: 200)
                .scaleEffect(scale)
                .opacity(opacity)
            
            // Inner breathing circle
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            theme.glowColor,
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 80
                    )
                )
                .frame(width: 160, height: 160)
                .scaleEffect(scale * 0.8)
                .opacity(opacity * 0.7)
            
            // Center dot
            Circle()
                .fill(theme.accent.opacity(0.8))
                .frame(width: 6, height: 6)
                .scaleEffect(scale * 0.5)
        }
        .onAppear {
            startBreathingAnimation()
        }
    }
    
    private func startBreathingAnimation() {
        // Breathing rhythm: 4 seconds in, 4 seconds out
        withAnimation(
            Animation.easeInOut(duration: 4.0)
                .repeatForever(autoreverses: true)
        ) {
            scale = 1.2
        }
        
        withAnimation(
            Animation.easeInOut(duration: 4.0)
                .repeatForever(autoreverses: true)
        ) {
            opacity = 0.6
        }
    }
}

// MARK: - Preview
#Preview {
    MeditationAnimatedBackground()
        .environment(\.theme, WaterTheme.riverFlow.colors)
}