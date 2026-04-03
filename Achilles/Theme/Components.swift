import SwiftUI

// MARK: - Tactical Card

struct TacticalCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(Theme.spacingMD)
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                    .strokeBorder(Theme.border, lineWidth: 0.5)
            )
    }
}

// MARK: - Stat Readout

struct StatReadout: View {
    let label: String
    let value: String
    let unit: String
    var color: Color = Theme.textPrimary

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.uppercased())
                .font(Theme.label(10, weight: .semibold))
                .foregroundStyle(Theme.textTertiary)
                .tracking(1.2)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(Theme.mono(22, weight: .bold))
                    .foregroundStyle(color)
                Text(unit)
                    .font(Theme.mono(12))
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue("\(value) \(unit)")
    }
}

// MARK: - Progress Bar

struct TacticalProgressBar: View {
    let progress: Double
    var color: Color = Theme.olive
    var height: CGFloat = 6

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Theme.surface)
                RoundedRectangle(cornerRadius: 2)
                    .fill(color)
                    .frame(width: geo.size.width * min(progress, 1.0))
                    .animation(Theme.snapAnimation, value: progress)
            }
        }
        .frame(height: height)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Progress bar")
        .accessibilityValue("\(Int(min(progress, 1.0) * 100)) percent")
    }
}

// MARK: - Ring Progress

struct RingProgress: View {
    let progress: Double
    var color: Color = Theme.olive
    var lineWidth: CGFloat = 6
    var size: CGFloat = 60

    var body: some View {
        ZStack {
            Circle()
                .stroke(Theme.surface, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(Theme.snapAnimation, value: progress)
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Progress")
        .accessibilityValue("\(Int(min(progress, 1.0) * 100)) percent")
    }
}

// MARK: - Tactical Button

struct TacticalButton: View {
    let title: String
    var icon: String? = nil
    var style: ButtonStyle = .primary
    let action: () -> Void

    enum ButtonStyle {
        case primary, secondary, ghost, danger
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.spacingSM) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                }
                Text(title.uppercased())
                    .font(Theme.label(14, weight: .bold))
                    .tracking(1.0)
            }
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, Theme.spacingLG)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .strokeBorder(borderColor, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: .black
        case .secondary: Theme.amber
        case .ghost: Theme.textSecondary
        case .danger: Theme.danger
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .primary: Theme.amber
        case .secondary: Theme.amber.opacity(0.12)
        case .ghost: .clear
        case .danger: Theme.danger.opacity(0.12)
        }
    }

    private var borderColor: Color {
        switch style {
        case .primary: Theme.amber
        case .secondary: Theme.amber.opacity(0.3)
        case .ghost: Theme.border
        case .danger: Theme.danger.opacity(0.3)
        }
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    var action: (() -> Void)? = nil
    var actionLabel: String = "View All"

    var body: some View {
        HStack {
            Text(title.uppercased())
                .font(Theme.label(12, weight: .bold))
                .foregroundStyle(Theme.textTertiary)
                .tracking(1.5)
            Spacer()
            if let action {
                Button(action: action) {
                    Text(actionLabel.uppercased())
                        .font(Theme.label(10, weight: .semibold))
                        .foregroundStyle(Theme.amber)
                        .tracking(1.0)
                }
            }
        }
    }
}

// MARK: - Day Selector

