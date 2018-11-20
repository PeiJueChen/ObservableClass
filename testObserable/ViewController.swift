//
//  ViewController.swift
//  testObserable
//
//  Created by 陈培爵 on 2018/11/18.
//  Copyright © 2018年 PeiJueChen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    fileprivate var observers: [AnyObserver] = []
    private var __age = 1

    // 移除observers
    deinit {
        for ob in observers {
            ob.remove()
        }
    }
    @IBAction func changeLang(_ sender: Any) {
        __age += 1

        let appSettings = AppSettings.shared
        if appSettings.language == .Chinese {
            appSettings.language = .English
        } else {
            appSettings.language = .Chinese
        }

        appSettings.stuObservable.value = Stu(name: "peter", age: 67 + __age)

        appSettings.stusObservable.value = [Stu(name: "Amy" + "\(__age)", age: 167 + __age)]

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let appSettings = AppSettings.shared
        let appSettingObserver = appSettings.observableLanguage.onSet { (oldValue, newValue) in
            print("oldValue:\(oldValue)  newValue:\(newValue)")
            print("-----------------------------------start -----")
        }

        let stuObserver = appSettings.stuObservable.onSet ([.FireImmediately]) { (oldStu, newStu) in
            print("oldStu:\(oldStu)  newStu:\(newStu)")

            if (oldStu == newStu) {
                print("-------  oldStu =  newStu  -----------")
            }
            print("----------------------------------------")
        }

        let stusObserver = appSettings.stusObservable.onSet ([.FireSynchronously]) { (oldStus, newStus) in
            print("oldStus:\(oldStus)  newStus:\(newStus)")
            print("---------------------------------------->>>>>>>>end >>>")
        }

        observers.append(appSettingObserver)
        observers.append(stuObserver)
        observers.append(stusObserver)



    }



}

