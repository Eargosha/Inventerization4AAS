// windows/windows_notification_window.h
#ifndef RUNNER_WINDOWS_NOTIFICATION_WINDOW_H_
#define RUNNER_WINDOWS_NOTIFICATION_WINDOW_H_

#include <windows.h>
#include <string>

class WindowsNotificationWindow {
public:
    static HWND CreateNotificationWindow(const std::string& title, const std::string& message);
    static void ShowNotification(const std::string& title, const std::string& message);
    
private:
    static LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam);
    static void SetupWindowClass();
    static bool class_registered_;
    static int window_count_;
};

#endif