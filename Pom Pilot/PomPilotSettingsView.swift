//
//  PomPilotSettingsView.swift
//  Pom Pilot
//
//  Created by Walter de Bruijn on 07/11/2025.
//

import SwiftUI

struct PomPilotSettingsView: View {
    @Environment(\.dismiss) private var dismiss

        // Bind or initialize with your stored values (in minutes)
        @State private var workMinutes: Double
        @State private var shortBreakMinutes: Double
        @State private var longBreakMinutes: Double

        /// Called when the user taps Save
        var onSave: (_ workMin: Int, _ shortMin: Int, _ longMin: Int) -> Void

        init(
            workMinutes: Int = 25,
            shortBreakMinutes: Int = 5,
            longBreakMinutes: Int = 15,
            onSave: @escaping (_ workMin: Int, _ shortMin: Int, _ longMin: Int) -> Void
        ) {
            _workMinutes = State(initialValue: Double(workMinutes))
            _shortBreakMinutes = State(initialValue: Double(shortBreakMinutes))
            _longBreakMinutes = State(initialValue: Double(longBreakMinutes))
            self.onSave = onSave
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                Text("Settings")
                    .font(.system(size: 24, weight: .semibold))
                    .padding(.top, 6)

                LabeledSlider(
                    title: "Work Duration",
                    value: $workMinutes,
                    range: 10...60,
                    step: 1
                )

                LabeledSlider(
                    title: "Short Break",
                    value: $shortBreakMinutes,
                    range: 3...15,
                    step: 1
                )

                LabeledSlider(
                    title: "Long Break",
                    value: $longBreakMinutes,
                    range: 10...45,
                    step: 1
                )

                Spacer(minLength: 8)

                HStack {
                    Spacer()
                    Button {
                        onSave(Int(workMinutes), Int(shortBreakMinutes), Int(longBreakMinutes))
                        dismiss()
                    } label: {
                        Text("Save Settings")
                            .font(.system(size: 15, weight: .semibold))
                            .padding(.vertical, 12)
                            .padding(.horizontal, 18)
                            .frame(maxWidth: 320)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.black)
                            )
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
                .padding(.bottom, 8)
            }
            .padding(20)
            .frame(width: 500, height: 340) // feel free to adjust
        }
    }

    /// A title + slider that shows the selected minutes inline
    private struct LabeledSlider: View {
        let title: String
        @Binding var value: Double
        let range: ClosedRange<Double>
        let step: Double

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text("\(title): \(Int(value)) minute\(Int(value) == 1 ? "" : "s")")
                    .font(.system(size: 15, weight: .semibold))

                // Standard Slider with subtle styling to resemble the screenshot
                Slider(value: $value, in: range, step: step)
                    .tint(.black) // knob/filled track
                    .padding(.horizontal, 2)
            }
        }
    }

    // MARK: - Preview & Example Usage

    #Preview {
        PomPilotSettingsView(
            workMinutes: 25,
            shortBreakMinutes: 5,
            longBreakMinutes: 15
        ) { w, s, l in
            print("Saved:", w, s, l)
        }
    }
