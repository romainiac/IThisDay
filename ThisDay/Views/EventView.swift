//
//  EventView.swift
//  ThisDay
//
//  Created by Roman Yefimets on 3/26/24.
//

import SwiftUI
import SwiftData

struct EventView: View {
    @State private var isShowingItemSheet = false
    @State private var eventToEdit: Event?
    @Environment(\.modelContext) var context
    @Query(sort: [SortDescriptor(\Event.startTime, order: .reverse)]) private var events: [Event]
    
    var body: some View {
            NavigationStack() {
                List {
                    
                    ForEach(events) {event in EventCell(event: event)
                            .onTapGesture {
                                eventToEdit = event
                            }
                            .swipeActions() {
                                Button("Reset") {
                                    event.startTime = .now
                                }
                                .tint(.blue)
                                Button("Delete") {
                                    context.delete(event)
                                }
                                .tint(.red)
                            }
                            .listRowSeparator(.hidden)
                    }
                }
                //.listStyle(.plain)
                .listRowBackground(Color.clear)
                .listRowSpacing(10)
                .sheet(isPresented: $isShowingItemSheet, content: {
                    AddEventSheet()
                })
                .sheet(item: $eventToEdit) { event in
                    UpdateEventSheet(event: event)
                    
                }
                .toolbar {
                    ToolbarItemGroup(placement: .bottomBar) {
                        VStack {
                            Button(action: {isShowingItemSheet = true}, label: {
                                Image(systemName: "plus.circle.fill")
                            })
                        }
                        .font(.system(size: 40))
                    }
                }
                .overlay {
                    if events.isEmpty {
                        ContentUnavailableView(label: {
                            Label( "No Events", systemImage: "list.bullet.rectangle.portrait")
                        })
                    }
                }
            
        }
    }
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                context.delete(events[index])
            }
        }
    }
}

struct EventCell: View {
    
    let event: Event
    
    func getTimeDiff() -> String {
        let timeNow = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: event.startTime, to: timeNow)
        var timeDifference = ""
        if let years = components.year, years > 0 {
            timeDifference += "\(years) year"
            if years > 1 {
                timeDifference += "s"
            }
        }
        if let months = components.month, let years = components.year, months > 0 {
            if years > 0 {
                timeDifference += ", "
            }
            timeDifference += "\(months) month"
            if months > 1 {
                timeDifference += "s"
            }
        }
        if let days = components.day, 
            let months = components.month,
           let years = components.year,
            days > 0 {
            if months > 0 || years > 0 {
                timeDifference += ", "
            }
            timeDifference += "\(days) day"
            if days > 1 {
                timeDifference += "s"
            }
        }
        if timeDifference == "" {
            timeDifference = "Less Than 1 Day"
        }
        return timeDifference
    }
    
    var body: some View {

        HStack() {
            VStack(alignment: .leading)
            {
                Text(event.startTime, format: .dateTime.month(.abbreviated).day())
                Text(event.startTime, format: .dateTime.year())
            }
            Divider()
            VStack(alignment: .leading) {
            Text(getTimeDiff())
                    .bold()
                    .font(.system(size: 20))
            Text(event.title)
            }
        }
    }
}

struct AddEventSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) var context
    @State private var title: String = ""
    @State private var about: String  = ""
    @State private var startTime: Date = .now

    var body: some View {
        NavigationStack {
            Form {
                ZStack(alignment: .topLeading) {
                    if title.isEmpty {
                        Text("test")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 8)
                    }
                    TextEditor(text: $title)
                }
                //TextField(text: event?.title)
                ZStack(alignment: .topLeading) {
                    if about.isEmpty {
                        Text("Additional Comments")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 8)
                    }
                    
                }
                DatePicker("Date", selection: $startTime, displayedComponents: [.date, .hourAndMinute])
            }
            .navigationTitle("New Event")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Save") {
                        let event = Event(startTime: startTime, title: title, about: about, created:.now)
                        context.insert(event)
                        dismiss()
                    }
                }
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Cancel") {dismiss()}
                }

            }
            
        }
    }
}


struct UpdateEventSheet: View {
    @State var event: Event
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) var context
    var body: some View {
        NavigationStack {
            Form {
                TextField("Event Name", text: $event.title)
                TextField("Description", text: $event.about)
                DatePicker("Date", selection: $event.startTime, displayedComponents: [.date, .hourAndMinute])
            }
            .navigationTitle("Update Event")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Done") {dismiss()}
                }

            }
            
        }
    }
}

extension Date {

    func isEqual(to date: Date, toGranularity component: Calendar.Component, in calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, equalTo: date, toGranularity: component)
    }

    func isInSameYear(as date: Date) -> Bool { isEqual(to: date, toGranularity: .year) }
    func isInSameMonth(as date: Date) -> Bool { isEqual(to: date, toGranularity: .month) }
    func isInSameWeek(as date: Date) -> Bool { isEqual(to: date, toGranularity: .weekOfYear) }

    func isInSameDay(as date: Date) -> Bool { Calendar.current.isDate(self, inSameDayAs: date) }

    var isInThisYear:  Bool { isInSameYear(as: Date()) }
    var isInThisMonth: Bool { isInSameMonth(as: Date()) }
    var isInThisWeek:  Bool { isInSameWeek(as: Date()) }

    var isInYesterday: Bool { Calendar.current.isDateInYesterday(self) }
    var isInToday:     Bool { Calendar.current.isDateInToday(self) }
    var isInTomorrow:  Bool { Calendar.current.isDateInTomorrow(self) }

    var isInTheFuture: Bool { self > Date() }
    var isInThePast:   Bool { self < Date() }
}

#Preview {
    EventView()
        .modelContainer(for: Event.self, inMemory: true)
}
