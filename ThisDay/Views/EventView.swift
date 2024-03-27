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
    
    var body: some View {
        HStack() {
            VStack(alignment: .leading)
            {
                Text(event.startTime, format: .dateTime.month(.abbreviated).day())
                Text(event.startTime, format: .dateTime.year())
            }
            Divider()
            VStack(alignment: .leading) {
                Text(event.startTime, format: .dateTime.year())
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

#Preview {
    EventView()
        .modelContainer(for: Event.self, inMemory: true)
}
