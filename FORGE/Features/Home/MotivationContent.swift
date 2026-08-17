import Foundation

enum MotivationContent {
    /// Witty, confident daily rhymes — shown when yesterday wasn't missed.
    static let dailyRhymes: [String] = [
        "No shortcuts, no excuse — showing up is the whole point of the truce.",
        "The plan's already made. Just go collect what you're owed.",
        "You didn't come this far to only come this far.",
        "Strong isn't sudden. It's just today, repeated on purpose.",
        "The weights don't care about your mood. Lift anyway.",
        "Today's rep count doesn't lie — neither should your effort.",
        "Discipline looks boring on camera and unstoppable on paper.",
        "You've got one body and zero rehearsals. Make today count.",
        "Small sets, steady gains — the boring stuff that actually works.",
        "Nobody's coming to do your set for you. Good. You've got this.",
        "Consistency is the only flex that compounds.",
        "Show up tired, leave proud — that's the whole trade.",
        "The mirror's patient. Keep giving it something to notice.",
        "Today's workout is just yesterday's promise, collected.",
    ]

    /// Comeback pep-talks — shown after a missed day, still witty but a little warmer.
    static let comebackLines: [String] = [
        "Yesterday's a write-off. Today's a clean page — pick up the pen.",
        "One missed day isn't a slump, it's a comma, not a period.",
        "Streaks break. Habits don't, if you just show up again.",
        "You didn't lose your progress overnight — go prove it.",
        "Nobody's grading yesterday. Today's the only rep that counts.",
        "Rust shakes off in about one set. Let's find out.",
        "Comeback tour starts now — no opening act needed.",
        "The streak resets. The strength doesn't. Get back in there.",
    ]

    static func rhyme(for date: Date) -> String {
        let day = Calendar.forge.ordinality(of: .day, in: .year, for: date) ?? 1
        return dailyRhymes[day % dailyRhymes.count]
    }

    static func comeback(for date: Date) -> String {
        let day = Calendar.forge.ordinality(of: .day, in: .year, for: date) ?? 1
        return comebackLines[day % comebackLines.count]
    }

    static func greeting(for date: Date = Date()) -> String {
        let hour = Calendar.forge.component(.hour, from: date)
        switch hour {
        case 0..<5: return "Still up"
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Late one"
        }
    }
}
