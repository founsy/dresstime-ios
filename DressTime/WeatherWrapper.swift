//
//  WeatherWrapper.swift
//  DressTime
//
//  Created by Fab on 09/10/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation

class WeatherWrapper {
    
    
    func wrapListWeather(current: JSON, forecast: JSON) -> [Weather]{
        var list = [Weather]()
        list.append(wrapToWeather(current, time: "Now"))
        if let data = getFrame() {
            for (var i=0; i < data.count; i++){
                var time = ""
                if (data[i] == 2) {
                    time = "afternoon"
                } else if (data[i] == 4) {
                    time = "tonight"
                } else if (data[i] == 8) {
                    time = "tom. morning"
                } else if (data[i] == 10) {
                    time = "tom. afternoon"
                }
                list.append(wrapToWeather(forecast["list"][data[i]], time: time))
            }
        }
        return list
    }
    
    func wrapToWeather(json: JSON, time: String)-> Weather {
        let weather = Weather()
        weather.time = time
        weather.temp = json["main"]["temp"].int
        weather.tempMin = json["main"]["temp_min"].int
        weather.tempMax = json["main"]["temp_max"].int
        weather.code = json["weather"][0]["id"].int
        weather.icon = codeToFont(json["weather"][0]["id"].int!)
       
        //Forecast
        if let city = json["city"]["name"].string {
            weather.city = city
        } else {
            //Current
            if let city = json["name"].string {
                weather.city = city
            }
        }
        
        return weather
    }
    
    func getFrame() -> [Int]?{
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([NSCalendarUnit.Hour,NSCalendarUnit.Minute], fromDate: date)
        let hour = components.hour
        
        if (hour > 6 && hour < 12){
            //Afternoon & Tonight
            return [2, 4]
        } else if (hour > 12 && hour < 18) {
            //Tonight & Tomorrow Morning (9h)
            return [4, 8]
        } else if (hour > 18) {
            //Tomorrow Morning and Tomorrow Afternoon
             return [8, 10]
        }
        return nil
    }
    
    func codeToFont(code:Int) -> String{
        for (var i=0; i < transcodeValue.count; i++){
            if (transcodeValue[i][0] == code){
                return transcodeValue[i][2] as! String
            }
        }
        return "."
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