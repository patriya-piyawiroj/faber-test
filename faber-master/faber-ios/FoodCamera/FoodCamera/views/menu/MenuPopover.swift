//
//  MenuPopover.swift
//  FoodCamera
//
//  Created by Mac on 2020/4/14.
//  Copyright © 2020 Yinghui Linda He. All rights reserved.
//

import SwiftUI
import SDWebImage
import SDWebImageSwiftUI

struct MenuPopover: View {
    
    var menu: Array<MenuItem>

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .center) {
                ForEach(0..<self.menu.count/3) { index in
                    MenuPopoverRow(menuItem1: self.menu[index], menuItem2: self.menu[index+1], menuItem3: self.menu[index+2])
                }
                // rest menuItems
                MenuPopoverRow(
                    menuItem1: self.menu.count/3*3 < self.menu.count ? self.menu[self.menu.count/3*3] : MenuItem(name: "", photo: "", price: 0, description: "")!,
                    menuItem2: self.menu.count/3*3+1 < self.menu.count ? self.menu[self.menu.count/3*3+1] : MenuItem(name: "", photo: "", price: 0, description: "")!,
                    menuItem3: (self.menu.count/3*3+2 < self.menu.count ? self.menu[self.menu.count/3*3+2] : MenuItem(name: "", photo: "", price: 0, description: ""))!);
            }
        }
        .frame(width: 155, height: 300)
    }
    
}
