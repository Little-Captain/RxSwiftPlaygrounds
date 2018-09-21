//: Playground - noun: a place where people can play

import RxSwift

func example(_ description: String,
             _ action: () -> ()) {
    
    print("================== \(description) ==================")
    action()
}

// 常用的获取事件操作符

// elementAt
example("elementAt") {
    
    let tasks = PublishSubject<String>()
    let bag = DisposeBag()
    
    tasks.elementAt(0).subscribe {
        print($0)
    }
    
    tasks.onNext("T1") // 0
    tasks.onNext("T2") // 1
    tasks.onNext("T3") // 2
    tasks.onCompleted()
}

// filter
example("filter") {
    
    let tasks = PublishSubject<String>()
    let bag = DisposeBag()
    
    tasks.filter { $0 == "T2" }.subscribe {
        print($0)
    }
    
    tasks.onNext("T1") // 0
    tasks.onNext("T2") // 1
    tasks.onNext("T3") // 2
    tasks.onCompleted()
}

// take
example("take") {
    
    let tasks = PublishSubject<String>()
    let bag = DisposeBag()
    
    tasks.take(2).subscribe {
        print($0)
    }
    
    tasks.onNext("T1") // 0
    tasks.onNext("T2") // 1
    tasks.onNext("T3") // 2
    tasks.onCompleted()
}

// takeWhile
example("takeWhile") {
    
    let tasks = PublishSubject<String>()
    let bag = DisposeBag()
    
    tasks.takeWhile { $0 != "T3" }.subscribe {
        print($0)
    }
    
    tasks.onNext("T1") // 0
    tasks.onNext("T2") // 1
    tasks.onNext("T3") // 2
    tasks.onNext("T1")
    tasks.onNext("T2")
    tasks.onCompleted()
}

// takeWhileWithIndex
example("takeWhileWithIndex") {
    
    let tasks = PublishSubject<String>()
    let bag = DisposeBag()
    
    tasks.takeWhileWithIndex { (value, index) in
        value != "T3" && index < 3
    }.subscribe {
        print($0)
    }
    
    tasks.onNext("T1") // 0
    tasks.onNext("T2") // 1
    tasks.onNext("T3") // 2
    tasks.onNext("T1")
    tasks.onNext("T2")
    tasks.onCompleted()
}

// takeUntil
example("takeUntil") {
    
    let tasks = PublishSubject<String>()
    let bossHasGone = PublishSubject<Void>()
    let bag = DisposeBag()
    
    tasks.takeUntil(bossHasGone)
        .subscribe {
            print($0)
        }
        .disposed(by: bag)
    
    tasks.onNext("T1")
    tasks.onNext("T2")
    bossHasGone.onNext(())
    tasks.onNext("T3")
    tasks.onCompleted()
}
