//: Playground - noun: a place where people can play

import RxSwift
import RxCocoa

func example(_ tip: String, _ closure: () -> ()) {
    print(tip)
    closure()
}

// 四种Subject的基本用法

// PublishSubject
example("PublishSubject") {
    let subject = PublishSubject<String>()
    
    let sub1 = subject.subscribe(onNext: {
        print("Sub1 - what happened: \($0)")
    })
    subject.onNext("Episode1 updated")
    
    sub1.dispose()
    
    let sub2 = subject.subscribe(onNext: {
        print("Sub2 - what happened: \($0)")
    })
    
    subject.onNext("Episode2 updated")
    subject.onNext("Episode3 updated")
    
    sub2.dispose()
}


// BehaviorSubject
example("BehaviorSubject") {
    let subject2 = BehaviorSubject<String>(
        value: "RxSwift step by step")
    
    _ = subject2.subscribe(onNext: {
        print("Sub1 - what happened: \($0)")
    })
    
    subject2.onNext("Episode1 updated")
    
    _ = subject2.subscribe(onNext: {
        print("Sub2 - what happened: \($0)")
    })
}

// ReplaySubject
example("ReplaySubject") {
    let subject = ReplaySubject<String>.create(bufferSize: 2)
    _ = subject.subscribe(onNext: {
        print("Sub1 - what happened: \($0)")
    })
    subject.onNext("Episode1 updated")
    subject.onNext("Episode2 updated")
    subject.onNext("Episode3 updated")
    
    _ = subject.subscribe(onNext: {
        print("Sub2 - what happened: \($0)")
    })
}

// Variable
example("Variable") {
    let stringVariable = BehaviorRelay(value: "Episode1")
    _ = stringVariable
        .asObservable()
        .subscribe {
            print("sub1: \($0)")
    }
    stringVariable.accept("Episode2")
}
