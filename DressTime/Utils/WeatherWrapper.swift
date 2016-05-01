//
//  WeatherWrapper.swift
//  DressTime
//
//  Created by Fab on 09/10/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation

public class Weather: NSObject {
    var code: Int?
    var temp: Int?
    var tempMin: Int?
    var tempMax: Int?
    var time: String?
    var hour: Int?
    var city: String?
    var icon: String?
    
    public override init(){
    }
    
    public init(json: JSON){
        code = json["code"].int
        temp = json["temp"].int
        tempMin = json["tempMin"].int
        tempMax = json["tempMax"].int
        time = json["time"].string
        hour = json["hour"].int
        city = json["city"].string
        icon = json["icon"].string
    }
}

public class WeatherHelper {
    private static func weatherConditionByCode(code: Int) -> String{
        //2xx Thunderstorm
        //3xx Drizzle
        //5xx Rain
        //6xx Snow
        //7xx Atmosphere
        //800 sunny
        //80x Clouds
        //9xx Extreme
        
        
        if (code >= 200 && code < 300){
            return "storm"
        } else if (code >= 300 && code < 400){
            return "drizzle"
        } else if (code >= 500 && code < 600){
            return "rainy"
        } else if (code >= 600 && code < 700){
            return "snowy"
        } else if (code >= 700 && code < 800){
            return "atmosphere"
        } else if (code == 800 ){
            return "sunny"
        } else if (code >= 800 && code < 900){
            return "cloudy"
        } else if (code >= 900){
            return "extreme"
        } else {
            return ""
        }
    }
    
    public static func changeBackgroundDependingWeatherCondition(code: Int) -> String{
        let condition = WeatherHelper.weatherConditionByCode(code)

        switch condition {
            case "storm":
                return "HomeBgStorm"
            case "drizzle":
                return "HomeBgRain"
            case "rainy":
                return "HomeBgRain2"
            case "snowy":
                return "HomeBgSnow"
            case "atmosphere":
                return "HomeBgAtmosphere"
            case "sunny":
                return "HomeBgSun"
            case "cloudy":
                return "HomeBgCloud"
            case "extreme":
                return "HomeBgTornado"
            default:
                return "HomeBgSun"
        }
    }

}
class WeatherWrapper {
    
    
    func arrayOfWeather(list: JSON)  -> [Weather]{
        var result = [Weather]()
        for item in list.arrayValue {
            result.append(Weather(json: item))
        }
        return result
    }
    
    
    func wrapListWeather(current: JSON, forecast: JSON) -> [Weather]{
        var list = [Weather]()
        list.append(wrapToWeather(current, time: "Now"))
        if let data = getTimeFrame() {
            var time = "", i = 0
            for (_, subjson) in forecast["list"]{
                let hour = getHour(subjson["dt_txt"].stringValue)
                if (hour == data[i]){
                    if (data[i] == 9) {
                        time = "Morning"
                    } else if (data[i] == 15) {
                        time = "Afternoon"
                    } else if (data[i] == 21) {
                        time = "Tonight"
                    }
                    let weather = wrapToWeather(subjson, time: time)
                    if let city = forecast["city"]["name"].string {
                        weather.city = city
                    }
                    list.append(weather)
                    i += 1
                    if (i>1) {
                        break;
                    }
                }
            }
        }
        return list
    }
    
    func getHour(dateStr: String) -> Int{
        let date = dateStr.toDateTime()!
        let calendar = NSCalendar.currentCalendar()
        calendar.timeZone = NSTimeZone(name: "UTC")!
        let components = calendar.components([NSCalendarUnit.Hour], fromDate: date)
        return components.hour
    }
    
    func wrapToWeather(json: JSON, time: String)-> Weather {
        let calendar = NSCalendar.currentCalendar()
        var date = NSDate()/*NSDate(timeIntervalSince1970: Double(json["dt"].floatValue))*/
        if let dateStr = json["dt_txt"].string {
            date = dateStr.toDateTime()!
            calendar.timeZone = NSTimeZone(name: "UTC")!
        }
        let components = calendar.components([NSCalendarUnit.Hour], fromDate: date)
        let hour = components.hour
        
        
        let weather = Weather()
        weather.hour = hour
        weather.time = time
        weather.temp = json["main"]["temp"].int
        weather.tempMin = json["main"]["temp_min"].int
        weather.tempMax = json["main"]["temp_max"].int
        weather.code = json["weather"][0]["id"].int
        weather.icon = codeToFont(json["weather"][0]["id"].int!)
       
        //Current
        if let city = json["name"].string {
            weather.city = city
        }
        
        
        return weather
    }
    
    func getTimeFrame() -> [Int]?{
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([NSCalendarUnit.Hour,NSCalendarUnit.Minute], fromDate: date)
        let hour = components.hour
        
        if (hour >= 0 && hour < 12){
            //Afternoon(15h) & Tonight(21h)
            return [15, 21]
        } else if (hour >= 12 && hour < 18) {
            //Tonight(21h) & Tomorrow Morning (9h)
            return [21, 9]
        } else if (hour >= 18) {
            //Tomorrow Morning (9h) and Tomorrow Afternoon(15h)
             return [9, 15]
        }
        return nil
    }
    
