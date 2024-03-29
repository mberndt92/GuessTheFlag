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
    
    let labels = [
        "Estonia": "Flag with three horizontal stripes of equal size. Top stripe blue, middle stripe black, bottom stripe white",
        "France": "Flag with three vertical stripes of equal size. Left stripe blue, middle stripe white, right stripe red",
        "Germany": "Flag with three horizontal stripes of equal size. Top stripe black, middle stripe red, bottom stripe gold",
        "Ireland": "Flag with three vertical stripes of equal size. Left stripe green, middle stripe white, right stripe orange",
        "Italy": "Flag with three vertical stripes of equal size. Left stripe green, middle stripe white, right stripe red",
        "Nigeria": "Flag with three vertical stripes of equal size. Left stripe green, middle stripe white, right stripe green",
        "Poland": "Flag with two horizontal stripes of equal size. Top stripe white, bottom stripe red",
        "Russia": "Flag with three horizontal stripes of equal size. Top stripe white, middle stripe blue, bottom stripe red",
        "Spain": "Flag with three horizontal stripes. Top thin stripe red, middle thick stripe gold with a crest on the left, bottom thin stripe red",
        "UK": "Flag with overlapping red and white crosses, both straight and diagonally, on a blue background",
        "US": "Flag with red and white stripes of equal size, with white stars on a blue background in the top-left corner"
    ]
    
    @State private var correctAnswer = Int.random(in: 0...2)
    @State private var selectedAnswer: Int? = nil
    @State private var animationAmount = 0.0
    @State private var opacityNonSelected = 1.0
    
    @State private var animateAnswerCorrectness = false
    @State private var state: GameState = .questionAsked
    
    private var pendingAnswerColor = Color(red: 226 / 255, green: 135 / 255, blue: 67 / 255)
    private var correctAnswerColor = Color(red: 0.3, green: 0.7, blue: 0.26)
    private var wrongAnswerColor = Color(red: 0.76, green: 0.15, blue: 0.26)
    private var askingQuestionColor = Color(red: 0.1, green: 0.2, blue: 0.45)
    
    @State private var scaleAmount = 1.0
    
    var body: some View {
        ZStack {
            RadialGradient(stops: [
                .init(color: askingQuestionColor, location: 0.3),
                .init(color: gradientColor(), location: 0.3)
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
                                opacityNonSelected = 0.25
                                flagTapped(number)
                            }
                        } label: {
                            FlagView(imageName: countries[number])
                                .scaleEffect(scaleEffectAmount(number))
                                .accessibilityLabel(labels[countries[number], default: "Unknown flag"])
                        }
                        .rotation3DEffect(
                            .degrees(state == .answerRevealed && number == selectedAnswer ?  animationAmount : 0), axis: (x: 0, y: 1, z: 0))
                        .opacity(number == selectedAnswer ? 1 : opacityNonSelected)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
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
    
    private func scaleEffectAmount(_ number: Int) -> CGSize {
        let answerSize = number == selectedAnswer ? 1.0 : 0.8
        let result = state == .answerRevealed ? answerSize : 1.0
        return CGSize(width: result, height: result)
    }
    
    private func gradientColor() -> Color {
        let answerColor = selectedAnswer == correctAnswer ? correctAnswerColor : wrongAnswerColor
        return state == .questionAsked ? pendingAnswerColor : answerColor
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
