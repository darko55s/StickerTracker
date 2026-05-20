import SwiftData

struct SeedData {
    static let teams: [(code: String, name: String, flag: String, count: Int)] = [
        ("FWC", "FIFA World Cup",       "⚽",  19),
        ("MEX", "Mexico",               "🇲🇽", 20),
        ("RSA", "South Africa",         "🇿🇦", 20),
        ("KOR", "South Korea",          "🇰🇷", 20),
        ("CZE", "Czech Republic",       "🇨🇿", 20),
        ("CAN", "Canada",               "🇨🇦", 20),
        ("BIH", "Bosnia & Herzegovina", "🇧🇦", 20),
        ("QAT", "Qatar",                "🇶🇦", 20),
        ("SUI", "Switzerland",          "🇨🇭", 20),
        ("BRA", "Brazil",               "🇧🇷", 20),
        ("MAR", "Morocco",              "🇲🇦", 20),
        ("HAI", "Haiti",                "🇭🇹", 20),
        ("SCO", "Scotland",             "🏴󠁧󠁢󠁳󠁣󠁴󠁿", 20),
        ("USA", "United States",        "🇺🇸", 20),
        ("PAR", "Paraguay",             "🇵🇾", 20),
        ("AUS", "Australia",            "🇦🇺", 20),
        ("TUR", "Türkiye",              "🇹🇷", 20),
        ("GER", "Germany",              "🇩🇪", 20),
        ("CUW", "Curaçao",              "🇨🇼", 20),
        ("CIV", "Côte d'Ivoire",        "🇨🇮", 20),
        ("ECU", "Ecuador",              "🇪🇨", 20),
        ("NED", "Netherlands",          "🇳🇱", 20),
        ("JPN", "Japan",                "🇯🇵", 20),
        ("SWE", "Sweden",               "🇸🇪", 20),
        ("TUN", "Tunisia",              "🇹🇳", 20),
        ("BEL", "Belgium",              "🇧🇪", 20),
        ("EGY", "Egypt",                "🇪🇬", 20),
        ("IRN", "Iran",                 "🇮🇷", 20),
        ("NZL", "New Zealand",          "🇳🇿", 20),
        ("ESP", "Spain",                "🇪🇸", 20),
        ("CPV", "Cape Verde",           "🇨🇻", 20),
        ("KSA", "Saudi Arabia",         "🇸🇦", 20),
        ("URU", "Uruguay",              "🇺🇾", 20),
        ("FRA", "France",               "🇫🇷", 20),
        ("SEN", "Senegal",              "🇸🇳", 20),
        ("IRQ", "Iraq",                 "🇮🇶", 20),
        ("NOR", "Norway",               "🇳🇴", 20),
        ("ARG", "Argentina",            "🇦🇷", 20),
        ("ALG", "Algeria",              "🇩🇿", 20),
        ("AUT", "Austria",              "🇦🇹", 20),
        ("JOR", "Jordan",               "🇯🇴", 20),
        ("POR", "Portugal",             "🇵🇹", 20),
        ("COD", "DR Congo",             "🇨🇩", 20),
        ("UZB", "Uzbekistan",           "🇺🇿", 20),
        ("COL", "Colombia",             "🇨🇴", 20),
        ("ENG", "England",              "🏴󠁧󠁢󠁥󠁮󠁧󠁿", 20),
        ("CRO", "Croatia",              "🇭🇷", 20),
        ("GHA", "Ghana",                "🇬🇭", 20),
        ("PAN", "Panama",               "🇵🇦", 20),
    ]

    static func seed(context: ModelContext) {
        for (index, entry) in teams.enumerated() {
            let team = Team(
                code: entry.code,
                name: entry.name,
                flagEmoji: entry.flag,
                sortOrder: index
            )
            context.insert(team)
            for n in 1...entry.count {
                context.insert(Sticker(number: n, team: team))
            }
        }
    }
}
