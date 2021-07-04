//
//  EsightApp.swift
//  Esight
//
//  Created by 陳奕利 on 2021/6/27.
//

import SwiftUI
import UserNotifications

@main
struct EsightApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appdelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    // status (menu) bar item
    var statusbarItem: NSStatusItem?
    var popOver = NSPopover()
    // notification
    @AppStorage(Settings.WorkTimeKey) var worktime = 40
    @AppStorage(Settings.FullScreenKey) var fullscreen = true
    @AppStorage(Settings.Twenty_TewntyKey) var twenty_twenty = false
    // timer
    var timer: DispatchSourceTimer?
    var timerData: AppTimer!
    var leftMinute: Int = 0
    var notificationWindow: NSWindow!
    // menubar popover
    @objc func togglePopover(_ sender: AnyObject?) {
        // show
        func showPopup(_: AnyObject?) {
            if let button = statusbarItem?.button {
                popOver.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
        // close
        func closePopover(_ sender: AnyObject?) {
            popOver.performClose(sender)
        }
        if popOver.isShown {
            closePopover(sender)
        } else {
            showPopup(sender)
        }
    }

    func applicationDidFinishLaunching(_: Notification) {
        //
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
        //
        timerData = AppTimer()
        func createMenuBarView() {
            let menuBar = MenuBar(Timer: timer, timerData: timerData)
            popOver.behavior = .transient
            popOver.animates = true
            popOver.contentViewController = NSViewController()
            popOver.contentViewController?.view = NSHostingView(rootView: menuBar)
            // create menu-bar button
            statusbarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
            statusbarItem?.button?.action = #selector(togglePopover)
        }
        createMenuBarView()
        // \\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
        func pushNotification() {
            // Notification View
            func createNotificationView() {
                notificationWindow = NSWindow(
                    contentRect: NSRect(
                        x: 0, y: 0, width: NSScreen.main!.frame.width,
                        height: NSScreen.main!.frame.height
                    ),
                    styleMask: [.closable, .fullSizeContentView],
                    backing: .buffered,
                    defer: false
                )
                notificationWindow.center()
                notificationWindow.level = .floating
                notificationWindow.orderFrontRegardless()
                notificationWindow.contentView = NSHostingView(rootView: NotificationView(window: notificationWindow, timerData: timerData))
                notificationWindow.isOpaque = true
                notificationWindow.backgroundColor = NSColor(red: 128, green: 128, blue: 128, alpha: 0.7)
            }
            // \\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
            func timerManager() {
                timer = DispatchSource.makeTimerSource()
                timer?.schedule(deadline: DispatchTime.now(), repeating: .seconds(1), leeway: DispatchTimeInterval.seconds(1))
                // timer start up
                timer?.setRegistrationHandler(handler: {
                    DispatchQueue.main.async {
                        self.timerData.TimerSecond = 0
                        self.timerData.TimerMinute = 0
                        self.timerData.NMleftTime = 0
                        self.leftMinute = 0
                    }
                })
                // timer => repeat every 1 second
                timer?.setEventHandler {
                    DispatchQueue.main.async {
                        if self.twenty_twenty {
                            self.worktime = 20
                        }
                        if self.leftMinute >= 0 {
                            self.leftMinute = self.worktime - self.timerData.TimerMinute
                        }
                        if self.leftMinute > 0 {
                            self.statusbarItem?.button?.image = nil
                            self.statusbarItem?.button?.title = "\(self.leftMinute)min"
                        } else {
                            self.statusbarItem?.button?.image = NSImage(systemSymbolName: "eye.slash.fill", accessibilityDescription: nil)
                        }
                        
                        self.timerData.TimerSecond += 1
                        if self.timerData.TimerSecond == 60 {
                            self.timerData.TimerMinute += 1
                            self.timerData.TimerSecond = 0
                        }
                        if !self.twenty_twenty {
                            // normal mode
                            if self.timerData.TimerMinute == 60 {
                                self.timerData.TimerSecond = 0
                                self.timerData.TimerMinute = 0
                                if self.notificationWindow != nil {
                                    self.notificationWindow.close()
                                }
                            }
                        } else {
                            // 20-20-20 mode
                            if self.timerData.TimerMinute == 20, self.timerData.TimerSecond == 20 {
                                self.timerData.TimerSecond = 0
                                self.timerData.TimerMinute = 0
                                if self.notificationWindow != nil {
                                    self.notificationWindow.close()
                                }
                            }
                        }
                        // show notification
                        if self.timerData.TimerMinute == self.worktime, self.timerData.TimerSecond == 0 {
                            if self.fullscreen {
                                self.timerData.NMleftTime = (60 - self.timerData.TimerMinute) * 60 - self.timerData.TimerSecond
                                createNotificationView()
                            } else {
                                let notification = UNMutableNotificationContent()
                                let body = ["have a cup of coffee ☕️", "have a cup of tea 🫖",
                                            "go jogging 🏃‍♂️🏃‍♀️", "stretch yourself"]
                                notification.title = "Take a break!"
                                notification.body = body.randomElement()!
                                notification.sound = UNNotificationSound.default
                                let request = UNNotificationRequest(identifier: UUID().uuidString, content: notification, trigger: nil)
                                UNUserNotificationCenter.current().add(request)
                            }
                        }
                    }
                }
                timer?.activate()
            }
            timerManager()
        }
        pushNotification()
    }
}
