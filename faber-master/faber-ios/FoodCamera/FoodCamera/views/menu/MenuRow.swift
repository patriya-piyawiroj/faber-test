//
//  MenuItemRow.swift
//  FoodCamera
//
//  Created by Mac on 2020/4/12.
//  Copyright © 2020 Yinghui Linda He. All rights reserved.
//

import SwiftUI
import SDWebImage
import SDWebImageSwiftUI

struct MenuRow: View {
    var menuItem: MenuItem
    
    var body: some View {
        VStack(alignment: .center) {
            if(menuItem.photo != "") {
                WebImage(url: URL(string: menuItem.photo))
                .resizable()
                .frame(width: 100, height: 100)
            }
            Text(menuItem.name)
            if (menuItem.price != 0) {
                Text("Price: $" + String(menuItem.price))
            }
            if (menuItem.description != "") {
                Text("Description: " + menuItem.description)
            }
            Spacer()
        }
        .padding()
    }
}
