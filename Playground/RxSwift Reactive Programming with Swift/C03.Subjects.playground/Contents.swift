//: Playground - noun: a place where people can play

import RxSwift

//: Subject
// Observer, Observable, Subscriber, Event, Value
// Observer 收集 Value, 形成 Observable
// Subscriber 订阅 Observable, 捕获 Event, 获取 Value
example(of: "PublishSubject") {
    let subject = PublishSubject<String>()
    subject.onNext("Is anyone listening")
    let subscriptionOne = subject
        .subscribe(onNext: { string in
            print(string)
        })
    subject.on(.next("1"))
    subject.onNext("2")
    let subscriptionTwo = subject
        .subscribe({ event in
            print("2)", event.element ?? event)
        })
    subject.onNext("3")
    subscriptionOne.dispose()
    subject.onNext("4")
    // 1
    subject.onCompleted()
    // 2
    subject.onNext("5")
    // 3
    subscriptionTwo.dispose()
    let disposeBag = DisposeBag()
    // 4
    subject
        .subscribe {
            print("3)", $0.element ?? $0)
        }
        .disposed(by: disposeBag)
    subject.onNext("?")
}

enum MyError: Error {
    case anError
}

func print<T: CustomStringConvertible>(label: String, event: Event<T>) {
    print(label, event.element ?? event.error ?? event)
}
// BehaviorSubject
// 发送最新的事件给新订阅者: .next, .completed, .error
example(of: "BehaviorSubject") {
    let subject = BehaviorSubject(value: "Initial value")
    subject.onNext("X")
    subject.onNext("Y")
    let disposeBag = DisposeBag()
    subject
        .subscribe {
            print(label: "1)", event: $0)
        }
        .disposed(by: disposeBag)
    // 1
//    subject.onError(MyError.anError)
    subject.onCompleted()
    // 2
    subject
        .subscribe {
            print(label: "2)", event: $0)
        }
        .disposed(by: disposeBag)
}

// ReplaySubject
// 仅仅缓存非完成事件(.next)
// 发送缓存的所有事件, 以及最后的完成事件(.completed, .error)给新订阅者
example(of: "ReplaySubject") {
    // 1
    let subject = ReplaySubject<String>.create(bufferSize: 2)
    let disposeBag = DisposeBag()
    // 2
    subject.onNext("1")
    subject.onNext("2")
    subject.onNext("3")
    // 3
    subject
        .subscribe {
            print(label: "1)", event: $0)
        }
        .disposed(by: disposeBag)
    subject
        .subscribe {
            print(label: "2)", event: $0)
        }
        .disposed(by: disposeBag)
    subject.onNext("4")
    subject.onError(MyError.anError)
    //    subject.dispose()
    subject
        .subscribe {
            print(label: "3)", event: $0)
        }
        .disposed(by: disposeBag)
}

example(of: "Variable") {
    // 1
    let varibale = Variable("Initial value")
    let disposeBag = DisposeBag()
    // 2
    varibale.value = "New initial value"
    // 3
    varibale.asObservable()
        .subscribe {
            print(label: "1)", event: $0)
        }
        .disposed(by: disposeBag)
    
    // 1
    varibale.value = "1"
    varibale.asObservable()
        .subscribe {
            print(label: "2)", event: $0)
    }
        .disposed(by: disposeBag)
    varibale.value = "2"
}

example(of: "Create a blackjack card dealer using a publish subject") {
    
    let disposeBag = DisposeBag()
    
    let dealtHand = PublishSubject<[(String, Int)]>()
    
    func deal(_ cardCount: UInt) {
        var deck = cards
        var cardsRemaining: UInt32 = 52
        var hand = [(String, Int)]()
        
        for _ in 0..<cardCount {
            let randomIndex = Int(arc4random_uniform(cardsRemaining))
            hand.append(deck[randomIndex])
            deck.remove(at: randomIndex)
            cardsRemaining -= 1
        }
        
        // Add code to update dealtHand here
        if points(for: hand) > 21 {
            dealtHand.onError(HandError.busted)
        } else {
            dealtHand.onNext(hand)
        }
        
    }
    
    // Add subscription to dealtHand here
    dealtHand
        .subscribe(
            onNext: {
                print(cardString(for: $0), "for", points(for: $0), "points")
        },
            onError: {
                print(String(describing: $0).capitalized)
        })
        .disposed(by: disposeBag)
    
    deal(3)
}

example(of: "Observe and check user session state using a variable") {
    
    enum UserSession {
        case loggedIn, loggedOut
    }
    
    enum LoginError: Error {
        case invalidCredentials
    }
    
    let disposeBag = DisposeBag()
    
    // Create userSession Variable of type UserSession with initial value of .loggedOut
    let userSession: Variable<UserSession> = Variable(.loggedOut)
    
    // Subscribe to receive next events from userSession
    userSession.asObservable()
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
    
    
    func logInWith(username: String, password: String, completion: (Error?) -> Void) {
        guard username == "johnny@appleseed.com",
            password == "appleseed"
            else {
                completion(LoginError.invalidCredentials)
                return
        }
        
        // Update userSession
        completion(nil)
        userSession.value = .loggedIn
    }
    
    func logOut() {
        // Update userSession
        userSession.value = .loggedOut
    }
    
    func performActionRequiringLoggedInUser(_ action: () -> Void) {
        // Ensure that userSession is loggedIn and then execute action()
        guard userSession.value == .loggedIn else { return }
        action()
    }
    
    for i in 1...2 {
        let password = i % 2 == 0 ? "appleseed" : "password"
        
        logInWith(username: "johnny@appleseed.com", password: password) { error in
            guard error == nil else {
                print(error!)
                return
            }
            
            print("User logged in.")
        }
        
        performActionRequiringLoggedInUser {
            print("Successfully did something only a logged in user can do.")
        }
    }
}
