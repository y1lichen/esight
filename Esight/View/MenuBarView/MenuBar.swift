//
//  menubar.swift
//  eyes
//
//  Created by 陳奕利 on 2021/6/19.
//

import SwiftUI
import UserNotifications
import LaunchAtLogin

struct MenuBar: View {
    // app setting data
    var setStatusFunc: () -> Void
    @AppStorage(Settings.Twenty_TewntyKey) var twenty_twenty = false
    @AppStorage(Settings.WorkTimeKey) var worktime = 40
    @AppStorage(Settings.FullScreenKey) var fullscreen = true
    //
    @AppStorage(Settings.NMworktimeKey) var nmworktime = 40
    //
    @AppStorage(Settings.NotificationPermitKey) var notificationpermit = false
    //
    let Timer: DispatchSourceTimer?
    // timer data
    @ObservedObject var timerData: AppTimer
    //
    @ObservedObject private var launchAtLogin = LaunchAtLogin.observable
    var body: some View {
        VStack {
            VStack {
            Spacer().frame(height: 10)
            VStack(alignment: .leading) {
                Toggle("Launch at login", isOn: $launchAtLogin.isEnabled).padding(.bottom, 10)
                Picker("Mode", selection: $fullscreen) {
                    Text("fullscreen pop-up").font(.custom("Helvetica", size: 14)).tag(true)
                    Text("notification").font(.custom("Helvetica", size: 14)).tag(false)
                }.frame(width: 180)
                if !fullscreen && !self.notificationpermit {
                    Button("grant permission") {
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {
                            success, _ in
                            if success {
                                self.notificationpermit = true
                            } else {
                                self.notificationpermit = false
                            }
                        }
                    }.offset(x: 50)
                }
                Spacer().frame(height: 15)
                Toggle(isOn: $twenty_twenty) {
                    Text("20-20-20 Rule").font(.custom("Helvetica", size: 14))
                }.onReceive([self.twenty_twenty].publisher.first()) { (value) in
                    if value {
                        self.worktime = 20
                        if self.timerData.TimerMinute >= 20 {
                            self.timerData.Reset()
                        }
                        setStatusFunc()
                    } else {
                        self.worktime = self.nmworktime
                        setStatusFunc()
                    }
                }
                .toggleStyle(CheckboxToggleStyle())
                if !twenty_twenty {
                    Spacer().frame(height: 10)
                    HStack {
                        Stepper(onIncrement: {
                            if self.nmworktime < 50 {
                                self.nmworktime += 5
                            }
                        }, onDecrement: {
                            if self.nmworktime > 20 {
                                self.nmworktime -= 5
                            }
                        }) {
                            Text("work \($nmworktime.wrappedValue)")
                        }.onReceive([self.nmworktime].publisher.first()) { _ in
                            self.worktime = self.nmworktime
                            setStatusFunc()
                        }
                        Text("minutes per hour")
                    }.offset(x: 20)
                }
                Spacer()
                Divider()
                Button(action: {
                    self.timerData.Reset()
                    self.setStatusFunc()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("just take a break")
                    }
                }
                Button(action: {
                    if !self.timerData.onHold {
                        self.Timer?.suspend()
                    } else {
                        self.Timer?.resume()
                        self.timerData.Reset()
                    }
                    self.timerData.onHold.toggle()
                    self.setStatusFunc()
                }) {
                    HStack {
                        Image(systemName: self.timerData.onHold ? "play.fill" : "pause.fill")
                        Text(self.timerData.onHold ? "enable Esight" : "On Hold")
                    }
                }
            }.padding(13)
            }
            if self.timerData.onHold {
                Text("Esight won't work untill you dismiss on-hold")
                    .font(.custom("Helvetica", size: 12))
                    .foregroundColor(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Button(action: {
                NSApp.terminate(self)
            }) {
                Text("quit the app")
            }.padding(.bottom, 5)
        }
        .frame(width: 270, height: 280, alignment: .top)
    }
}
