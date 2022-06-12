//
//  ContentView.swift
//  HighRoller
//
//  Created by Michael & Diana Pascucci on 6/10/22.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(\.accessibilityVoiceOverEnabled) var voiceOverEnabled
    let diceTypes = [4, 6, 8, 10, 12, 20, 100]
    
    @AppStorage("selectedDiceType") var selectedDiceType = 6
    @AppStorage("numberToRoll") var numberToRoll = 4
    @State private var currentResult = DiceResult(type: 0, number: 0)
    @State private var feedback = UIImpactFeedbackGenerator(style: .rigid)
    
    let columns: [GridItem] = [
        .init(.adaptive(minimum: 60))
    ]
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State private var stoppedDice = 0
    
    let savePath = FileManager.documentsDirectory.appendingPathComponent("SavedRolls.json")
    @State private var savedResults = [DiceResult]()
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("Type of dice", selection: $selectedDiceType) {
                        ForEach(diceTypes, id: \.self) { type in
                            Text("D\(type)")
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Stepper("Number of dice: \(numberToRoll)", value: $numberToRoll, in: 1...20)
                    
                    Button("Roll them!", action: rollDice)
                } footer: {
                    LazyVGrid(columns: columns) {
                        ForEach(0..<currentResult.rolls.count, id: \.self) { rollNumber in
                            Text(String(currentResult.rolls[rollNumber]))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .aspectRatio(1, contentMode: .fit)
                                .foregroundColor(.black)
                                .background(.white)
                                .cornerRadius(10)
                                .shadow(radius: 3)
                                .font(.title)
                                .padding(5)
                        }
                    }
                    .accessibilityElement()
                    .accessibilityLabel("Latest roll: \(currentResult.description)")
                }
                .disabled(stoppedDice < currentResult.rolls.count)
                
                if savedResults.isEmpty == false {
                    Section("Previous results") {
                        ForEach(savedResults) { result in
                            VStack(alignment: .leading) {
                                Text("\(result.number) x D\(result.type)")
                                    .font(.headline)
                                Text(result.description)
                            }
                            .accessibilityElement()
                            .accessibilityLabel("\(result.number) D\(result.type), \(result.description)")
                        }
                    }
                }
            }
            .navigationTitle("High Rollers")
            .onReceive(timer) { date in
                updateDice()
            }
            .onAppear(perform: load)
        }
    }
    
    func rollDice() {
        currentResult = DiceResult(type: selectedDiceType, number: numberToRoll)
        if voiceOverEnabled {
            stoppedDice = numberToRoll
            savedResults.insert(currentResult, at: 0)
            save()
        } else {
            stoppedDice = -20
        }
    }
    
    func updateDice() {
        guard stoppedDice < currentResult.rolls.count else { return }
        
        for i in stoppedDice..<numberToRoll {
            if i < 0 { continue }
            currentResult.rolls[i] = Int.random(in: 1...selectedDiceType)
        }
        feedback.impactOccurred()
        stoppedDice += 1
        
        if stoppedDice == numberToRoll {
            savedResults.insert(currentResult, at: 0)
            save()
        }
    }
    
    func load() {
        if let data = try? Data(contentsOf: savePath) {
            if let results = try? JSONDecoder().decode([DiceResult].self, from: data) {
                savedResults = results
            }
        }
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(savedResults) {
            try? data.write(to: savePath, options: [.atomic, .completeFileProtection])
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

/*
 Your challenge this time can be easy or hard depending on how far you want to take it, but at its core the project is simple: you need to build an app that helps users roll dice then store the results they had.
 
 At the very least you should lets users roll dice, and also let them see results from previous rolls. However, if you want to push yourself further you can try one or more of the following:
 
 1. Let the user customize the dice that are rolled: how many of them, and what type: 4-sided, 6-sided, 8-sided, 10-sided, 12-sided, 20-sided, and even 100-sided.
 
 2. Show the total rolled on the dice.
 
 3. Store the results using JSON or Core Data – anywhere they are persistent.
 
 4. Add haptic feedback when dice are rolled.
 
 5. For a real challenge, make the value rolled by the dice flick through various possible values before settling on the final figure.
 When I say “roll dice” you don’t need to create fancy 3D effects – just showing the numbers that were “rolled” is fine.
 
 The only thing that might cause you some work is step 5: making the results flick through various values before settling on the final figure. The easiest way to tackle this is through a Timer that gets cancelled after a certain number of calls.
 
 While you’re working, please take a moment to remember the accessibility of your code – try using it with VoiceOver and make sure it works as well as you can make it.
 */
