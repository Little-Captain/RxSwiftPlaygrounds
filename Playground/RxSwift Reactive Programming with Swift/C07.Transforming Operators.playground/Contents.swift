//: Playground - noun: a place where people can play

import RxSwift

//: Transforming Operators

example(of: "toArray") {
    let disposeBag = DisposeBag()
    // 1
    Observable.of("A", "B", "C")
        // 2
        .toArray()
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}

example(of: "map") {
    let disposeBag = DisposeBag()
    // 1
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    // 2
    Observable<NSNumber>.of(123, 4, 56)
        // 3
        .map { formatter.string(from: $0) ?? "" }
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}

example(of: "enumerated and map") {
    let bag = DisposeBag()
    Observable.of(1, 2, 3, 4, 5, 6)
        .enumerated()
        .map { $0 > 2 ? $1 * 2 : $1 }
        .subscribe(onNext: { print($0) })
        .disposed(by: bag)
}

struct Student {
    
    var score: BehaviorSubject<Int>
    
}

example(of: "flatMap") {
    let bag = DisposeBag()
    let ryan = Student(score: BehaviorSubject(value: 80))
    let charlotte = Student(score: BehaviorSubject(value: 90))
    let student = PublishSubject<Student>()
    student
        .flatMap { $0.score }
        .subscribe(onNext: { print($0) })
        .disposed(by: bag)
    
    student.onNext(ryan)
    ryan.score.onNext(85)
    student.onNext(charlotte)
    ryan.score.onNext(100)
    charlotte.score.onNext(101)
}

example(of: "flatMapLatest") {
    let bag = DisposeBag()
    let ryan = Student(score: BehaviorSubject(value: 80))
    let charlotte = Student(score: BehaviorSubject(value: 90))
    let student = PublishSubject<Student>()
    student
        .flatMapLatest { $0.score }
        .subscribe(onNext: { print($0) })
        .disposed(by: bag)
    
    student.onNext(ryan)
    ryan.score.onNext(85)
    student.onNext(charlotte)
    ryan.score.onNext(100)
    charlotte.score.onNext(101)
}

example(of: "materialize and dematerialize") {
    enum MyError: Error {
        case anError
    }
    
    let bag = DisposeBag()
    let ryan = Student(score: BehaviorSubject(value: 80))
    let charlotte = Student(score: BehaviorSubject(value: 100))
    let student = BehaviorSubject(value: ryan)
    
    let studentScore = student
        // 封包成事件
        .flatMapLatest { $0.score.materialize() }
    studentScore
        // 过滤掉所有的错误事件
        .filter { $0.error == nil }
        // 解包成原始值
        .dematerialize()
        .subscribe(onNext: { print($0) }, onCompleted: { print("completed") })
        .disposed(by: bag)
    
    ryan.score.onNext(85)
    ryan.score.onError(MyError.anError)
    ryan.score.onNext(90)
    student.onNext(charlotte)
    charlotte.score.onNext(101)
    charlotte.score.onCompleted()
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
    
    let convert: (String) -> UInt? = { value in
        if let number = UInt(value), number < 10 { return number }
        return ["abc": 2, "def": 3, "ghi": 4,
                "jkl": 5, "mno": 6, "pqrs": 7,
                "tuv": 8, "wxyz": 9]
            .filter { $0.key.contains(value.lowercased()) }
            .map { $0.value }
            .first
    }
    
    let format: ([UInt]) -> String = {
        var phone = $0.map(String.init).joined()
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
    
    let dial: (String) -> String = {
        if let contact = contacts[$0] {
            return "Dialing \(contact) (\($0))..."
        } else {
            return "Contact not found"
        }
    }
    
    let input = Variable<String>("")
    
    // Add your code here
    input.asObservable()
        .map(convert)
        .filter { $0 != nil }
        .map { $0! }
        .skipWhile { $0 == 0 }
        .take(10)
        .toArray()
        .map(format)
        .map(dial)
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
    
    input.value = ""
    input.value = "0"
    input.value = "408"
    
    input.value = "6"
    input.value = ""
    input.value = "0"
    input.value = "3"
    
    "JKL1A1B".forEach {
        input.value = "\($0)"
    }
    
    input.value = "9"
}
