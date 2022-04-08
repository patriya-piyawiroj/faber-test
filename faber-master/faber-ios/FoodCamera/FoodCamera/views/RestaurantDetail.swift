/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view showing the details for a landmark.
*/

import SwiftUI
import SDWebImage
import SDWebImageSwiftUI

struct RestaurantDetail: View {
    var restaurant: Restaurant
    
    var body: some View {
        VStack {
            WebImage(url: URL(string: restaurant.cover))
                .edgesIgnoringSafeArea(.top)
                .frame(height: 300)
            
            WebImage(url: URL(string: restaurant.icon))
                .offset(x: 0, y: -130)
                .padding(.bottom, -130)
            
            VStack(alignment: .center) {
                HStack {
                    Text(restaurant.name)
                        .font(.title)
                }
                
                HStack(alignment: .top) {
                    Text(restaurant.cuisineType)
                        .font(.subheadline)
                }
            }
            .padding()
            
            Menu(menu: restaurant.menu);

            Spacer()
        }
    }
}
