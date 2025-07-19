
import WidgetKit
import SwiftUI
import SystemMonitor
import TfLService

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), cpuUsage: 0.5, memoryUsage: (8, 4, 16), gpuUsage: 0.7, arrivals: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), cpuUsage: 0.5, memoryUsage: (8, 4, 16), gpuUsage: 0.7, arrivals: [])
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            let systemMonitor = SystemMonitor()
            let tflService = TfLService()

            // You will need to provide your TfL API key here
            // tflService.setApiKey("YOUR_TFL_API_KEY")
            tflService.start()

            let currentDate = Date()
            let nextUpdateDate = Calendar.current.date(byAdding: .second, value: 15, to: currentDate)!

            let cpuUsage = systemMonitor.getCPUUsage()
            let memoryUsage = systemMonitor.getMemoryUsage()
            let gpuUsage = systemMonitor.getGPUUsage()

            // Wait for arrivals to be fetched by TfLService
            // This is a simplified approach. In a real app, you might use Combine or async streams
            // to observe changes in tflService.arrivals.
            // For now, we'll just use the current arrivals after a short delay or a more robust mechanism.
            try await Task.sleep(nanoseconds: 1_000_000_000) // Wait for 1 second for data to potentially arrive
            let arrivals = tflService.arrivals

            let entry = SimpleEntry(date: currentDate, cpuUsage: cpuUsage, memoryUsage: memoryUsage, gpuUsage: gpuUsage, arrivals: arrivals)
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let cpuUsage: Double
    let memoryUsage: (free: Double, used: Double, total: Double)
    let gpuUsage: Double
    let arrivals: [Arrival]
}

struct BusWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        WidgetView(entry: entry)
    }
}

@main
struct BusWidget: Widget {
    let kind: String = "BusWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) {
            entry in
            BusWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Bus Widget")
        .description("Displays system stats and nearby bus arrivals.")
    }
}
