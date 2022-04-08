//
//  MenuPopoverRow.swift
//  FoodCamera
//
//  Created by Mac on 2020/4/15.
//  Copyright © 2020 Yinghui Linda He. All rights reserved.
//

import SwiftUI
import SDWebImage
import SDWebImageSwiftUI

struct MenuPopoverRow: View {
    
    var menuItem1: MenuItem
    var menuItem2: MenuItem
    var menuItem3: MenuItem

    var body: some View {
        HStack {
            MenuRow(menuItem: menuItem1);
            MenuRow(menuItem: menuItem2);
            MenuRow(menuItem: menuItem3);
        }
      }
}

