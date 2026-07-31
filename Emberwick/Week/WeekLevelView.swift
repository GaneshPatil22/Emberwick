//
//  WeekLevelView.swift
//  Emberwick
//
//  The calm, full-screen, DATELESS week page. Shows an era chip (if the week is in
//  an era), a soft title, the week's entries, and "Add to this week." A week is
//  derived — all entries whose date maps to this (row, column).
//
//  No dates by design: v1's divide-logic isn't calendar-accurate, so a shown date
//  could mismatch. (Revisited in Phase F once weeks are calendar-accurate.)
//

import SwiftData
import SwiftUI

struct WeekLevelView: View {
    let position: GridPosition

    @Query private var allEntries: [Entry]
    @Query private var eras: [Era]
    @AppStorage(AppConfig.birthDateKey) private var birthInterval = 0.0
    @State private var sheet: EntrySheet?

    private var birthYear: Int {
        GridMath.year(for: AppConfig.birthDate(interval: birthInterval))
    }

    private var weekDate: Date {
        GridMath.representativeDate(row: position.row, column: position.column, birthYear: birthYear)
    }

    private var weekEntries: [Entry] {
        allEntries
            .filter { GridMath.position(for: $0.date, birthYear: birthYear) == position }
            .sorted { $0.date < $1.date }
    }

    private var currentEra: Era? {
        eras.first { $0.startDate <= weekDate && weekDate <= $0.endDate }
    }

    private var subtitle: String {
        switch weekEntries.count {
        case 0: "Nothing here yet — add the first."
        case 1: "One moment lived here."
        default: "\(weekEntries.count) moments lived here."
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: EmberSpacing.md) {
                if let era = currentEra {
                    EraChip(name: era.name, tintHex: era.tintHex)
                }

                Text("A week worth keeping")
                    .font(EmberTypography.heading)
                    .foregroundStyle(EmberPalette.ink)
                Text(subtitle)
                    .font(EmberTypography.subtitle)
                    .foregroundStyle(EmberPalette.inkSoft)

                ForEach(weekEntries) { entry in
                    EntryRowView(entry: entry)
                        .onTapGesture { sheet = EntrySheet(entry: entry, weekDate: weekDate) }
                }

                Button(action: addEntry) {
                    Label("Add to this week", systemImage: "plus")
                        .font(EmberTypography.body)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, EmberSpacing.md)
                        .foregroundStyle(.white)
                        .background(EmberPalette.accent, in: .rect(cornerRadius: EmberRadius.medium))
                }
                .padding(.top, EmberSpacing.sm)
            }
            .padding(EmberSpacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(EmberPalette.paper)
        .sheet(item: $sheet) { sheet in
            EntryEditView(existingEntry: sheet.entry, weekDate: sheet.weekDate)
        }
    }

    private func addEntry() {
        sheet = EntrySheet(entry: nil, weekDate: weekDate)
    }
}
