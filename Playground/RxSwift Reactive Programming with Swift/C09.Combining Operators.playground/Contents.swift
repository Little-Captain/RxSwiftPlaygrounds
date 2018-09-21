//: Playground - noun: a place where people can play

import RxSwift
import RxCocoa

//: Combining Operators

example(of: "startWith") {
    let bag = DisposeBag()
    let numbers = Observable.of(2, 3, 4)
    let observable = numbers.startWith(1)
    observable
        .subscribe(onNext: { print($0) })
        .disposed(by: bag)
}

example(of: "Observable.concat") {
    let bag = DisposeBag()
    let first = Observable.of(1, 2, 3)
    let second = Observable.of(4, 5, 6)
    let observable = Observable.concat([first, second])
    observable
        .subscribe(onNext: { print($0) })
        .disposed(by: bag)
}

example(of: "concat") {
    let bag = DisposeBag()
    let germanCities = Observable.of("Berlin", "Munich", "Frankfurt")
    let spanishCities = Observable.of("Madrid", "Barcelona", "Valencia")
    let observable = germanCities.concat(spanishCities)
    observable
        .subscribe(onNext: { print($0) })
        .disposed(by: bag)
}

example(of: "concatMap") {
    let sequences = [
        "Germany": Observable.of("Berlin", "Munich", "Frankfurt"),
        "Spain": Observable.of("Madrid", "Barcelona", "Valencia")
    ]
    
    let observable = Observable.of("Germany", "Spain")
        .concatMap { sequences[$0] ?? .empty() }
    
    _ = observable.subscribe(onNext: { print($0) })
}

//: merge

// A merge() observable subscribes to each of the sequences it receives and
// emits the elements as soon as they arrive — there’s no predefined order.
// 一个 merge() observable 订阅它收到的每一个序列
// 然后在它收到元素后马上发出, 这里没有预定义的顺序

// merge() completes after its source sequence completes and all inner
// sequences have completed.
// merge() 在原序列完成且所有内部序列完成后完成

// The order in which the inner sequences complete is irrelevant.
// 内部序列完成的顺序无关紧要

// If any of the sequences emit an error, the merge() observable
// immediately relays the error, then terminates.
// 如果任何一个序列发出错误, merge() observable 立即发出错误, 然后结束
example(of: "merge") {
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()
    let source = Observable.of(left.asObservable(), right.asObservable())
    let observable = source.merge()
    let disposable = observable.subscribe(onNext: { print($0) })
    var leftValues = ["Berlin", "Munich", "Frankfurt"]
    var rightValues = ["Madrid", "Barcelona", "Valencia"]
    repeat {
        if arc4random_uniform(2) == 0 {
            if !leftValues.isEmpty {
                left.onNext("Left: " + leftValues.removeFirst())
            }
        } else if !rightValues.isEmpty {
            right.onNext("Right: " + rightValues.removeFirst())
        }
    } while !leftValues.isEmpty || !rightValues.isEmpty
    disposable.dispose()
}

example(of: "combineLatest") {
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()
    
    let observable = Observable
//        .combineLatest(left, right) { "\($0) \($1)" }
        .combineLatest([left, right]) { $0.joined(separator: " ") }
    
    let disposable = observable.subscribe(onNext: { print($0) })
    
    print("> Sending a value to Left")
    left.onNext("Hello,")
    print("> Sending a value to Right")
    right.onNext("world")
    print("> Sending another value to Right")
    right.onNext("RxSwift")
    print("> Sending another value to Left")
    left.onNext("Have a good day,")
    
    disposable.dispose()
}

example(of: "combine user choice and value") {
    let choice: Observable<DateFormatter.Style> = Observable.of(.short, .long)
    let dates = Observable.of(Date())
    
    let observable = Observable.combineLatest(choice, dates) { format, when -> String in
        let formatter = DateFormatter()
        formatter.dateStyle = format
        return formatter.string(from: when)
    }
    
    observable
        .subscribe(onNext: { print($0) })
}

//: zip
// zip(_:_:resultSelector:) did for you:
// 1. Subscribed to the observables you provided.
// 2. Waited for each to emit a new value.
// 3. Called your closure with both new values.
// zip(_:_:resultSelector:) 为你做的:
// 1. 订阅你提供的所有序列
// 2. 等待他们发出新值
// 3. 使用每个序列的新值调用你的闭包

// The explanation lies in the way zip operators work.
// They wait until each of the inner observables emits a new value.
// If one of them completes, zip completes as well.
// It doesn’t wait until all of the inner observables are done!
// This is called indexed sequencing, which is a way to walk though
// sequences in lockstep.
// zip 的工作方式
// 等待每一个内部序列发出新值
// 如果某个内部序列完成, zip 完成
// zip 不等待所有内部序列完成
// 这被称为索引序列, 所有内部序列被步伐一致的遍历
example(of: "zip") {
    enum Weather {
        case cloudy
        case sunny
    }
    let left: Observable<Weather> = Observable.of(.sunny, .cloudy, .cloudy, .sunny)
    let right = Observable.of("Lisbon", "Copenhagen", "London", "Madrid", "Vienna")
    
    let observable = Observable.zip(left, right) { "It's \($0) in \($1)" }
    
    observable
        .subscribe(onNext: { print($0) })
}

//: withLatestFrom
// withLatestFrom 在处理用户界面时, 非常有用

// withLatestFrom(_:) is useful in all situations where you want
// the current (latest) value emitted from an observable,
// but only when a particular trigger occurs.
// withLatestFrom(_:) 的使用场景: 当你需要通过触发发出某个序列的最新值时
example(of: "withLatestFrom") {
    let button = PublishSubject<Void>()
    let textField = PublishSubject<String>()
    
    let observable = button.withLatestFrom(textField)
    
    _ = observable.subscribe(onNext: { print($0) })
    
    textField.onNext("Par")
    textField.onNext("Pari")
    textField.onNext("Paris")
    
    button.onNext(())
    button.onNext(())
}

