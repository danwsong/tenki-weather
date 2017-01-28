//
//  ViewController.swift
//  Tenki
//
//  Created by Daniel Song on 2016-03-28.
//  Copyright © 2016 Daniel Song. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    let weatherAPIKey: String = "45cb9107296937c955f9fde49ff44155"
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var highLowTemperatureLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var humidityRingView: CircularRingView!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var humidityLabelLabel: UILabel!
    @IBOutlet weak var probabilityOfPrecipitationRingView: CircularRingView!
    @IBOutlet weak var probabilityOfPrecipitationLabel: UILabel!
    @IBOutlet weak var probabilityOfPrecipitationLabelLabel: UILabel!
    @IBOutlet weak var cloudCoverRingView: CircularRingView!
    @IBOutlet weak var cloudCoverLabel: UILabel!
    @IBOutlet weak var cloudCoverLabelLabel: UILabel!
    @IBOutlet weak var iconLabel: UILabel!
    
    @IBOutlet weak var dayOneLabel: UILabel!
    @IBOutlet weak var dayTwoLabel: UILabel!
    @IBOutlet weak var dayThreeLabel: UILabel!
    @IBOutlet weak var dayFourLabel: UILabel!
    @IBOutlet weak var dayFiveLabel: UILabel!
    @IBOutlet weak var daySixLabel: UILabel!
    @IBOutlet weak var daySevenLabel: UILabel!
    
    @IBOutlet weak var dayOneTemperatureLabel: UILabel!
    @IBOutlet weak var dayTwoTemperatureLabel: UILabel!
    @IBOutlet weak var dayThreeTemperatureLabel: UILabel!
    @IBOutlet weak var dayFourTemperatureLabel: UILabel!
    @IBOutlet weak var dayFiveTemperatureLabel: UILabel!
    @IBOutlet weak var daySixTemperatureLabel: UILabel!
    @IBOutlet weak var daySevenTemperatureLabel: UILabel!
    
    @IBOutlet weak var dayOneWeatherIconLabel: UILabel!
    @IBOutlet weak var dayTwoWeatherIconLabel: UILabel!
    @IBOutlet weak var dayThreeWeatherIconLabel: UILabel!
    @IBOutlet weak var dayFourWeatherIconLabel: UILabel!
    @IBOutlet weak var dayFiveWeatherIconLabel: UILabel!
    @IBOutlet weak var daySixWeatherIconLabel: UILabel!
    @IBOutlet weak var daySevenWeatherIconLabel: UILabel!
    
    var locationManager: CLLocationManager?
    var currentApproximateLocation: CLLocation?
    var currentDailyLabel: Int = 1
    var currentDay: Int?
    var numberToMonth: [String] = ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    var iconStringToIconText: [String : String] = ["clear-day" : "\u{f00d}", "clear-night" : "\u{f02e}", "rain" : "\u{f008}", "snow" : "\u{f00a}", "sleet" : "\u{f0b2}", "wind" : "\u{f085}", "fog" : "\u{f003}", "cloudy" : "\u{f002}", "partly-cloudy-day" : "\u{f00c}", "partly-cloudy-night" : "\u{f031}"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager?.requestWhenInUseAuthorization()
        }
        
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager?.startUpdatingLocation()
        
        let currentCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
        currentDay = (currentCalendar as NSCalendar).component(.weekday, from: Date())
        let timeAroundNoon = CGFloat(abs(720 - ((currentCalendar as NSCalendar).component(.hour, from: Date()) * 60 + (currentCalendar as NSCalendar).component(.minute, from: Date())))) / 720.0
        let upColor = UIColor(hue: 21.0 / 36.0 - 1.0 / 36.0 * timeAroundNoon, saturation: 0.2 + 0.5 * timeAroundNoon, brightness: 0.9 - 0.4 * timeAroundNoon, alpha: 1.0).cgColor
        let downColor = UIColor(hue: 20.0 / 36.0 + 1.0 / 36.0 * timeAroundNoon, saturation: 0.8 + 0.05 * timeAroundNoon, brightness: 0.75 - 0.5 * timeAroundNoon, alpha: 1.0).cgColor
        
        let timeGradientLayer = CAGradientLayer()
        timeGradientLayer.frame = view.bounds
        timeGradientLayer.colors = [upColor, downColor]
        view.layer.insertSublayer(timeGradientLayer, at: 0)
        
        humidityLabelLabel.layer.cornerRadius = 8.0
        humidityLabelLabel.clipsToBounds = true
        probabilityOfPrecipitationLabelLabel.layer.cornerRadius = 8.0
        probabilityOfPrecipitationLabelLabel.clipsToBounds = true
        cloudCoverLabelLabel.layer.cornerRadius = 8.0
        cloudCoverLabelLabel.clipsToBounds = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func weekdayNumberToString(_ weekday: Int) -> String {
        switch weekday {
        case 0:
            return "SUN"
        case 1:
            return "MON"
        case 2:
            return "TUE"
        case 3:
            return "WED"
        case 4:
            return "THU"
        case 5:
            return "FRI"
        case 6:
            return "SAT"
        default:
            return ""
        }
    }
    
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let weatherRequestURL = URL(string: "https://api.forecast.io/forecast/\(weatherAPIKey)/\(locations.first!.coordinate.latitude),\(locations.first!.coordinate.longitude)")!
        let weatherRequestData = try! Data(contentsOf: weatherRequestURL)
        
        CLGeocoder().reverseGeocodeLocation(locations.first!) { (placemarks: [CLPlacemark]?, error: Error?) -> Void in
            self.locationLabel.text = placemarks?.first?.locality == nil ? "Unknown location" : placemarks?.first?.locality
            UIView.animate(withDuration: 1.0, animations: { () -> Void in
                self.locationLabel.alpha = 1.0
                self.timeLabel.alpha = 1.0
            }) 
        }
        
        if let weatherRequestJSONData = try! JSONSerialization.jsonObject(with: weatherRequestData, options: .mutableContainers) as? NSDictionary {
            if let currentWeatherData = weatherRequestJSONData["currently"] as? NSDictionary {
                if let currentTemperature = currentWeatherData["temperature"] as? Double {
                    temperatureLabel.text = "\(Int(round(currentTemperature)))°"
                    UIView.animate(withDuration: 1.0, animations: { () -> Void in
                        self.temperatureLabel.alpha = 1.0
                    }) 
                }
                
                if let currentTime = currentWeatherData["time"] as? Double {
                    let currentDate = Date(timeIntervalSince1970: currentTime)
                    let currentCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
                    timeLabel.text = "\(numberToMonth[(currentCalendar as NSCalendar).component(.month, from: currentDate)]) \((currentCalendar as NSCalendar).component(.day, from: currentDate))"
                }
                
                if let currentHumidity = currentWeatherData["humidity"] as? Double {
                    humidityRingView.humidityPercentage = CGFloat(currentHumidity)
                    humidityLabel.text = "\(Int(round(currentHumidity * 100)))%"
                    UIView.animate(withDuration: 1.0, animations: { () -> Void in
                        self.humidityLabel.alpha = 1.0
                        self.humidityLabelLabel.alpha = 1.0
                    }) 
                }
                
                if let currentProbabilityOfPrecipitation = currentWeatherData["precipProbability"] as? Double {
                    probabilityOfPrecipitationRingView.humidityPercentage = CGFloat(currentProbabilityOfPrecipitation)
                    probabilityOfPrecipitationLabel.text = "\(Int(round(currentProbabilityOfPrecipitation * 100)))%"
                    UIView.animate(withDuration: 1.0, animations: { () -> Void in
                        self.probabilityOfPrecipitationLabel.alpha = 1.0
                        self.probabilityOfPrecipitationLabelLabel.alpha = 1.0
                    }) 
                }
                
                if let currentCloudCover = currentWeatherData["cloudCover"] as? Double {
                    cloudCoverRingView.humidityPercentage = CGFloat(currentCloudCover)
                    cloudCoverLabel.text = "\(Int(round(currentCloudCover * 100)))%"
                    UIView.animate(withDuration: 1.0, animations: { () -> Void in
                        self.cloudCoverLabel.alpha = 1.0
                        self.cloudCoverLabelLabel.alpha = 1.0
                    }) 
                }
                
                if let currentWeatherIcon = currentWeatherData["icon"] as? String {
                    iconLabel.text = iconStringToIconText[currentWeatherIcon]
                    UIView.animate(withDuration: 1.0, animations: { () -> Void in
                        self.iconLabel.alpha = 1.0
                    }) 
                }
            }
            
            if let dailyWeatherData = weatherRequestJSONData["daily"] as? NSDictionary {
                if let dailyWeatherArray = dailyWeatherData["data"] as? NSArray {
                    for value in dailyWeatherArray {
                        if let weatherData = value as? NSDictionary {
                            if let dailyTemperature = weatherData["temperatureMax"] as? Double {
                                if let dailyIcon = weatherData["icon"] as? String {
                                    switch currentDailyLabel {
                                    case 1:
                                        dayOneLabel.text = weekdayNumberToString((currentDay! - 1 % 7))
                                        dayOneTemperatureLabel.text = "\(Int(round(dailyTemperature)))°"
                                        dayOneWeatherIconLabel.text = iconStringToIconText[dailyIcon]
                                        currentDailyLabel += 1
                                        if let currentTemperatureMin = weatherData["temperatureMin"] as? Double {
                                            if let currentTemperatureMax = weatherData["temperatureMax"] as? Double {
                                                highLowTemperatureLabel.text = "\u{2191} \(Int(round(currentTemperatureMax)))° \u{2193} \(Int(round(currentTemperatureMin)))°"
                                                UIView.animate(withDuration: 1.0, animations: { () -> Void in
                                                    self.highLowTemperatureLabel.alpha = 1.0
                                                }) 
                                            }
                                        }
                                    case 2:
                                        dayTwoLabel.text = weekdayNumberToString((currentDay!) % 7)
                                        dayTwoTemperatureLabel.text = "\(Int(round(dailyTemperature)))°"
                                        dayTwoWeatherIconLabel.text = iconStringToIconText[dailyIcon]
                                        currentDailyLabel += 1
                                    case 3:
                                        dayThreeLabel.text = weekdayNumberToString((currentDay! + 1) % 7)
                                        dayThreeTemperatureLabel.text = "\(Int(round(dailyTemperature)))°"
                                        dayThreeWeatherIconLabel.text = iconStringToIconText[dailyIcon]
                                        currentDailyLabel += 1
                                    case 4:
                                        dayFourLabel.text = weekdayNumberToString((currentDay! + 2) % 7)
                                        dayFourTemperatureLabel.text = "\(Int(round(dailyTemperature)))°"
                                        dayFourWeatherIconLabel.text = iconStringToIconText[dailyIcon]
                                        currentDailyLabel += 1
                                    case 5:
                                        dayFiveLabel.text = weekdayNumberToString(((currentDay! + 3) % 7))
                                        dayFiveTemperatureLabel.text = "\(Int(round(dailyTemperature)))°"
                                        dayFiveWeatherIconLabel.text = iconStringToIconText[dailyIcon]
                                        currentDailyLabel += 1
                                    case 6:
                                        daySixLabel.text = weekdayNumberToString((currentDay! + 4) % 7)
                                        daySixTemperatureLabel.text = "\(Int(round(dailyTemperature)))°"
                                        daySixWeatherIconLabel.text = iconStringToIconText[dailyIcon]
                                        currentDailyLabel += 1
                                    case 7:
                                        daySevenLabel.text = weekdayNumberToString((currentDay! + 5) % 7)
                                        daySevenTemperatureLabel.text = "\(Int(round(dailyTemperature)))°"
                                        daySevenWeatherIconLabel.text = iconStringToIconText[dailyIcon]
                                        currentDailyLabel = 0
                                    default:
                                        currentDailyLabel = 1
                                    }
                                }
                            }
                            UIView.animate(withDuration: 1.0, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                                self.dayOneLabel.alpha = 1.0
                                self.dayOneTemperatureLabel.alpha = 1.0
                                self.dayOneWeatherIconLabel.alpha = 1.0
                                }, completion: nil)
                            UIView.animate(withDuration: 1.0, delay: 1.0 / 3.0, options: UIViewAnimationOptions(), animations: {
                                self.dayTwoLabel.alpha = 1.0
                                self.dayTwoTemperatureLabel.alpha = 1.0
                                self.dayTwoWeatherIconLabel.alpha = 1.0
                                }, completion: nil)
                            UIView.animate(withDuration: 1.0, delay: 2.0 / 3.0, options: UIViewAnimationOptions(), animations: {
                                self.dayThreeLabel.alpha = 1.0
                                self.dayThreeTemperatureLabel.alpha = 1.0
                                self.dayThreeWeatherIconLabel.alpha = 1.0
                                }, completion: nil)
                            UIView.animate(withDuration: 1.0, delay: 1.0, options: UIViewAnimationOptions(), animations: {
                                self.dayFourLabel.alpha = 1.0
                                self.dayFourTemperatureLabel.alpha = 1.0
                                self.dayFourWeatherIconLabel.alpha = 1.0
                                }, completion: nil)
                            UIView.animate(withDuration: 1.0, delay: 4.0 / 3.0, options: UIViewAnimationOptions(), animations: {
                                self.dayFiveLabel.alpha = 1.0
                                self.dayFiveTemperatureLabel.alpha = 1.0
                                self.dayFiveWeatherIconLabel.alpha = 1.0
                                }, completion: nil)
                            UIView.animate(withDuration: 1.0, delay: 5.0 / 3.0, options: UIViewAnimationOptions(), animations: {
                                self.daySixLabel.alpha = 1.0
                                self.daySixTemperatureLabel.alpha = 1.0
                                self.daySixWeatherIconLabel.alpha = 1.0
                                }, completion: nil)
                            UIView.animate(withDuration: 1.0, delay: 2.0, options: UIViewAnimationOptions(), animations: {
                                self.daySevenLabel.alpha = 1.0
                                self.daySevenTemperatureLabel.alpha = 1.0
                                self.daySevenWeatherIconLabel.alpha = 1.0
                                }, completion: nil)
                        }
                    }
                }
            }
        }
        
        locationManager?.stopUpdatingLocation()
    }
    
}

