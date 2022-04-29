import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

import Combine
import Foundation

var subscriptions = Set<AnyCancellable>()
let subject = PassthroughSubject<String, Never>()


subject
//  .sink { value in
//    print("Received value:", value)
//  }
  .prepend("aaaa")
  .sink(receiveValue: { string in
    print(string)
  })
  .store(in: &subscriptions)

subject.send("あ")
subject.send("い")
subject.send("う")
subject.send("え")
subject.send("お")


