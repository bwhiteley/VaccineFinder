//
//  ContentView.swift
//  VaccineFinder
//
//  Created by Bart Whiteley on 2/24/21.
//

import SwiftUI

enum ListItem {
    case date(String)
    case title(String)
    case event(VEvent)
}

struct ContentView: View {
    @ObservedObject var state: AppState = AppState.shared
    @Environment(\.openURL) var openURL
    
    var body: some View {
        Button("💉 Refresh 💉") {
            state.load()
        }.padding()
        List(days(from: state.events), id: \.date) { day in
            VStack {
                Divider()
                Text(day.date).font(.title)
                Text(day.events.first?.title ?? "").font(.footnote).padding(5)
                Group {
                    ForEach(day.events, id: \.id) { event in
                        Button(action: { openURL(URL(string: "https://healthevents.utahcounty.gov/event/\(event.id)")!) }) {
                        HStack {
                            Text(event.city)
                            available(i: event.remaining)
                            Spacer()
                        }.padding(3)}
                    }
                }
            }
        }
        .onAppear {
            state.load()
        }
    }
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


