import SwiftUI

struct WaterLogSheet: View {
    @Environment(\.dismiss) private var dismiss
    let dailyLog: DailyLog?
    let target: Double
    @State private var customAmount = ""

    private var current: Double { dailyLog?.waterIntakeOz ?? 0 }

    var body: some View {
        NavigationStack {
            VStack(spacing: Theme.spacingLG) {
                ZStack {
                    RingProgress(progress: target > 0 ? current / target : 0, color: Theme.waterColor, lineWidth: 10, size: 140)
                    VStack(spacing: 2) {
                        Text("\(Int(current))")
                            .font(Theme.mono(32, weight: .bold))
                            .foregroundStyle(Theme.waterColor)
                        Text("/ \(Int(target)) oz")
                            .font(Theme.mono(13))
                            .foregroundStyle(Theme.textSecondary)
                    }
                }

                HStack(spacing: Theme.spacingMD) {
                    waterQuickButton("+8 oz", amount: 8)
                    waterQuickButton("+16 oz", amount: 16)
                    waterQuickButton("+32 oz", amount: 32)
                }

                HStack(spacing: Theme.spacingSM) {
                    TextField("", text: $customAmount, prompt: Text("Custom oz").foregroundStyle(Theme.textTertiary))
                        .font(Theme.mono(15))
                        .foregroundStyle(Theme.textPrimary)
                        .keyboardType(.numberPad)
                        .padding(10)
                        .background(Theme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))

                    Button {
                        if let amount = Double(customAmount) {
                            dailyLog?.waterIntakeOz += amount
                            HapticService.impact(.light)
                            customAmount = ""
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Theme.waterColor)
                    }
                    .accessibilityLabel("Add custom water amount")
                }
                .padding(.horizontal, Theme.spacingLG)

                Spacer()
            }
            .padding(.top, Theme.spacingXL)
            .background(Theme.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("HYDRATION")
                        .font(Theme.heading(16))
                        .foregroundStyle(Theme.textPrimary)
                        .tracking(2)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Theme.amber)
                }
            }
        }
        .presentationDetents([.medium])
        .preferredColorScheme(.dark)
    }

    private func waterQuickButton(_ label: String, amount: Double) -> some View {
        Button {
            dailyLog?.waterIntakeOz += amount
            HapticService.impact(.light)
        } label: {
            Text(label)
                .font(Theme.mono(13, weight: .bold))
                .foregroundStyle(Theme.waterColor)
                .padding(.horizontal, Theme.spacingMD)
                .padding(.vertical, 12)
                .background(Theme.waterColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                        .strokeBorder(Theme.waterColor.opacity(0.3), lineWidth: 1)
                )
        }
        .accessibilityLabel("Add \(Int(amount)) ounces of water")
    }
}