    func codeToFont(code:Int) -> String{
        for i in 0 ..< transcodeValue.count {
            if (transcodeValue[i][0] == code){
                return transcodeValue[i][2] as! String
            }
        }
        return "."
    }
    
    func getNameByTime(hour: Int) -> String {
        if (hour >= 0 && hour < 12){
            //Afternoon(15h) & Tonight(21h)
            return "Morning"
        } else if (hour >= 12 && hour < 18) {
            //Tonight(21h) & Tomorrow Morning (9h)
            return "Afternoon"
        } else if (hour >= 18) {
            //Tomorrow Morning (9h) and Tomorrow Afternoon(15h)
            return "Tonight"
        }
        return ""
    }

    
    let transcodeValue = [
        [200,"thunderstorm with light rain","S","S"  ],
        [201,"thunderstorm with rain","Q","Q"  ],
        [202,"thunderstorm with heavy rain","Q","Q"  ],
        [210,"light thunderstorm","Y","X"  ],
        [211,"thunderstorm","Y","Y"  ],
        [212,"heavy thunderstorm","Y","Y"  ],
        [221,"ragged thunderstorm","Y","Y"  ],
        [230,"thunderstorm with light drizzle","S","S"  ],
        [231,"thunderstorm with drizzle","S","S"  ],
        [232,"thunderstorm with heavy drizzle","Q","Q"  ],
        [300,"light intensity drizzle","M","M"  ],
        [301,"drizzle","M","M"  ],
        [302,"heavy intensity drizzle","M","M"  ],
        [310,"light intensity drizzle rain","M","M"  ],
        [311,"drizzle rain","U","U"  ],
        [312,"heavy intensity drizzle rain","U","U"  ],
        [313,"shower rain and drizzle","U","U"  ],
        [314,"heavy shower rain and drizzle","O","O"  ],
        [321,"shower drizzle","O","O"  ],
        [500,"light rain","M","M"  ],
        [501,"moderate rain","M","M"  ],
        [502,"heavy intensity rain","U","U"  ],
        [503,"very heavy rain","U","U"  ],
        [504,"extreme rain","U","U"  ],
        [511,"freezing rain","U","U"  ],
        [520,"light intensity shower rain","O","O"  ],
        [521,"shower rain","O","O"  ],
        [522,"heavy intensity shower rain","O","O"  ],
        [531,"ragged shower rain","O","O"  ],
        [600,"light snow","I","I"  ],
        [601,"snow","I","I"  ],
        [602,"heavy snow","I","I"  ],
        [611,"sleet","I","I"  ],
        [612,"shower sleet","I","I"  ],
        [615,"light rain and snow","I","I"  ],
        [616,"rain and snow","I","I"  ],
        [620,"light shower snow","I","I"  ],
        [621,"shower snow","I","I"  ],
        [622,"heavy shower snow","I","I"  ],
        [701,"mist","Z","Z"  ],
        [711,"smoke","Z","Z"  ],
        [721,"haze","Z","Z"  ],
        [731,"sand, dust whirls","Z","Z"  ],
        [741,"fog","Z","Z"  ],
        [751,"sand","Z","Z"  ],
        [761,"dust","Z","Z"  ],
        [762,"volcanic ash","Z","Z"  ],
        [771,"squalls","Z","Z"  ],
        [781,"tornado","Z","Z"  ],
        [800,"clear sky","1","1"  ],
        [801,"few clouds","2","2"  ],
        [802,"scattered clouds","A","A"  ],
        [803,"broken clouds","3","3"  ],
        [804,"overcast clouds","G","G"  ],
        [900,"tornado","Q","Q"  ],
        [901,"tropical storm","Q","Q"  ],
        [902,"hurricane","Q","Q"  ],
        [903,"cold","6","6"  ],
        [904,"hot","1","1"  ],
        [905,"windy","E","E"  ],
        [906,"hail","O","O"  ],
        [951,"calm","B","B"  ],
        [952,"light breeze","D","D"  ],
        [953,"gentle breeze","D","D"  ],
        [954,"moderate breeze","D","D"  ],
        [955,"fresh breeze","D","D"  ],
        [956,"strong breeze","D","D"  ],
        [957,"high wind, near gale","E","E"  ],
        [958,"gale","E","E"  ],
        [959,"severe gale","E","E"  ],
        [960,"storm","E","E"  ],
        [961,"violent storm","E","E"  ],
        [962,"hurricane","E","E"  ]
    ]
}

extension String
{
    func toDateTime() -> NSDate?
    {
        //Create Date Formatter
        let dateFormatter = NSDateFormatter()
        
        //Specify Format of String to Parse
        dateFormatter.dateFormat = "yyyy-MM-dd kk:mm:ss"//this your string date format
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        
        //Parse into NSDate
        let dateFromString = dateFormatter.dateFromString(self)
        
        //Return Parsed Date
        return dateFromString
    }
}