//
//  AppState.swift
//  VaccineFinder
//
//  Created by Bart Whiteley on 2/24/21.
//

import Foundation
import Combine

class AppState: ObservableObject {
    @Published var events: [String: [VEvent]] = [:]
    
    static let shared: AppState = AppState()
    
    private init() {}
    
    var cancellables = Set<AnyCancellable>()
    
    func load() {
        let url = URL(string: "https://healthevents.utahcounty.gov/api/events")!
        let task = URLSession.shared.dataTaskPublisher(for: url)
        task.receive(on: DispatchQueue.main).sink { (completion: Subscribers.Completion<URLSession.DataTaskPublisher.Failure>) in
            
        } receiveValue: { (output: URLSession.DataTaskPublisher.Output) in
            guard let events = try? JSONDecoder().decode([String: [VEvent]].self, from: output.data) else { return }
            self.events = events
        }.store(in: &cancellables)

    }
}

struct VEvent: Decodable, Hashable {
    var id: Int
    var city: String
    var remaining: Int
    var title: String
}
