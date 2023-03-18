//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by Maximilian Berndt on 2023/03/09.
//

import SwiftUI

struct FlagView : View {
    
    var imageName: String
    
    var body: some View {
        Image(imageName)
            .renderingMode(.original)
            .clipShape(Capsule())
            .shadow(radius: 5)
    }
}

struct ContentView: View {
    
    private var totalGameQuestions = 8
    
    enum GameState {
        case questionAsked
        case answerRevealed
        case gameOver
    }
    
    @State private var showingScore = false
    @State private var showingNewGame = false
    @State private var scoreTitle = ""
    @State private var score = 0
    @State private var questionsAsked = 1
    
    @State private var countries = [
    "Estonia",
    "France",
    "Germany",
    "Ireland",
    "Italy",
    "Nigeria",
    "Poland",
    "Russia",
    "Spain",
    "UK",
    "US"
    ].shuffled()
    
    @State private var correctAnswer = Int.random(in: 0...2)
    @State private var selectedAnswer: Int? = nil
    @State private var animationAmount = 0.0
    @State private var opacityNonSelected = 1.0
    
    @State private var animateAnswerCorrectness = false
    @State private var state: GameState = .questionAsked
    
    var body: some View {
        ZStack {
            RadialGradient(stops: [
                .init(color: Color(red: 0.1, green: 0.2, blue: 0.45), location: 0.3),
                .init(color: Color(red: 0.76, green: 0.15, blue: 0.26), location: 0.3)
            ], center: .top, startRadius: 200, endRadius: 700)
            .ignoresSafeArea()
            VStack {
                Spacer()
                Text("Guess the Flag")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                VStack(spacing: 15) {
                    VStack {
                        Text("Tap the flag of")
                            .foregroundStyle(.secondary)
                            .font(.subheadline.weight(.heavy))
                        Text(countries[correctAnswer])
                            .font(.largeTitle.weight(.semibold))
                    }
                    ForEach(0..<3) { number in
                        Button {
                            withAnimation {
                                selectedAnswer = number
                                animationAmount += 360
                                opacityNonSelected = 0.2
                                flagTapped(number)
                            }
                        } label: {
                            FlagView(imageName: countries[number])
                        }
                        .rotation3DEffect(
                            .degrees(state == .answerRevealed && number == selectedAnswer ?  animationAmount : 0), axis: (x: 0, y: 1, z: 0))
                        .opacity(number == selectedAnswer ? 1 : opacityNonSelected)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
//                .background(state != .questionAsked ? .regularMaterial : selectedAnswer == correctAnswer ? .red : .green)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                Spacer()
                Spacer()
                Text("Score: \(score)")
                    .foregroundColor(.white)
                    .font(.title.bold())
                Spacer()
            }.padding()
        }
        .alert("Final Score", isPresented: $showingNewGame) {
            Button("New Game", action: newGame)
        } message: {
            Text("Your final score is \(score)")
        }
    }
    
    private func flagTapped(_ number: Int) {
        switch state {
        case .questionAsked:
            print("questionAsked")
            evaluateAnswer(number)
        case .answerRevealed:
            print("answerRevealed")
            askQuestion()
        case .gameOver:
            print("gameOver")
            showingNewGame = true
        }
    }
    
    private func evaluateAnswer(_ number: Int) {
        state = .answerRevealed
        if number == correctAnswer {
            scoreTitle = "Correct"
            score += 1
        } else {
            scoreTitle = "Wrong, that is the flag of \(countries[number])"
        }
        
        if questionsAsked == totalGameQuestions {
            showingNewGame = true
            state = .gameOver
        }
    }
    
    private func askQuestion() {
        state = .questionAsked
        withAnimation {
            opacityNonSelected = 1
        }
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        questionsAsked += 1
    }
    
    private func newGame() {
        questionsAsked = 0
        score = 0
        askQuestion()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
