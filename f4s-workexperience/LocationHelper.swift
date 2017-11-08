//
//  LocationHelper.swift
//  f4s-workexperience
//
//  Created by Sergiu Simon on 11/11/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation
import Alamofire
import CoreLocation
import SwiftyJSON
import GoogleMaps
import Reachability

class LocationHelper {

    static let sharedInstance = LocationHelper()

    func googleGeocodeAddressString(_ address: String, _ placeId: String?, completion: @escaping (_ succeeded: Bool, _ coordinates: Result<CLLocationCoordinate2D>) -> Void) {

        if let reachability = Reachability() {
            if !reachability.isReachableByAnyMeans {
                completion(false, .error("NoConnectivity"))
                return
            }
        }

        var geocodeUrl = ""
        if let placeId = placeId {
            geocodeUrl = GoogleApiKeys.geocodeUrl + "?place_id=\(placeId)&key=\(GoogleApiKeys.geocodeApiKey)"
        } else {
            geocodeUrl = GoogleApiKeys.geocodeUrl + "?address=\(address)&key=\(GoogleApiKeys.geocodeApiKey)"
        }
        var s = (CharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
        s.addCharacters(in: "+&")
        if let encodedString = geocodeUrl.addingPercentEncoding(withAllowedCharacters: s as CharacterSet) {
            Alamofire.request(encodedString, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON { (response: DataResponse<Any>) in
                switch response.result {
                case .success(let data):
                    let json = JSON(data)
                    let status = json["status"].string
                    print(json)
                    if status == "OK" {
                        var results = json["results"].array

                        let lat = results![0]["geometry"]["location"]["lat"]
                        let lng = results![0]["geometry"]["location"]["lng"]
                        let coordinates = CLLocationCoordinate2DMake(lat.doubleValue, lng.doubleValue)
                        completion(true, .value(Box(coordinates)))
                    } else {
                        geocodeUrl = GoogleApiKeys.geocodeUrl + "?address=\(address)&key=\(GoogleApiKeys.geocodeApiKey)"

                        s = (CharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
                        s.addCharacters(in: "+&")
                        if let encodedString = geocodeUrl.addingPercentEncoding(withAllowedCharacters: s as CharacterSet) {
                            Alamofire.request(encodedString, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON { (response: DataResponse<Any>) in
                                switch response.result {
                                case .success(let data):
                                    let json = JSON(data)
                                    let status = json["status"].string
                                    print(json)
                                    if status == "OK" {
                                        var results = json["results"].array

                                        let lat = results![0]["geometry"]["location"]["lat"]
                                        let lng = results![0]["geometry"]["location"]["lng"]
                                        let coordinates = CLLocationCoordinate2DMake(lat.doubleValue, lng.doubleValue)
                                        completion(true, .value(Box(coordinates)))
                                    } else {
                                        completion(false, .error("Location not found."))
                                    }
                                case .failure(let error):
                                    completion(false, .error("Location not found."))
                                    debugPrint(error)
                                }
                            }
                        }
                    }
                case .failure(let error):
                    completion(false, .error("Location not found."))
                    debugPrint(error)
                }
            }
        } else {
            completion(false, .error("An error occurred."))
            debugPrint("invalid encoded string in googleGeocodeAddressString")
        }
    }

    func googleGeocodeAddressToBounds(_ address: String, completion: @escaping (_ succeeded: Bool, _ coordinates: Result<Dictionary<String, CLLocationCoordinate2D>>) -> Void) {
        let geocodeUrl = GoogleApiKeys.geocodeUrl + "?address=\(address)&region=ro&components=locality&key=\(GoogleApiKeys.geocodeApiKey)"
        let s = (CharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
        s.addCharacters(in: "+&")
        if let encodedString = geocodeUrl.addingPercentEncoding(withAllowedCharacters: s as CharacterSet) {
            Alamofire.request(encodedString, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON { (response: DataResponse<Any>) in switch response.result {
            case .success(let data):
                let json = JSON(data)
                let status = json["status"].string
                if status == "OK" {
                    var coordDict: [String: CLLocationCoordinate2D] = [:]
                    var results = json["results"].array
                    if results![0]["geometry"]["bounds"].exists() {
                        if var bounds = results![0]["geometry"]["bounds"].dictionary {

                            let NElat = bounds["northeast"]!["lat"]
                            let NElng = bounds["northeast"]!["lng"]
                            let NEcoordinates = CLLocationCoordinate2DMake(NElat.doubleValue, NElng.doubleValue)
                            coordDict["northeast"] = NEcoordinates

                            let SWlat = bounds["southwest"]!["lat"]
                            let SWlng = bounds["southwest"]!["lng"]
                            let SWcoordinates = CLLocationCoordinate2DMake(SWlat.doubleValue, SWlng.doubleValue)
                            coordDict["southwest"] = SWcoordinates

                            completion(true, .value(Box(coordDict)))
                        }
                    } else {
                        completion(false, .error("Address was not found"))
                    }
                } else if status == "ZERO_RESULTS" {
                    debugPrint("address not found")
                    completion(false, .error("Address was not found"))
                }

            case .failure(let error):
                completion(false, .error("Error"))
                debugPrint(error)
            }
            }
        } else {
            completion(false, .error("Error"))
            debugPrint("invalid encoded string in googleGeocodeAddressString")
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
                print("Error Reverse Geocoding Location: \(err.localizedDescription)")
                completion(nil, error as NSError?)
                return
            }
            completion(placemarks?[0], nil)

        })
    }

    class func addressFromPlacemark(_ placemark: CLPlacemark) -> String {
        var address = ""

        if let name = placemark.addressDictionary?["Name"] as? String {
            address = constructAddressString(address, newString: name)
        }

        if let city = placemark.addressDictionary?["City"] as? String {
            address = constructAddressString(address, newString: city)
        }

        if let state = placemark.addressDictionary?["State"] as? String {
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
