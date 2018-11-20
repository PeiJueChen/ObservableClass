//
//  Stu.swift
//  testObserable
//
//  Created by 陈培爵 on 2018/11/19.
//  Copyright © 2018年 PeiJueChen. All rights reserved.
//

import UIKit

struct Stu {
    var name: String
    var age: Int
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
}

// 也可以自定義 == 來判斷是相等的stu
func == (lhs: Stu, rhs: Stu) -> Bool {
    return lhs.name == rhs.name
}
func ~= (lhs: Stu, rhs: Stu) -> Bool {
    return lhs.name == rhs.name
}
extension Stu: Equatable { }

