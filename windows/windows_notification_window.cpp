// windows/windows_notification_window.cpp
#include "windows_notification_window.h"
#include <windows.h>
#include <string>
#include <thread>

bool WindowsNotificationWindow::class_registered_ = false;
int WindowsNotificationWindow::window_count_ = 0;

void WindowsNotificationWindow::SetupWindowClass() {
    if (class_registered_) return;
    
    WNDCLASS wc = {};
    wc.lpfnWndProc = WindowsNotificationWindow::WndProc;
    wc.hInstance = GetModuleHandle(nullptr);
    wc.lpszClassName = L"FlutterNotificationWindow";
    wc.hbrBackground = (HBRUSH)(COLOR_WINDOW + 1);
    wc.hCursor = LoadCursor(nullptr, IDC_ARROW);
    
    RegisterClass(&wc);
    class_registered_ = true;
}

LRESULT CALLBACK WindowsNotificationWindow::WndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam) {
    switch (msg) {
        case WM_CREATE: {
            // Создаем элементы управления
            HWND title = CreateWindow(L"STATIC", L"", WS_CHILD | WS_VISIBLE | SS_LEFT,
                                    10, 10, 280, 20, hwnd, nullptr, GetModuleHandle(nullptr), nullptr);
            HWND message = CreateWindow(L"STATIC", L"", WS_CHILD | WS_VISIBLE | SS_LEFT,
                                      10, 35, 280, 60, hwnd, nullptr, GetModuleHandle(nullptr), nullptr);
            
            SetWindowText(title, L"Заголовок");
            SetWindowText(message, L"Сообщение");
            
            SetTimer(hwnd, 1, 5000, nullptr); // Автозакрытие через 5 секунд
            break;
        }
        case WM_TIMER: {
            if (wParam == 1) {
                KillTimer(hwnd, 1);
                DestroyWindow(hwnd);
            }
            break;
        }
        case WM_LBUTTONDOWN: {
            DestroyWindow(hwnd);
            break;
        }
        case WM_DESTROY: {
            PostQuitMessage(0);
            break;
        }
        default:
            return DefWindowProc(hwnd, msg, wParam, lParam);
    }
    return 0;
}

HWND WindowsNotificationWindow::CreateNotificationWindow(const std::string& title, const std::string& message) {
    SetupWindowClass();
    
    // Конвертируем строки
    std::wstring wtitle(title.begin(), title.end());
    std::wstring wmessage(message.begin(), message.end());
    
    HWND hwnd = CreateWindowEx(
        WS_EX_TOPMOST | WS_EX_TOOLWINDOW,
        L"FlutterNotificationWindow",
        wtitle.c_str(),
        WS_POPUP | WS_BORDER,
        CW_USEDEFAULT, CW_USEDEFAULT,
        320, 120,
        nullptr, nullptr,
        GetModuleHandle(nullptr),
        nullptr
    );
    
    if (hwnd) {
        // Устанавливаем текст
        HWND title_ctrl = GetDlgItem(hwnd, 100);
        HWND message_ctrl = GetDlgItem(hwnd, 101);
        
        if (title_ctrl) SetWindowText(title_ctrl, wtitle.c_str());
        if (message_ctrl) SetWindowText(message_ctrl, wmessage.c_str());
        
        // Позиционируем окно в правом нижнем углу
        RECT screen;
        GetWindowRect(GetDesktopWindow(), &screen);
        SetWindowPos(hwnd, HWND_TOPMOST, 
                    screen.right - 330, 
                    screen.bottom - 150 - (window_count_ * 130),
                    320, 120, SWP_SHOWWINDOW);
        
        ShowWindow(hwnd, SW_SHOW);
        UpdateWindow(hwnd);
        window_count_++;
    }
    
    return hwnd;
}

void WindowsNotificationWindow::ShowNotification(const std::string& title, const std::string& message) {
    CreateNotificationWindow(title, message);
}