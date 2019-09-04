//: Playground - noun: a place where people can play

import RxSwift

func example(_ description: String,
             _ action: () -> ()) {
    print("================== \(description) ==================")
    action()
}

// 如何合并Observables中的事件
// combineLatest
// 1. 都 completed 总的才 completed
// 2. 任何一个 error 总的就 error
// 3. 任何一个发出新值，总的就发出新值

// 把多个Observables中的事件合并为一个
example("处理事件的前置条件") {
    enum E: Error {
        case demo
    }
    
    let bag = DisposeBag()
    
    let queueA = PublishSubject<String>()
    //    let queueB = PublishSubject<String>()
    let queueB = PublishSubject<Int>()
    
    //    let sequence = Observable
    //        .combineLatest(queueA, queueB) {
    //            eventA, eventB in
    //            eventA + "," + eventB
    //        }
    let sequence = Observable
        .combineLatest(queueA, queueB) {
            eventA, eventB in
            eventA + "," + String(eventB)
    }
    
    sequence
        .subscribe(onNext: {
            dump($0)
        }, onError: {
            print($0)
        }, onCompleted: {
            print("Completed")
        },onDisposed:  {
            print("Disposed")
        })
        .disposed(by: bag)
    
    //    queueA.onNext("A1")
    //    queueB.onNext("B1")
    //    queueA.onNext("A2")
    //    queueB.onNext("B2")
    queueA.onNext("A1")
    queueB.onNext(1)
    //    queueA.onCompleted()
    queueA.onNext("A2")
    //    queueA.onError(E.demo) // error 发生，sequence 异常终止
    queueB.onNext(2)
    //    queueB.onCompleted()
    queueB.onNext(3)
}

// 真正只合并最新事件的operator
// zip
// 1. 都 completed 总的才 completed
// 2. 任何一个 error 总的就 error
// 3. 都发出新值，总的才发出新值
example("真正只合并最新事件的operator") {
    enum E: Error {
        case demo
    }
    
    let bag = DisposeBag()
    
    let queueA = PublishSubject<String>()
    //    let queueB = PublishSubject<String>()
    let queueB = PublishSubject<Int>()
    
    //    let sequence = Observable
    //        .combineLatest(queueA, queueB) {
    //            eventA, eventB in
    //            eventA + "," + eventB
    //        }
    let sequence = Observable
        .zip(queueA, queueB) {
            eventA, eventB in
            eventA + "," + String(eventB)
    }
    
    sequence
        .subscribe(onNext: {
            dump($0)
        }, onError: {
            print($0)
        }, onCompleted: {
            print("Completed")
        },onDisposed:  {
            print("Disposed")
        })
        .disposed(by: bag)
    
    queueA.onNext("A1")
    queueB.onNext(1)
    print("point 1")
    //    queueA.onCompleted()
    print("point 2")
    queueA.onNext("A2")
    queueB.onNext(2)
    //    queueB.onError(E.demo)
    queueB.onNext(3)
    print("point 3")
    //    queueB.onCompleted()
}
