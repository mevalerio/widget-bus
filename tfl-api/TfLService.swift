
import Foundation
import CoreLocation

// MARK: - Data Structures for TfL API Response

struct StopPoint: Codable {
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

class TfLService: NSObject, CLLocationManagerDelegate {

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
        fetchBusStops(around: location.coordinate)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error.localizedDescription)")
    }

    private func fetchBusStops(around coordinate: CLLocationCoordinate2D) {
        let urlString = "https://api.tfl.gov.uk/StopPoint?stopTypes=NaptanPublicBusCoachTram&lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&radius=\(radius)&app_key=\(apiKey)"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Failed to fetch bus stops: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let response = try JSONDecoder().decode(StopPointsResponse.self, from: data)
                response.stopPoints.forEach { stopPoint in
                    self.fetchArrivals(for: stopPoint.naptanId)
                }
            } catch {
                print("Failed to decode bus stops: \(error.localizedDescription)")
            }
        }.resume()
    }

    private func fetchArrivals(for stopId: String) {
        let urlString = "https://api.tfl.gov.uk/StopPoint/\(stopId)/Arrivals?app_key=\(apiKey)"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Failed to fetch arrivals: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let arrivals = try JSONDecoder().decode([Arrival].self, from: data)
                // Now we have the arrivals, we can process them
                // For now, let's just print them
                print("Arrivals for stop \(stopId): \(arrivals)")
            } catch {
                print("Failed to decode arrivals: \(error.localizedDescription)")
            }
        }.resume()
    }
}
