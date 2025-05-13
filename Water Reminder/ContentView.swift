//
//  ContentView.swift
//  WaterApp
//
//
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    @AppStorage("weight") private var weight: Double = 0
    @AppStorage("waterDrank") private var waterDrank: Double = 0
    @AppStorage("lastResetDate") private var lastResetDate: String = ""

    @State private var checkInMessage: String?
    @State private var selection = 0 // 0 = Hydration, 1 = Settings

    var dailyGoal: Double {
        weight * 0.5
    }

    var body: some View {
        TabView(selection: $selection) {
            // 💧 Hydration Tab
            ScrollView {
                VStack(spacing: 20) {
                    Text("💧 Daily Hydration")
                        .font(.title)
                        .padding(.top)
                        .foregroundColor(.white)

                    if weight > 0 {
                        Text("You should drink about \(Int(dailyGoal)) oz of water.")
                            .foregroundColor(.white)

                        let bottles = dailyGoal / 16.9
                        Text("That's about \(String(format: "%.1f", bottles)) bottles.")
                            .foregroundColor(.gray)

                        Button("Check In") {
                            let reminderCount = 8.0
                            let perReminder = dailyGoal / reminderCount
                            waterDrank += perReminder
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)

                        ProgressView(value: min(waterDrank, dailyGoal), total: dailyGoal)
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                            .padding(.horizontal)

                    } else {
                        Text("Please set your weight in Settings.")
                            .foregroundColor(.red)
                    }

                    Spacer()
                }
                .padding(.top, 40)
                .frame(maxWidth: .infinity)
            }
            .background(Color(red: 0.1, green: 0.1, blue: 0.12))
            .onAppear {
                checkDailyReset()
            }
            .tabItem {
                Label("Hydration", systemImage: "drop.fill")
            }
            .tag(0)

            // ⚙️ Settings Tab
            SettingsView(selection: $selection, onTabLeave: {
                if selection != 1 {
                    checkInMessage = nil
                }
            })

            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(1)
        }
        .accentColor(.white)
    }

    func checkDailyReset() {
        let today = formattedDate(Date())
        if lastResetDate != today {
            waterDrank = 0
            lastResetDate = today
        }
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

struct SettingsView: View {
    @AppStorage("weight") private var weight: Double = 0
    @AppStorage("waterDrank") private var waterDrank: Double = 0

    @State private var localWeight: Double = 0
    @State private var showDebug = false
    @State private var saveMessage: String?
    @State private var testNoteMessage: String?
    @State private var resetMessage: String?

    @Binding var selection: Int
    var onTabLeave: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Text("⚙️ Settings")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(.top)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Weight (lbs):")
                        .foregroundColor(.white)

                    TextField("Enter weight", value: $localWeight, format: .number)
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(Color(red: 0.2, green: 0.2, blue: 0.25))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }

                Button("Apply Weight") {
                    weight = localWeight
                    scheduleDefaultReminders()
                    saveMessage = "✅ Reminders scheduled from 8 AM to 10 PM."
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                if let msg = saveMessage {
                    Text(msg)
                        .foregroundColor(.green)
                        .padding(.top, -20)
                }

                Toggle("Debug Mode", isOn: $showDebug)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    .foregroundColor(.white)
                    .padding(.top, 10)

                if showDebug {
                    VStack(spacing: 16) {
                        Button("Send Test Notification") {
                            sendTestNotification()
                            testNoteMessage = "✅ Sending test notification in 10 seconds"
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)

                        if let note = testNoteMessage {
                            Text(note)
                                .foregroundColor(.green)
                                .font(.subheadline)
                        }

                        Button("Reset Progress") {
                            waterDrank = 0
                            resetMessage = "✅ Progress has been reset"
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)

                        if let reset = resetMessage {
                            Text(reset)
                                .foregroundColor(.green)
                                .font(.subheadline)
                        }
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 40)
            .padding(.bottom, 140)
            .onAppear {
                localWeight = weight
            }
            .onDisappear {
                onTabLeave()
                saveMessage = nil
                testNoteMessage = nil
                resetMessage = nil
            }
        }
        .background(Color(red: 0.1, green: 0.1, blue: 0.12))
        .frame(maxWidth: .infinity)
        .ignoresSafeArea()
    }

    func scheduleDefaultReminders() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        let content = UNMutableNotificationContent()
        content.title = "💧 Water Reminder"
        content.body = "Time to drink water!"
        content.sound = .default

        for hour in stride(from: 8, through: 22, by: 2) {
            var components = DateComponents()
            components.hour = hour
            components.minute = 0

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
    }

    func sendTestNotification() {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "💧 Water Reminder"
        content.body = "Time to drink water!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
}
