import Foundation

/**
 An aviation routine weather reports. METARs are generated by human observers
 or sensor packages at many airports throughout the world. METARs are typically
 generated hourly, but can also be produced as needed when weather changes more
 frequently.
 
 METARs indicate observed weather in a 5-mile radius around a reporting site.
 */

public struct METAR: Codable {
    
    /// The raw text of the METAR.
    public let text: String?
    
    /// The nature of this METAR's publivation.
    public let issuance: Issuance
    
    /// The ICAO ID of the reporting station (typically an airport).
    public let stationID: String
    
    /// The components for the date this METAR was generated.
    public let calendarDate: DateComponents
    
    /// Who or what recorded the observation.
    public let observer: Observer
    
    /// The recorded winds.
    public let wind: Wind?
    
    /// The recorded visibility amount.
    public let visibility: Visibility?
    
    /// Any runway visibilities recorded.
    public let runwayVisibility: Array<RunwayVisibility>
    
    /// Any observed weather phenomena. An empty array means no weather
    /// phenomena exists; `nil` means no data was provided.
    public let weather: Array<Weather>?
    
    /// Any observed cloud layers, or other sky conditions.
    public let conditions: Array<Condition>
    
    /// The current temperature, in degrees Celsius.
    public let temperature: Int8?
    
    /// The dewpoint, in degrees Celsius.
    public let dewpoint: Int8?
    
    /// The sea-level pressure, used by pilots to set their altimeter datum.
    public let altimeter: Altimeter?
    
    /// Remarks published along with the METAR. Remarks are typically
    /// machine-generated, but can also be human-written in plain text.
    public let remarks: Array<RemarkEntry>
    
    /// Raw remarks, before parsing.
    public let remarksString: String?
    
    /// The date this METAR was generated.
    public var date: Date { calendarDate.date! }
    
    /**
     Parse a METAR from its text.
     
     - Parameter string: The METAR text.
     - Parameter date: METAR dates only include the day and hour. By default,
                       the month and year are taken from the current date. If
                       you pass in a date here, its month and year will be used
                       for the METAR dates.
     - Parameter lenientRemarks: If true, does not require the string "RMK" to
                                 appear before the remarks section. This will
                                 reduce the amount of errors when parsing non-US
                                 METARs, but can result in mis-formatted weather
                                 data being parsed as a remark.
     - Returns: The parsed METAR.
     - Throws: If a parsing error occurs.
     */
    public static func from(string: String, on date: Date? = nil, lenientRemarks: Bool = false) throws -> METAR {
        return try parseMETAR(string, on: date, lenientRemarks: lenientRemarks)
    }
    
    /// Possible reasons for a METAR publication.
    public enum Issuance: String, Codable {
        
        /// Routine hourly METAR.
        case routine = "METAR"
        
        /// METAR was generated in response to significant weather.
        case special = "SPECI"
    }

    /// Sources for METAR observations.
    public enum Observer: String, Codable {
        
        /// A trained observer recorded this METAR.
        case human = ""
        
        /// A meteorological sensor package recorded this METAR.
        case automated = "AUTO"
        
        /// This is a corrected report.
        case corrected = "COR"
    }
}
