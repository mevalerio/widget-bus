
import SwiftUI
import TfLService

struct WidgetView: View {
    var entry: SimpleEntry

    var body: some View {
        VStack {
            Text("System Monitor")
                .font(.headline)
            HStack {
                Text(String(format: "CPU: %.0f%%", entry.cpuUsage * 100))
                Text(String(format: "RAM: %.1fGB / %.1fGB", entry.memoryUsage.used, entry.memoryUsage.total))
                Text(String(format: "GPU: %.0f%%", entry.gpuUsage * 100))
            }
            .padding(.bottom)

            Text("Bus Arrivals")
                .font(.headline)
            ForEach(entry.arrivals, id: \.timeToStation) { arrival in
                HStack {
                    Text(arrival.lineName)
                    Text(arrival.destinationName)
                    Spacer()
                    Text("\(arrival.timeToStation / 60) min")
                }
            }
            Spacer()
        }
        .padding()
    }
}
