//
//  BirthdayField.swift
//  Emberwick
//
//  Reusable birthday input, shared by onboarding and Settings. Lets the user give an
//  exact date OR just a month & year (privacy-friendly) — month-only births anchor to
//  the 15th, which keeps the placed week within ~2 weeks of the true one.
//

import SwiftUI

struct BirthdayField: View {
    @Binding var date: Date
    /// True = exact day given; false = month & year only.
    @Binding var dayKnown: Bool

    private let calendar = Calendar.current
    private var months: [String] { calendar.monthSymbols }
    private var years: [Int] {
        let thisYear = calendar.component(.year, from: .now)
        return Array((thisYear - 120)...thisYear).reversed()
    }

    private var month: Int { calendar.component(.month, from: date) }
    private var year: Int { calendar.component(.year, from: date) }

    var body: some View {
        VStack(alignment: .leading, spacing: EmberSpacing.md) {
            Picker("Precision", selection: $dayKnown) {
                Text("Exact date").tag(true)
                Text("Month & year").tag(false)
            }
            .pickerStyle(.segmented)

            if dayKnown {
                DatePicker("", selection: $date, in: ...Date.now, displayedComponents: .date)
                    .labelsHidden()
                    .tint(EmberPalette.accentInk)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                HStack(spacing: EmberSpacing.md) {
                    menu(months[month - 1], binding: monthBinding, options: Array(1...12)) { months[$0 - 1] }
                    menu(String(year), binding: yearBinding, options: years) { String($0) }
                }
            }

            Label {
                Text("Private & on-device. Your birthday only places your weeks on the grid — it's never shared or uploaded.")
            } icon: {
                Image(systemName: "lock.fill")
            }
            .font(EmberTypography.caption)
            .foregroundStyle(EmberPalette.inkFaint)
        }
        .onChange(of: dayKnown) { _, known in
            if !known { setMonthYear(month: month, year: year) } // snap to the 15th
        }
    }

    // MARK: - Month & year menus

    private func menu(
        _ label: String,
        binding: Binding<Int>,
        options: [Int],
        title: @escaping (Int) -> String
    ) -> some View {
        Menu {
            Picker("", selection: binding) {
                ForEach(options, id: \.self) { Text(title($0)).tag($0) }
            }
        } label: {
            HStack {
                Text(label)
                    .foregroundStyle(EmberPalette.ink)
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption)
                    .foregroundStyle(EmberPalette.inkFaint)
            }
            .font(EmberTypography.body)
            .padding(EmberSpacing.md)
            .frame(maxWidth: .infinity)
            .background(EmberPalette.card, in: .rect(cornerRadius: EmberRadius.medium))
        }
    }

    private var monthBinding: Binding<Int> {
        Binding(get: { month }, set: { setMonthYear(month: $0, year: year) })
    }

    private var yearBinding: Binding<Int> {
        Binding(get: { year }, set: { setMonthYear(month: month, year: $0) })
    }

    /// Rebuilds `date` from month/year at the 15th, clamped to not exceed today.
    private func setMonthYear(month: Int, year: Int) {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 15
        if let resolved = calendar.date(from: components) {
            date = min(resolved, .now)
        }
    }
}
