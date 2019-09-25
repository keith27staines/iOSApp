//
//  LocationHelper.swift
//  f4s-workexperience
//
//  Created by Sergiu Simon on 11/11/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation
import CoreLocation
import GoogleMaps
import Reachability

public final class Box<A> {
    let value: A
    
    init(_ value: A) {
        self.value = value
    }
}

enum Result<A> {
    case error(String)
    case value(Box<A>)
}

class LocationHelper {

    static let sharedInstance = LocationHelper()
    struct Location : Decodable {
        var lat: Double?
        var lng: Double?
        var location_type: String?
        func coordinates() -> CLLocationCoordinate2D? {
            guard let lat = lat, let lng = lng else { return nil }
            return CLLocationCoordinate2DMake(lat, lng)
        }
    }
    struct GeocodeResult: Decodable {
        
        struct Result : Decodable {
            struct Geometry : Decodable {
                var location : Location
            }
            var geometry: Geometry
        }
        var status: String?
        var results: [Result]?
        func coordinates() -> CLLocationCoordinate2D? {
            return results?.first?.geometry.location.coordinates()
        }
    }

    func googleCoordinatesWithUrl(_ url: URL, completion: @escaping (_ coordinates: Result<CLLocationCoordinate2D>) -> ()) {
        let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                guard let data = data else {
                    completion(.error("Location not found."))
                    return
                }
                let decoder = JSONDecoder()
                guard let geocodeResult = try? decoder.decode(GeocodeResult.self, from: data),
                    let coordinates = geocodeResult.coordinates() else {
                        completion(.error("Location not found."))
                        return
                }
                completion(.value(Box(coordinates)))
            }
        }
        dataTask.resume()
    }
    
    func googleGeocodeAddressString(_ address: String, _ placeId: String?, completion: @escaping (_ coordinates: Result<CLLocationCoordinate2D>) -> Void) {
        if let reachability = Reachability() {
            if !reachability.isReachableByAnyMeans {
                completion(.error("NoConnectivity"))
                return
            }
        }
        let geocodeUrl = URL(string: GoogleApiKeys.geocodeUrl)!
        let q1: URLQueryItem
        let q2 = URLQueryItem(name: "key", value: GoogleApiKeys.geocodeApiKey)
        if let placeId = placeId {
            q1 = URLQueryItem(name: "place_id", value: placeId)
        } else {
            q1 = URLQueryItem(name: "address", value: address)
        }
  
        var components = URLComponents(url: geocodeUrl, resolvingAgainstBaseURL: false)!
        components.queryItems = [q1,q2]
        struct Json : Decodable {
            var status: String
        }
        guard let url = components.url else {
            completion(.error("Location not found."))
            return
        }
        
        googleCoordinatesWithUrl(url) { (coordinateResult) in
            switch coordinateResult {
            case .value(_):
                completion(coordinateResult)
            case .error(let error):
                completion(.error(error))
            }
        }
    }

    func isLocationInBoundingBox(_ location: CLLocationCoordinate2D, boundingBox: GMSCoordinateBounds) -> Bool {

        if boundingBox.contains(location) {
            return true
        } else {
            return false
        }
    }

    // MARK: - Apple Geocorder
    class func geocodeAddressString(_ address: String, completion: @escaping (_ placemark: CLPlacemark?, _ error: NSError?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address, completionHandler: { placemarks, error in
            if error == nil {
                //  if placemarks.count > 0{
                completion((placemarks?[0]), error as NSError?)
                //   }
            } else {
                completion(nil, error as NSError?)
            }
        })
    }

    class func reverseGeocodeLocation(_ location: CLLocation, completion: @escaping (_ placemark: CLPlacemark?, _ error: NSError?) -> Void) {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, completionHandler: { placemarks, error in
            if let err = error {
                completion(nil, err as NSError?)
                return
            }
            completion(placemarks?[0], nil)

        })
    }

    class func addressFromPlacemark(_ placemark: CLPlacemark) -> String {
        var address = ""
        if let name = placemark.name {
            address = constructAddressString(address, newString: name)
        }
        
        if let city = placemark.subAdministrativeArea {
            address = constructAddressString(address, newString: city)
        }

        if let state = placemark.administrativeArea {
            address = constructAddressString(address, newString: state)
        }

        if let country = placemark.country {
            address = constructAddressString(address, newString: country)
        }

        return address
    }

    fileprivate class func constructAddressString(_ string: String, newString: String) -> String {
        var address = string
        if !address.isEmpty {
            address = address + ", \(newString)"
        } else {
            address = address + newString
        }
        return address
    }
}
