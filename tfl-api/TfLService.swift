
import Foundation
import CoreLocation

// MARK: - Data Structures for TfL API Response

public struct StopPoint: Codable {
    let naptanId: String
    let commonName: String
    let distance: Double
    let lat: Double
    let lon: Double
}

struct StopPointsResponse: Codable {
    let stopPoints: [StopPoint]
}

struct Arrival: Codable {
    let lineName: String
    let destinationName: String
    let timeToStation: Int // in seconds
}

import Combine

class TfLService: NSObject, ObservableObject, CLLocationManagerDelegate {

    @Published var arrivals: [Arrival] = []

    private let locationManager = CLLocationManager()
    private var apiKey: String = "" // Replace with your TfL API key
    private let radius = 1609 // 1 mile in meters

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func setApiKey(_ key: String) {
        self.apiKey = key
    }

    func start() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task {
            do {
                let stopPoints = try await fetchBusStops(around: location.coordinate)
                var allArrivals: [Arrival] = []
                for stopPoint in stopPoints {
                    let arrivals = try await fetchArrivals(for: stopPoint.naptanId)
                    allArrivals.append(contentsOf: arrivals)
                }
                DispatchQueue.main.async {
                    self.arrivals = allArrivals.sorted { $0.timeToStation < $1.timeToStation }
                }
            } catch {
                print("Error fetching data: \(error.localizedDescription)")
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error.localizedDescription)")
    }

    private func fetchBusStops(around coordinate: CLLocationCoordinate2D) async throws -> [StopPoint] {
        let urlString = "https://api.tfl.gov.uk/StopPoint?stopTypes=NaptanPublicBusCoachTram&lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&radius=\(radius)&app_key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(StopPointsResponse.self, from: data)
        return response.stopPoints
    }

    private func fetchArrivals(for stopId: String) async throws -> [Arrival] {
        let urlString = "https://api.tfl.gov.uk/StopPoint/\(stopId)/Arrivals?app_key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let arrivals = try JSONDecoder().decode([Arrival].self, from: data)
        return arrivals
    }
}
