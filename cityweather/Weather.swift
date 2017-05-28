//
//  Weather.swift
//  cityweather
//
//  Created by Usman Jamil on 28/05/2017.
//  Copyright © 2017 Usman Jamil. All rights reserved.
//

import Foundation
import CoreLocation

struct Weather {
    let summary:String
    let icon:String
    let temperature:Double
    
    enum SerializationError:Error {
        case missing(String)
        case invalid(String, Any)
    }
    
    init(json:[String:Any]) throws {
        guard let summary = json["summary"] as? String else {
            throw SerializationError.missing("Summary is missing")
        }
        
        guard let icon = json["icon"] as? String else {
            throw SerializationError.missing("Icon is missing")
        }
        
        guard let temperature = json["temperatureMax"] as? Double else {
            throw SerializationError.missing("Temperature is missing")
        }
        
        self.summary = summary
        self.icon = icon
        self.temperature = temperature
    }
    
    static let basePath = "https://api.darksky.net/forecast/2c0a7d1d980ee4051cf06eefffa5379c/"
    
    static func forecast (withLocation location:CLLocationCoordinate2D, completion: @escaping ([Weather]) -> ()) {
        
        let url = basePath + "\(location.latitude),\(location.longitude)"

        let request = URLRequest(url: URL(string: url)!)

        
        let task = URLSession.shared.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
            
            var forecastArray:[Weather] = []
            
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        print("im here")
                        if let dailyForecasts = json["daily"] as? [String:Any] {
                            if let dailyData = dailyForecasts["data"] as? [[String:Any]] {
                                for dataPoint in dailyData {
                                    if let weatherObject = try? Weather(json: dataPoint) {
                                        forecastArray.append(weatherObject)
                                    }
                                }
                            }
                        }
                        
                    }
                }catch {
                  print(error.localizedDescription)
                }
                completion(forecastArray)
            }
        }
        
        task.resume()
    }
}
