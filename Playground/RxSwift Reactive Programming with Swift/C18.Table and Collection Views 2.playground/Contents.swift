//: Playground - noun: a place where people can play

import UIKit
import RxSwift
import RxCocoa
import Action

class ButtonCell: UITableViewCell {
    
    var button: UIButton = UIButton()
    
}

//: Table and Collection Views

// 1
let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 400, height: 640),
                            style: .plain)

let cities = Variable(["Lisbon", "Copenhagen", "London", "Madrid", "Vienna"])

let bag = DisposeBag()

cities
    .asDriver()
    .drive(tableView.rx.items) { (tableView, index, element) in
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell") as! ButtonCell
        cell.selectionStyle = .none
        cell.textLabel?.text = element
        // 使用 Action
        cell.button.rx.action = CocoaAction {
            // do something specific to this cell here
            return .empty()
        }
        return cell
    }
    .disposed(by: bag)

tableView
    .rx.modelSelected(String.self)
    .subscribe(onNext: {
        print("\($0) was selected")
    })
    .disposed(by: bag)

tableView
    .rx.itemSelected
    .asObservable()
    .subscribe(onNext: {
        print("\($0) was selected")
    })
    .disposed(by: bag)

DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
    cities.value = ["1", "2", "3"]
}

// 2
//enum MyModel {
//
//    case text(String)
//    case pairOfImages(UIImage)
//
//}
//let bag = DisposeBag()
//
//let observable = Observable<[MyModel]>.just([
//    .text("Paris"),
//    .pairOfImages(UIImage(contentsOfFile: Bundle.main.path(forResource: "1", ofType: "png")!)!),
//    .text("London"),
//    .pairOfImages(UIImage(contentsOfFile: Bundle.main.path(forResource: "2", ofType: "png")!)!),
//    ])
//
//let tableV = UITableView(frame: CGRect(x: 0, y: 0, width: 400, height: 640),
//                            style: .plain)
//
//observable
//    .bind(to: tableV.rx.items) { (tableView, index, element) in
//        let indexPath = IndexPath(item: index, section: 0)
//        switch element {
//        case .text(let title):
//            let cell = tableView.dequeueReusableCell(withIdentifier: "text", for: indexPath)
//            cell.textLabel?.text = title
//            return cell
//        case .pairOfImages(let image):
//            let cell = tableView.dequeueReusableCell(withIdentifier: "image", for: indexPath)
//            cell.imageView?.image = image
//            return cell
//        }
//    }
//    .disposed(by: bag)

let hostView = setupHostView()
hostView.addSubview(tableView)
hostView