//: sample
// A close relative to withLatestFrom(_:) is the sample(_:) operator.
// sample(_:) 与 withLatestFrom(_:) 相似

// It does nearly the same thing with just one variation: each time the
// trigger observable emits a value, sample(_:) emits the latest value
// from the “other” observable, but only if it arrived since the last “tick”.
// If no new data arrived, sample(_:) won’t emit anything.
// sample(_:) 几乎就是 withLatestFrom(_:) 的一个变体:
// 每次 trigger observable 发出一个值, sample(_:) 发出序列的最新值
// 但是只有在自上次以来有新值到达才发出
// 如果没有新数据到达, sample(_:) 不会发出任何值

// You could have achieved the same behavior by adding
// a distinctUntilChanged() to the withLatestFrom(_:) observable,
// but smallest possible operator chains are the Zen of Rx
// 在 withLatestFrom(_:) 后添加 distinctUntilChanged() 可以实现 sample(_:)
// 相同的功能. 但是最小可能的操作链是 Rx 之禅

// Note: Don’t forget that withLatestFrom(_:) takes the data observable as a parameter,
// while sample(_:) takes the trigger observable as a parameter.
// This can easily be a source of mistakes — so be careful!
// 注意: 不要忘了 withLatestFrom(_:) 把数据序列作为参数
// 而 sample(_:) 把触发序列作为参数
// 这常常是错误的根源, 请一定小心!
example(of: "sample") {
    let button = PublishSubject<Void>()
    let textField = PublishSubject<String>()
    
    let observable = textField.sample(button)
    
    _ = observable.subscribe(onNext: { print($0) })
    
    textField.onNext("Par")
    textField.onNext("Pari")
    textField.onNext("Paris")
    
    button.onNext(())
    textField.onNext("Pariss")
    button.onNext(())
    button.onNext(())
}

//: amb: ambiguity
// The amb(_:) operator subscribes to left and right observables.
// It waits for any of them to emit an element, then unsubscribes
// from the other one. After that, it only relays elements from
// the first active observable. It really does draw its name from
// the term ambiguous: at first, you don’t know which sequence
// you’re interested in, and want to decide only when one fires.
// amb(_:) 订阅 左右两个序列
// 它等待它们中任何一个发出元素, 然后取消订阅另一个
// 然后, 它只转发首先活跃的序列的元素
// 它的名字来源于: ambiguous
// 首先, 你不知道那个序列是你感兴趣的, 然后想通过那个首先发出元素确定使用那个
example(of: "amb") {
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()
    
    let observable = left.amb(right)
    let disposable = observable.subscribe(onNext: { print($0) })
    
    right.onNext("Copenhagen")
    left.onNext("Lisbon")
    left.onNext("London")
    left.onNext("Madrid")
    right.onNext("Vienna")
    
    disposable.dispose()
}

//  switchLatest() 和 flatMapLatest(_:) 非常相似, 注意区分
example(of: "switchLatest") {
    let one = PublishSubject<String>()
    let two = PublishSubject<String>()
    let three = PublishSubject<String>()
    
    let source = PublishSubject<Observable<String>>()
    
    let observable = source.switchLatest()
    let disposable = observable.subscribe(onNext: { print($0) })
    
    source.onNext(one)
    one.onNext("Some text from sequence one")
    two.onNext("Some text from sequence two")
    
    source.onNext(two)
    two.onNext("More text from sequence two")
    one.onNext("and also from sequence one")
    
    source.onNext(three)
    two.onNext("Why don't you see me?")
    one.onNext("I'm alone, help me")
    three.onNext("Hey it's three. I win.")
    
    source.onNext(one)
    one.onNext("Nope. It's me, one!")
    
    disposable.dispose()
}

//: reduce
// When the source observable completes, reduce(_:_:) emits
// the summary value, then completes.
// 当 source observable 完成时, reduce(_:_:) 发出最后的结果, 然后完成

// Note: reduce(_:_:) produces its summary (accumulated) value only
// when the source observable completes. Applying this operator to
// sequences that never complete won’t emit anything. This is a frequent
// source of confusion and hidden problems.
// 注意: reduce(_:_:) 只有当 Source observable 完成时发出最后结果, 然后完成
// 将其应用在一个永远不会完成的序列上, 不会发出任何值.
// 这是一个经常发生且不易发现的问题源头
example(of: "reduce") {
    let source = Observable.of(1, 3, 5, 7, 9)
    let observable = source.reduce(0, accumulator: +)
    observable.subscribe(onNext: { print($0) })
}

//: scan
// A close relative to reduce(_:_:) is the scan(_:accumulator:) operator.
// scan(_:accumulator:) 与 reduce(_:_:) 非常相似
// You get one output value per input value.
// 每一个输入值都会产生一个输出值
example(of: "scan") {
    let source = Observable.of(1, 3, 5, 7, 9)
    let observable = source.scan(0, accumulator: +)
    observable.subscribe(onNext: { print($0) })
}

example(of: "Challenge 1: solution using zip") {
    let source = Observable.of(1, 3, 5, 7, 9)
    let observable = source.scan(0, accumulator: +)
    Observable.zip(source, observable)
        .subscribe(onNext: { print($0) })
}

example(of: "Challenge 1: solution using just scan and a tuple") {
    let source = Observable.of(1, 3, 5, 7, 9)
    let observable = source.scan((0, 0)) { ($1, $0.1 + $1) }
    observable.subscribe(onNext: { print($0) })
}
