//
//  ContentView.swift
//  WaterApp
//
//
//

import SwiftUI
import UserNotifications


struct ContentView: View {
    @State private var waterIntake: Double = 0
    let dailyGoal: Double = 2000  // in ml

    var body: some View {
        VStack(spacing: 20) {
            Text("Water Intake Tracker")
                .font(.title)

            Text("\(Int(waterIntake)) / \(Int(dailyGoal)) ml")
                .font(.headline)

            ProgressView(value: waterIntake, total: dailyGoal)
                .padding()

            Button("Drink 250ml") {
                waterIntake += 250
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            Spacer()
        }
        .padding()
        .onAppear {
            requestNotificationPermission()
            scheduleReminders()
        }
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Error requesting notifications: \(error)")
            }
        }
    }

    func scheduleReminders() {
        let content = UNMutableNotificationContent()
        content.title = "Time to drink water 💧"
        content.body = "Stay hydrated by drinking a glass of water."

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: true) // every hour
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
}
