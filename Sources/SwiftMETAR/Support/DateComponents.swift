import Foundation

extension DateComponents {
    private var mostSignificantEmptyComponent: Calendar.Component? {
        if year != nil { return .era }
        if month != nil { return .year }
        if day != nil { return .month }
        if hour != nil { return .day }
        if minute != nil { return .hour }
        if second != nil { return .minute }
        if nanosecond != nil { return .second }
        return nil
    }
    
    func merged(with other: DateComponents) -> DateComponents? {
        guard let calendar = calendar,
              let date = date,
              let timeZone = timeZone,
              let period = other.mostSignificantEmptyComponent,
              let start = date.startOf(period),
              let compDate = start.next(other) else { return nil }
        return calendar.dateComponents(in: timeZone, from: compDate)
    }
}

extension DateComponents {
    var tafDayHour: String {
        let startDayString = day.map { day in String(format: "%02d", day) } ?? "//"
        let startHourString = hour.map { hour in String(format: "%02d", hour) } ?? "//"
        return "\(startDayString)\(startHourString)"
    }
    
    var tafDayHourMinute: String {
        let startDayString = day.map { day in String(format: "%02d", day) } ?? "//"
        let startHourString = hour.map { hour in String(format: "%02d", hour) } ?? "//"
        let startMinuteString = minute.map { minute in String(format: "%02d", minute) } ?? "//"
        return "\(startDayString)\(startHourString)\(startMinuteString)"
    }
}
