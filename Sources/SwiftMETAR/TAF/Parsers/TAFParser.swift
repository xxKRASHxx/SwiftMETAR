import Foundation

func parseTAF(_ codedTAF: String, on referenceDate: Date? = nil, lenientRemarks: Bool = false) throws -> TAF {
    var parts = codedTAF.split(separator: .whitespacesAndNewlines)
    
    let issuance = try parseIssuance(&parts)
    let locationID = try parseLocationID(&parts)
    let date = try parseDate(&parts, referenceDate: referenceDate)
    
    var groups = Array<TAF.Group>()
    while !parts.isEmpty {
        guard let period = try parsePeriod(&parts, referenceDate: date.date!) else { break }
        let wind = try parseWind(&parts)
        let visibility = try parseVisibility(&parts)
        let weather = try parseWeather(&parts)
        let conditions = try parseConditions(&parts)
        let windshear = try parseWindshear(&parts)
        let windshearConditions = try parseWindshearConditions(&parts)
        let icing = try parseIcing(&parts)
        let turbulence = try parseTurbulence(&parts)
        let altimeter = try parseTAFAltimeter(&parts)
        
        groups.append(TAF.Group(period: period,
                                wind: wind,
                                visibility: visibility,
                                weather: weather,
                                conditions: conditions,
                                windshear: windshear,
                                windshearConditions: windshearConditions,
                                icing: icing,
                                turbulence: turbulence,
                                altimeter: altimeter))
    }
    
    let temperatures = try parseTemperatures(&parts, date: date)
    let remarks = try parseRemarks(&parts, date: date, lenientRemarks: lenientRemarks)
    
    return TAF(text: codedTAF,
               issuance: issuance,
               airportID: locationID,
               originCalendarDate: date,
               groups: groups,
               temperatures: temperatures,
               remarks: remarks)
}

fileprivate func parseIssuance(_ parts: inout Array<String.SubSequence>) throws -> TAF.Issuance {
    guard !parts.isEmpty else { throw Error.badFormat }

    if parts[0] != "TAF" { return .routine }
    parts.removeFirst()
    guard !parts.isEmpty else { throw Error.badFormat }
    
    switch parts[0] {
        case "AMD":
            parts.removeFirst()
            return .amended
        case "COR":
            parts.removeFirst()
            return .corrected
        default:
            return .routine
    }
}
