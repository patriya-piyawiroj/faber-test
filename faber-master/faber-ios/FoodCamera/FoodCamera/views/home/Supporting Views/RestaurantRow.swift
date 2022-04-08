/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A single row to be displayed in a list of landmarks.
*/

import SwiftUI
import SDWebImage
import SDWebImageSwiftUI

struct RestaurantRow: View {
    var restaurant: Restaurant

    var body: some View {
        HStack {
            VStack {
                WebImage(url: URL(string: restaurant.cover))
                    .resizable()
                    .frame(width: 50, height: 50)
                    .gesture(
                        LongPressGesture(minimumDuration: 2)
                        .onEnded { _ in
                            
                        }
                    )
                    
                
                Text(restaurant.name)
                
                Spacer()
            }
            
        }
    }
}
