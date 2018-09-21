//: Playground - noun: a place where people can play

import RxSwift

func example(_ description: String,
             _ action: () -> ()) {
    
    print("================== \(description) ==================")
    action()
}

public func delay(_ delay: Double,
                  closure: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        closure()
    }
}

public func stamp() -> String {
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss"
    let result = formatter.string(from: date)
    
    return result
}

// 使用connectable operator回放事件
example("使用connectable operator回放事件") {
    
//    let interval = Observable<Int>.interval(1, scheduler:MainScheduler.instance).replay(2)
//    let interval = Observable<Int>.interval(1, scheduler:MainScheduler.instance).replayAll()
//    let interval = Observable<Int>.interval(1, scheduler:MainScheduler.instance).buffer(timeSpan: 4, count: 2, scheduler: MainScheduler.instance)
    
    let interval = Observable<Int>
        .interval(1, scheduler: MainScheduler.instance)
        .window(timeSpan: 4, count: 4, scheduler: MainScheduler.instance)
    
    print("START - " + stamp())
    
    _ = interval.subscribe(onNext: {
        (subObservable: Observable<Int>) in
        print("============= Window Open ===============")
        
        _ = subObservable.subscribe(onNext: {
            (value: Int) in
            print("Subscriber 1: Event - \(value) at \(stamp())")
        }, onCompleted: {
            print("============ Window Closed ==============")
        })
    })
    
    dispatchMain()
}