struct DaySelector: View {
    @Binding var selectedDate: Date

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.spacingSM) {
                    ForEach(-14...14, id: \.self) { offset in
                        let date = Calendar.current.date(byAdding: .day, value: offset, to: .now)!
                        let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                        Button {
                            withAnimation(Theme.snapAnimation) { selectedDate = date }
                        } label: {
                            VStack(spacing: 2) {
                                Text(date.formatted(.dateTime.weekday(.abbreviated)).uppercased())
                                    .font(Theme.label(9, weight: .semibold))
                                    .foregroundStyle(isSelected ? Theme.amber : Theme.textTertiary)
                                    .tracking(0.8)
                                Text(date.formatted(.dateTime.day()))
                                    .font(Theme.mono(16, weight: isSelected ? .bold : .medium))
                                    .foregroundStyle(isSelected ? Theme.textPrimary : Theme.textSecondary)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, Theme.spacingSM)
                            .background(isSelected ? Theme.olive.opacity(0.2) : .clear)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                                    .strokeBorder(isSelected ? Theme.olive : .clear, lineWidth: 1)
                            )
                        }
                        .id(offset)
                    }
                }
                .padding(.horizontal, Theme.spacingMD)
            }
            .onAppear { proxy.scrollTo(0, anchor: .center) }
        }
    }
}

// MARK: - Macro Ring Trio

struct MacroRingTrio: View {
    let protein: Double
    let carbs: Double
    let fat: Double
    let proteinTarget: Double
    let carbsTarget: Double
    let fatTarget: Double

    var body: some View {
        HStack(spacing: Theme.spacingLG) {
            macroRing("PROTEIN", value: protein, target: proteinTarget, color: Theme.proteinColor)
            macroRing("CARBS", value: carbs, target: carbsTarget, color: Theme.carbsColor)
            macroRing("FAT", value: fat, target: fatTarget, color: Theme.fatColor)
        }
    }

