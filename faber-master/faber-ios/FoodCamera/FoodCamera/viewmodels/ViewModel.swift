//
//  ViewModel.swift
//  FoodCamera
//
//  Created by Faber Labs on 4/6/20.
//  Copyright © 2020 Yinghui Linda He. All rights reserved.
//

import Foundation
import Combine

// the ViewModel protocol. Each ViewModel has a state, and accepts a type of inputs
protocol ViewModel: ObservableObject where ObjectWillChangePublisher.Output == Void {
    associatedtype State
    associatedtype Input  // data input from View to the ViewModel. Type should be Never if a View does not accept user input

    var state: State { get }
    func trigger(_ input: Input)  // actions to perform when given different kinds of inputs from a View. Does not return
}

@dynamicMemberLookup
final class AnyViewModel<State, Input>: ViewModel {

    // stored properties
    private let wrappedObjectWillChange: () -> AnyPublisher<Void, Never>
    private let wrappedState: () -> State
    private let wrappedTrigger: (Input) -> Void

    // computed properties
    var objectWillChange: AnyPublisher<Void, Never> {
        wrappedObjectWillChange()
    }

    var state: State {
        wrappedState()
    }

    func trigger(_ input: Input) {
        wrappedTrigger(input)
    }

    subscript<Value>(dynamicMember keyPath: KeyPath<State, Value>) -> Value {
        state[keyPath: keyPath]
    }

    init<V: ViewModel>(_ viewModel: V) where V.State == State, V.Input == Input {
        self.wrappedObjectWillChange = { viewModel.objectWillChange.eraseToAnyPublisher() }
        self.wrappedState = { viewModel.state }
        self.wrappedTrigger = viewModel.trigger
    }

}
