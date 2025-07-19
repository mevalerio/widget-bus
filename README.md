
# WidgetBus: System & Transit Monitor

A macOS desktop widget that provides a real-time overview of your system's performance and live bus arrival information from Transport for London (TfL).

![WidgetBus Screenshot](placeholder.png) <!-- You can replace placeholder.png with an actual screenshot later -->

## Features

- **System Monitoring**:
  - **CPU Usage**: See the current load on your processor cores.
  - **RAM Usage**: Track active memory usage against your system's total memory.
  - **GPU Usage**: Monitor the utilization of your graphics processor.

- **Live Bus Arrivals**:
  - **Geolocation**: Automatically detects your location to find nearby bus stops.
  - **Real-Time Data**: Fetches live arrival predictions for bus stops within a 1-mile radius.
  - **TfL Powered**: Uses the official Transport for London (TfL) Unified API.

## How It Works

The project is composed of three main parts:

1.  **SystemMonitor**: A Swift class that uses native macOS frameworks (`IOKit`, `mach`) to gather low-level system statistics. It is designed to be lightweight and efficient.

2.  **TfLService**: A service class that handles all interactions with the TfL API. It uses `CoreLocation` to get the user's location and `URLSession` to make network requests for bus stop and arrival data.

3.  **WidgetExtension**: A SwiftUI-based widget that presents the data. It uses a `TimelineProvider` to periodically fetch updated information from the monitoring and transit services, ensuring the widget stays current.

## Setup & Installation

To build and run this project, you will need:

- macOS 12.0+ (Monterey) or later
- Xcode 14.0 or later
- A free API key from Transport for London

### Steps:

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/widget-bus.git
    cd widget-bus
    ```

2.  **Get a TfL API Key:**
    - Visit the [TfL API Portal](https://api-portal.tfl.gov.uk/) and register for an account.
    - You will be provided with an **App Key**. Keep this safe.

3.  **Configure the Project:**
    - Open the project in Xcode.
    - Navigate to the `tfl-api/TfLService.swift` file.
    - Find the line `private var apiKey: String = ""` and insert your TfL API key inside the quotes.

4.  **Run the App:**
    - Select the `WidgetBus` scheme and choose `My Mac` as the destination.
    - Press the **Run** button (or `Cmd+R`).
    - The main app will launch. You can now add the "Bus Widget" to your Notification Center.

## Privacy

This application requires access to your location to find nearby bus stops. This data is sent directly to the TfL API and is not stored or shared elsewhere. Your location is requested only when the app is in use.
