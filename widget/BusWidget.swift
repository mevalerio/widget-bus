
import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), cpuUsage: 0.5, memoryUsage: (8, 4, 16), gpuUsage: 0.7, arrivals: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), cpuUsage: 0.5, memoryUsage: (8, 4, 16), gpuUsage: 0.7, arrivals: [])
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let systemMonitor = SystemMonitor()
        let tflService = TfLService()

        // You will need to provide your TfL API key here
        // tflService.setApiKey("YOUR_TFL_API_KEY")
        tflService.start()

        let currentDate = Date()
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!

        let cpuUsage = systemMonitor.getCPUUsage()
        let memoryUsage = systemMonitor.getMemoryUsage()
        let gpuUsage = systemMonitor.getGPUUsage()

        // This is a placeholder for the arrivals. In a real app, you would get this from the TfLService.
        let arrivals: [Arrival] = []

        let entry = SimpleEntry(date: currentDate, cpuUsage: cpuUsage, memoryUsage: memoryUsage, gpuUsage: gpuUsage, arrivals: arrivals)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
        completion(timeline)
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
