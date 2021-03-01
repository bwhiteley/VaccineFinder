//
//  ContentView.swift
//  VaccineFinder
//
//  Created by Bart Whiteley on 2/24/21.
//

import SwiftUI

enum ListItem: Hashable {
    case date(String)
    case title(String)
    case event(VEvent)
}

struct ContentView: View {
    @ObservedObject var state: AppState = AppState.shared
    @Environment(\.openURL) var openURL
    
    var body: some View {
        VStack {
            Button("Refresh") {
                state.load()
            }.padding()
            List {
                ForEach(days(from: state.events), id: \.date) { day in
                    Section(header: Text(day.date),
                            footer: Text("ELIGIBILITY: " + (day.events.first?.title ?? "")).font(.footnote).foregroundColor(.secondary)) {
                        ForEach(day.events, id: \.id) { event in
                            if event.remaining > 0 {
                                Button(action: { openURL(url(event: event.id)) }) {
                                    cellContents(event: event)
                                }
                            } else {
                                Group {
                                    cellContents(event: event)
                                }
                            }
                        }
                    }
                }
            }
            Text("For official information about COVID-19, visit the ").multilineTextAlignment(.center)
            Link("Utah Coronavirus website", destination: URL(string: "https://coronavirus.utah.gov")!)
        }
        .onAppear {
            state.load()
        }
    }
}

func cellContents(event: VEvent) -> some View {
    VStack {
        HStack {
            Text("Location:")
            Spacer()
            Text(event.city).bold()
        }
        HStack {
            Text("Available Appointments:")
            Spacer()
            available(i: event.remaining).bold()
        }
    }//.padding(3)
}

func url(event: Int) -> URL {
    URL(string: "https://healthevents.utahcounty.gov/event/\(event)")!
}

func available(i: Int) -> Text {
    let color: Color
    switch i {
    case 1..<100: color = .orange
    case 100...: color = .green
    default: color = .red
    }
    
    return Text("\(i)").foregroundColor(color)
}

struct Day {
    var date: String
    var events: [VEvent]
}

func days(from dict: [String: [VEvent]]) -> [Day] {
    dict.sorted(by: { $0.key < $1.key })
        .filter({ $0.value.count > 0 })
        .map({ Day(date: $0.key, events: $0.value) })
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


