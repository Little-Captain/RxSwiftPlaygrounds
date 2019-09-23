//: Playground - noun: a place where people can play

import RxSwift

enum LCError: Error {
    case error
}

//: Filtering Operators

example(of: "ignoreElements") {
    // 1
    let strikes = PublishSubject<String>()
    let disposeBag = DisposeBag()
    // 2
    strikes
            .ignoreElements()
            .subscribe { _ in
                print("You're out!")
            }
            .disposed(by: disposeBag)
    strikes.onNext("X")
    strikes.onNext("X")
    strikes.onNext("X")
//    strikes.onCompleted()
    strikes.onError(LCError.error)
}

example(of: "elementAt") {
    // 1
    let strikes = PublishSubject<String>()
    let disposeBag = DisposeBag()
    // 2
    strikes
            .elementAt(2)
            .subscribe(onNext: {
                print("You're out! \($0)")
            })
            .disposed(by: disposeBag)
    strikes.onNext("X")
    strikes.onNext("X")
    strikes.onNext("X")
}

example(of: "filter") {
    let disposeBag = DisposeBag()
    // 1
    Observable.of(1, 2, 3, 4, 5, 6)
            // 2
            .filter {
                $0 % 2 == 0
            }
            // 3
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
}

example(of: "skip") {
    let disposeBag = DisposeBag()
    // 1
    Observable.of("A", "B", "C", "D", "E", "F")
            // 2
            .skip(3)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
}

example(of: "skipWhile") {
    let disposeBag = DisposeBag()
    // 1
    Observable.of(0, 2, 2, 3, 4, 4)
            // 2
            .skipWhile {
                $0 % 2 == 0
            }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
}

example(of: "skipUntil") {
    let disposeBag = DisposeBag()
    // 1
    let subject = PublishSubject<String>()
    let trigger = PublishSubject<String>()
    // 2
    subject
            .skipUntil(trigger)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    subject.onNext("A")
    subject.onNext("B")
    trigger.onNext("X")
    subject.onNext("C")
}

example(of: "take") {
    let disposeBag = DisposeBag()
    // 1
    Observable.of(1, 2, 3, 4, 5, 6)
            // 2
            .take(3)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
}

example(of: "takeWhile") {
    let disposeBag = DisposeBag()
    // 1
    Observable.of(2, 2, 4, 4, 6, 6)
            // 2
            .enumerated()
            // 3
            .takeWhile {
                $1 % 2 == 0 && $0 < 3
            }
            .map {
                $0.element
            }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
}

example(of: "takeUntil") {
    let disposeBag = DisposeBag()
    // 1
    let subject = PublishSubject<String>()
    let trigger = PublishSubject<String>()
    trigger
            .debug()
            .subscribe(onNext: { print($0) })
    // 2
    subject
            .takeUntil(trigger)
            .debug()
            .subscribe(onNext: { print($0) }, onDisposed: { print("disposed") })
//            .disposed(by: disposeBag)
    // 3
    subject.onNext("1")
    subject.onNext("2")
    // 发送了事件后，takeUntil 对应的订阅就会立即结束，然后被 dispose
    trigger.onNext("X")
    subject.onNext("3")
    subject.onNext("4")
    /*
    someObservable
        .takeUntil(self.rx.deallocated)
        .subscribe(onNext: { print($0) })
     */
}

example(of: "distinctUntilChanged") {
    let disposeBag = DisposeBag()
    // 1
    Observable.of("A", "A", "B", "B", "A")
            // 2
            .distinctUntilChanged()
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
}

example(of: "distinctUntilChanged(_:)") {
    let disposeBag = DisposeBag()
    // 1
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    // 2
    Observable<NSNumber>.of(10, 110, 20, 200, 210, 310)
            // 3
            // return true: 表示未改变 a == b b 不会取
            // return false: 表示改变 a != b b 会取
            .distinctUntilChanged { a, b in
                // 4
                guard let aWords = formatter.string(from: a)?.components(separatedBy: " "),
                      let bWords = formatter.string(from: b)?.components(separatedBy: " ") else {
                    return false
                }
                print(formatter.string(from: a)!)
                print(formatter.string(from: b)!)
                var containsMatch = false
                // 5
                for aWord in aWords {
                    for bWord in bWords {
                        if aWord == bWord {
                            containsMatch = true
                            break
                        }
                    }
                }
                return containsMatch
            }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
}

example(of: "Challenge 1") {

    let disposeBag = DisposeBag()

    let contacts = [
        "603-555-1212": "Florent",
        "212-555-1212": "Junior",
        "408-555-1212": "Marin",
        "617-555-1212": "Scott"
    ]

    func phoneNumber(from inputs: [Int]) -> String {
        var phone = inputs.map(String.init).joined()

        phone.insert("-", at: phone.index(
                phone.startIndex,
                offsetBy: 3)
        )

        phone.insert("-", at: phone.index(
                phone.startIndex,
                offsetBy: 7)
        )

        return phone
    }

    let input = PublishSubject<Int>()

    // Add your code here
    input.asObserver()
            .skipWhile {
                $0 == 0
            }
            .filter {
                $0 < 10
            }
            .take(10)
            .toArray()
            .subscribe(onSuccess: {
                let phone = phoneNumber(from: $0)
                if let contact = contacts[phone] {
                    print("Dialing \(contact) (\(phone))...")
                } else {
                    print("Contact not found")
                }
            })
            .disposed(by: disposeBag)

    input.onNext(0)
    input.onNext(603)

    input.onNext(2)
    input.onNext(1)

    // Confirm that 7 results in "Contact not found", and then change to 2 and confirm that Junior is found
//    input.onNext(7)
    input.onNext(2)

    "5551212".forEach {
        if let number = (Int("\($0)")) {
            input.onNext(number)
        }
    }

    input.onNext(9)
}
