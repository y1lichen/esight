//
//  menubar.swift
//  eyes
//
//  Created by 陳奕利 on 2021/6/19.
//

import SwiftUI
import UserNotifications

struct MenuBar: View {
    // app setting data
    @AppStorage(Settings.Twenty_TewntyKey) var twenty_twenty = false
    @AppStorage(Settings.WorkTimeKey) var worktime = 40
    @AppStorage(Settings.FullScreenKey) var fullscreen = true
    @AppStorage(Settings.OnHold) var onhold = false
    //
    var body: some View {
        VStack {
            Spacer().frame(maxHeight: 15)
            Text("Esight").fontWeight(.heavy).font(.custom("PT Serif", size: 24)).kerning(1.0)
            Divider()
            Spacer().frame(maxHeight: 20)
            VStack(alignment: .leading) {
            Picker("Mode", selection: $fullscreen) {
                Text("fullscreen pop-up").font(.custom("Helvetica",size: 14)).tag(true)
                Text("notification").font(.custom("Helvetica",size: 14)).tag(false)
            }.frame(width: 180)
                if !fullscreen {
                    Button("grant permission") {
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge]) {
                            success, error in
                            if success {
                                print("success")
                            } else if let error = error {
                                print(error.localizedDescription)
                            }
                        }
                    }.offset(x: 50)
                }
                Spacer().frame(maxHeight: 20)
                Toggle(isOn: $twenty_twenty) {
                    Text("20-20-20 Rule").font(.custom("Helvetica",size: 14))
                       }.toggleStyle(CheckboxToggleStyle())
            if !twenty_twenty {
                Spacer().frame(maxHeight: 10)
                HStack {
                    Stepper(onIncrement: {
                        if worktime < 50 {
                            worktime+=5
                        }
                    }, onDecrement: {
                        if worktime > 20 {
                            worktime-=5
                        }
                    }) {
                        Text("work \($worktime.wrappedValue)")
                    }
                    Text("minutes per hour")
                }.offset(x: 20)
            }
            Spacer()
            Divider()
            Spacer()
                Button(action: {onhold.toggle()}) {
                    HStack {
                        Image(systemName: $onhold.wrappedValue ? "play.fill": "pause.fill")
                        Text($onhold.wrappedValue ? "enable Esight": "On Hold")
                    }
                }
            }.padding(8)
            if onhold {
                Text("Esight won't work untill you dismiss on-hold")
                    .font(.custom("Helvetica",size: 12))
                    .foregroundColor(.red)
                    .fixedSize(horizontal: false, vertical: true)
                }
            Button(action: {
                NSApp.terminate(self)
            }) {
                Text("quit the app")
            }.padding(.bottom, 5)
        }.frame(width: 270, height: 270, alignment: .top)
    }
}

