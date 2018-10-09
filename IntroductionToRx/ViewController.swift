//
//  ViewController.swift
//  IntroductionToRx
//
//  Created by Diego Perini on 9.10.2018.
//  Copyright © 2018 Diego Perini. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        arrayExample()
        observableExample()
    }

    func arrayExample() {
        let myArray = [1, 2, 3]
        let transformation = myArray.map { e -> Int in
            print("Map: ", e)
            return e * 2
        }
        let filtered = transformation.filter { e -> Bool in
            print("Filter: ", e)
            return e > 2
        }
        
        filtered.forEach { e in
            print("Result: ", e)
        }
        print("Done!")
    }
    
    func observableExample() {
        let myObservable = Observable.of(1, 2, 3) // or Observable.from([1, 2, 3])
        let transformation = myObservable.map { e -> Int in
            print("Map: ", e)
            return e * 2
        }
        let filtered = transformation.filter { e -> Bool in
            print("Filter: ", e)
            return e > 2
        }
        
        _ = filtered.subscribe(
            onNext: { e in
                print("Result: ", e)
            },
            onError: { err in
                print(err)
            },
            onCompleted: {
                print("Done!")
            },
            onDisposed: {
                print("Garbage collected!")
            }
        )
    }
}

