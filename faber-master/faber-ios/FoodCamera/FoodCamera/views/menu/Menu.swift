//
//  Menu.swift
//  FoodCamera
//
//  Created by Mac on 2020/4/14.
//  Copyright © 2020 Yinghui Linda He. All rights reserved.
//

import SwiftUI

struct Menu: View {
    
    var menu: Array<MenuItem>

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .center) {
                ForEach(menu) { menuItem in
                    MenuRow(menuItem: menuItem)
                }
            }
        }
        .padding()
    }
    
}