class CircularRingView: UIView {
    
    var humidityPercentage: CGFloat? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var previousPercentage: CGFloat?
    
    var circleShape: CAShapeLayer?
    var arcShape: CAShapeLayer?
    
    var drawnFlag: Bool = false
    
    override func draw(_ rect: CGRect) {
        if !drawnFlag {
            circleShape = CAShapeLayer()
            circleShape?.path = UIBezierPath(arcCenter: CGPoint(x: bounds.width / 2, y: bounds.height / 2), radius: bounds.width * 15 / 32, startAngle: -CGFloat(M_PI) / 2, endAngle: CGFloat(M_PI) * 2 - CGFloat(M_PI) / 2, clockwise: true).cgPath
            circleShape?.fillColor = UIColor.clear.cgColor
            circleShape?.strokeColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.25).cgColor
            circleShape?.lineWidth = bounds.width / 16
            
            let circleAnimation = CABasicAnimation(keyPath: "strokeEnd")
            circleAnimation.duration = 2.0
            circleAnimation.repeatCount = 1.0
            circleAnimation.fromValue = 0.0
            circleAnimation.toValue = 1.0
            circleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            circleShape?.add(circleAnimation, forKey: "drawArcAnimation")
            layer.addSublayer(circleShape!)
            
            drawnFlag = true
        }
        
        if let percentage = humidityPercentage {
            arcShape = CAShapeLayer()
            arcShape?.path = UIBezierPath(arcCenter: CGPoint(x: bounds.width / 2, y: bounds.height / 2), radius: bounds.width * 15 / 32, startAngle: -CGFloat(M_PI) / 2, endAngle: CGFloat(M_PI) * 2 * percentage - CGFloat(M_PI) / 2, clockwise: true).cgPath
            arcShape?.fillColor = UIColor.clear.cgColor
            arcShape?.strokeColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5).cgColor
            arcShape?.lineWidth = bounds.width / 16
            
            let arcAnimation = CABasicAnimation(keyPath: "strokeEnd")
            arcAnimation.duration = 2.0
            arcAnimation.repeatCount = 1.0
            arcAnimation.fromValue = 0.0
            arcAnimation.toValue = 1.0
            if let previous = previousPercentage {
                arcAnimation.fromValue = previous / percentage
            }
            arcAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            arcShape?.add(arcAnimation, forKey: "drawArcAnimation")
            layer.addSublayer(arcShape!)
            
            previousPercentage = humidityPercentage
        }
    }
    
}
 
