import Foundation

extension DateFormatter {

    static let apiDateTime: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm"
        return f
    }()

    static let displayTime: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    static let apiDate: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    static let dayName: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale.current
        f.dateFormat = "EEEE"
        return f
    }()
}

extension Date {

    var currentHour: Int {
        Calendar.current.component(.hour, from: self)
    }

    var apiDateString: String {
        DateFormatter.apiDate.string(from: self)
    }

    var displayTimeString: String {
        DateFormatter.displayTime.string(from: self)
    }

    var localizedDayName: String {
        DateFormatter.dayName.string(from: self).capitalized
    }
}

extension String {

    var dateFromAPI: Date? {
        DateFormatter.apiDateTime.date(from: self)
    }

    var dateFromAPIDate: Date? {
        DateFormatter.apiDate.date(from: self)
    }
}