    private func macroRing(_ label: String, value: Double, target: Double, color: Color) -> some View {
        VStack(spacing: Theme.spacingSM) {
            ZStack {
                RingProgress(
                    progress: target > 0 ? value / target : 0,
                    color: color,
                    lineWidth: 5,
                    size: 52
                )
                Text("\(Int(value))")
                    .font(Theme.mono(13, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
            }
            VStack(spacing: 1) {
                Text(label)
                    .font(Theme.label(9, weight: .bold))
                    .foregroundStyle(Theme.textTertiary)
                    .tracking(1.0)
                Text("\(Int(value))/\(Int(target))g")
                    .font(Theme.mono(10))
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue("\(Int(value)) of \(Int(target)) grams")
    }
}

// MARK: - Corinthian Helmet Icon

struct HelmetIcon: View {
    var size: CGFloat = 20
    var color: Color = Theme.amber

    var body: some View {
        Canvas { ctx, canvasSize in
            let w = canvasSize.width
            let h = canvasSize.height

            var helmet = Path()

            // Dome
            helmet.move(to: CGPoint(x: w * 0.50, y: h * 0.02))
            helmet.addCurve(
                to: CGPoint(x: w * 0.95, y: h * 0.38),
                control1: CGPoint(x: w * 0.78, y: h * 0.02),
                control2: CGPoint(x: w * 0.95, y: h * 0.18)
            )

            // Right cheek guard
            helmet.addCurve(
                to: CGPoint(x: w * 0.82, y: h * 0.92),
                control1: CGPoint(x: w * 0.95, y: h * 0.58),
                control2: CGPoint(x: w * 0.92, y: h * 0.78)
            )
            helmet.addCurve(
                to: CGPoint(x: w * 0.62, y: h * 0.98),
                control1: CGPoint(x: w * 0.76, y: h * 0.98),
                control2: CGPoint(x: w * 0.68, y: h * 0.99)
            )

            // Nose guard right edge
            helmet.addLine(to: CGPoint(x: w * 0.58, y: h * 0.45))
            helmet.addCurve(
                to: CGPoint(x: w * 0.50, y: h * 0.88),
                control1: CGPoint(x: w * 0.55, y: h * 0.60),
                control2: CGPoint(x: w * 0.52, y: h * 0.76)
            )

            // Nose guard left edge (mirror)
            helmet.addCurve(
                to: CGPoint(x: w * 0.42, y: h * 0.45),
                control1: CGPoint(x: w * 0.48, y: h * 0.76),
                control2: CGPoint(x: w * 0.45, y: h * 0.60)
            )
            helmet.addLine(to: CGPoint(x: w * 0.38, y: h * 0.98))

            // Left cheek guard
            helmet.addCurve(
                to: CGPoint(x: w * 0.18, y: h * 0.92),
                control1: CGPoint(x: w * 0.32, y: h * 0.99),
                control2: CGPoint(x: w * 0.24, y: h * 0.98)
            )
            helmet.addCurve(
                to: CGPoint(x: w * 0.05, y: h * 0.38),
                control1: CGPoint(x: w * 0.08, y: h * 0.78),
                control2: CGPoint(x: w * 0.05, y: h * 0.58)
            )

            // Close dome
            helmet.addCurve(
                to: CGPoint(x: w * 0.50, y: h * 0.02),
                control1: CGPoint(x: w * 0.05, y: h * 0.18),
                control2: CGPoint(x: w * 0.22, y: h * 0.02)
            )
            helmet.closeSubpath()

            // Crest ridge
            var crest = Path()
            crest.move(to: CGPoint(x: w * 0.50, y: 0))
            crest.addCurve(
                to: CGPoint(x: w * 0.50, y: h * 0.30),
                control1: CGPoint(x: w * 0.50, y: h * 0.08),
                control2: CGPoint(x: w * 0.50, y: h * 0.20)
            )

            ctx.fill(helmet, with: .color(color))
            ctx.stroke(crest, with: .color(color.opacity(0.6)), lineWidth: w * 0.06)

            // Eye slit cutouts (drawn darker to simulate openings)
            let eyeColor = Theme.background

            // Right eye
            var rightEye = Path()
            rightEye.move(to: CGPoint(x: w * 0.58, y: h * 0.46))
            rightEye.addCurve(
                to: CGPoint(x: w * 0.80, y: h * 0.44),
                control1: CGPoint(x: w * 0.64, y: h * 0.40),
                control2: CGPoint(x: w * 0.74, y: h * 0.39)
            )
            rightEye.addCurve(
                to: CGPoint(x: w * 0.58, y: h * 0.46),
                control1: CGPoint(x: w * 0.74, y: h * 0.50),
                control2: CGPoint(x: w * 0.64, y: h * 0.52)
            )
            rightEye.closeSubpath()

            // Left eye
            var leftEye = Path()
            leftEye.move(to: CGPoint(x: w * 0.42, y: h * 0.46))
            leftEye.addCurve(
                to: CGPoint(x: w * 0.20, y: h * 0.44),
                control1: CGPoint(x: w * 0.36, y: h * 0.40),
                control2: CGPoint(x: w * 0.26, y: h * 0.39)
            )
            leftEye.addCurve(
                to: CGPoint(x: w * 0.42, y: h * 0.46),
                control1: CGPoint(x: w * 0.26, y: h * 0.50),
                control2: CGPoint(x: w * 0.36, y: h * 0.52)
            )
            leftEye.closeSubpath()

            ctx.fill(rightEye, with: .color(eyeColor))
            ctx.fill(leftEye, with: .color(eyeColor))
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

// MARK: - Nav Bar Brand

struct NavBarBrand: View {
    let tabName: String
    var trailingContent: AnyView? = nil

    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: 10) {
                Image("AppLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 30)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 1) {
                    Text("ACHILLES")
                        .font(Theme.label(9, weight: .bold))
                        .foregroundStyle(Theme.amber)
                        .tracking(3)
                    Text(tabName)
                        .font(Theme.heading(18))
                        .foregroundStyle(Theme.textPrimary)
                        .tracking(2)
                }
            }
            Spacer()
            if let trailingContent {
                trailingContent
            }
        }
        .padding(.horizontal, Theme.spacingMD)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
}

// MARK: - View Extensions

extension View {
    func tacticalBackground() -> some View {
        self.background(Theme.background)
    }
}
