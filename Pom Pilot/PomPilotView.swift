//
//  PomPilotView.swift
//  Pom Pilot
//
//  Created by Walter de Bruijn on 07/11/2025.
//

import SwiftUI
import Combine

struct PomPilotView: View {
    var body: some View {
        ContentView()
    }
}

struct ContentView: View {
    enum Mode: String, CaseIterable, Identifiable {
        case work = "Work"
        case shortBreak = "Short Break"
        case longBreak = "Long Break"

        var id: String { rawValue }

        var duration: Int {
            switch self {
            case .work: return 25 * 60
            case .shortBreak: return 5 * 60
            case .longBreak: return 15 * 60
            }
        }

        var accentColor: Color {
            switch self {
            case .work: return .red
            case .shortBreak: return .gray.opacity(0.25)
            case .longBreak: return .gray.opacity(0.25)
            }
        }
    }

    @State private var mode: Mode = .work
    @State private var remaining: Int = Mode.work.duration
    @State private var isRunning = false
    @State private var sessionsCompleted = 0

    @State private var timerCancellable: AnyCancellable?
    @State private var showSettings = false

    @State private var currentWorkMinutes: Int = 25
    @State private var currentShortMinutes: Int = 5
    @State private var currentLongMinutes: Int = 15

    var body: some View {
        VStack(spacing: 0) {
            // Top segmented selector
            HStack(spacing: 12) {
                ForEach(Mode.allCases) { m in
                    Button {
                        switchMode(to: m)
                    } label: {
                        Text(m.rawValue)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(m == mode ? .white : .primary)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 14)
                            .frame(height: 32)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(m == mode ? Color.red : Color.gray.opacity(0.12))
                            )
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 8)

            Divider()

            // Center timer
            VStack(spacing: 18) {
                Text(timeString(from: remaining))
                    .font(.system(size: 96, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .padding(.top, 28)

                // Thin progress bar
                LinearProgress(value: progress)
                    .frame(height: 6)
                    .padding(.horizontal, 48)
                    .padding(.bottom, 8)

                // Controls
                HStack(spacing: 16) {
                    Button {
                        toggleTimer()
                    } label: {
                        Label(isRunning ? "Pause" : "Start", systemImage: isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 15, weight: .semibold))
                            .padding(.vertical, 10)
                            .padding(.horizontal, 26)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.black))
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)

                    Button {
                        resetTimer()
                    } label: {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                            .font(.system(size: 15, weight: .semibold))
                            .padding(.vertical, 10)
                            .padding(.horizontal, 22)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(NSColor.windowBackgroundColor))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 6)

                Text("Sessions completed: \(sessionsCompleted)")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .padding(.top, 6)

                Spacer()
            }

            // Bottom bar
            Divider()
            HStack(alignment: .center) {
                Button {
                    // Open settings or show a sheet if you prefer
                    showSettings = true
                } label: {
                    Label("Settings", systemImage: "gearshape")
                        .font(.system(size: 13, weight: .medium))
                }
                .buttonStyle(.plain)
                .padding(.vertical, 10)
                .sheet(isPresented: $showSettings) {
                    PomPilotSettingsView(
                        workMinutes: currentWorkMinutes,
                        shortBreakMinutes: currentShortMinutes,
                        longBreakMinutes: currentLongMinutes
                    ) { w, s, l in
                        // Persist to AppStorage or your model
                        currentWorkMinutes = w
                        currentShortMinutes = s
                        currentLongMinutes = l
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 16)
        }
        .onDisappear { stopTimer() }
        .onChange(of: mode) { oldValue, newValue in
            // keep progress consistent when switching modes
            remaining = newValue.duration
        }
    }

    private var progress: Double {
        guard mode.duration > 0 else { return 0 }
        return 1.0 - Double(remaining) / Double(mode.duration)
    }

    // MARK: - Actions

    private func switchMode(to newMode: Mode) {
        stopTimer()
        mode = newMode
        remaining = newMode.duration
    }

    private func toggleTimer() {
        isRunning ? stopTimer() : startTimer()
        isRunning.toggle()
    }

    private func resetTimer() {
        stopTimer()
        isRunning = false
        remaining = mode.duration
    }

    private func startTimer() {
        timerCancellable = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                tick()
            }
    }

    private func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    private func tick() {
        guard remaining > 0 else {
            // finished
            stopTimer()
            isRunning = false
            if mode == .work { sessionsCompleted += 1 }
            // Optional: auto-switch to a break here if you want.
            return
        }
        remaining -= 1
    }

    private func timeString(from totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// Simple linear progress matching a thin, subtle style
struct LinearProgress: View {
    var value: Double // 0...1

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.gray.opacity(0.25))
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.gray)
                    .frame(width: max(0, min(1, value)) * geo.size.width)
            }
        }
    }
}
