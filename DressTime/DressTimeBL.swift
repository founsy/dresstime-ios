//
//  DressTimeBL.swift
//  DressTime
//
//  Created by Fab on 14/10/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation

class DressTimeBL {
    
    
    func getDayMoment(hour: Int) -> [String] {
        var dayMoment = [String]()
        //Morning
        if (hour >= 0 && hour < 12){
            dayMoment = ["atWork", "relax"]
        } else if (hour >= 12 && hour < 18) { //Afternoon
             dayMoment =  ["atWork", "relax"]
        } else if (hour >= 18) { //Tonight
             dayMoment =  ["onParty", "relax"]
        }
        return dayMoment
    }

    
    func getStyleByMoment(moments: [String]) -> [String]{
        var styleByMoment = [String]()
        if let profil =  ProfilsDAL().fetch(SharedData.sharedInstance.currentUserId!) {
            for (var i=0; i < moments.count; i++){
                if (moments[i] == "atWork"){
                    if let workStyle = profil.atWorkStyle {
                        styleByMoment.append(workStyle)
                    } else {
                    
                    }
                } else if (moments[i] == "relax"){
                    if let relaxStyle = profil.relaxStyle {
                        styleByMoment.append(relaxStyle)
                    }
                } else if (moments[i] == "onParty"){
                    if let onPartyStyle = profil.onPartyStyle {
                        styleByMoment.append(onPartyStyle)
                    }
                }
            }
        }
        if (styleByMoment.count == 0){
            styleByMoment.append("casual")
            styleByMoment.append("business")
        }
        return styleByMoment
    }
    
    func getMomentByStyle(moments: [String], style: String) -> String {
        if let profil =  ProfilsDAL().fetch(SharedData.sharedInstance.currentUserId!) {
            if ((moments[0] == "atWork" || moments[1] == "atWork") && profil.atWorkStyle == style){
                return  "at Work"
            } else if ((moments[0] == "relax" || moments[1] == "relax") && profil.relaxStyle == style){
                return  "relax"
            } else if ((moments[0] == "onParty" || moments[1] == "onParty") && profil.onPartyStyle == style){
                return  "on Party"
            }
        }
        return ""
    }
}