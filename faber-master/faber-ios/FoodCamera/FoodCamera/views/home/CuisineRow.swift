/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view showing a scrollable list of landmarks.
*/

import SwiftUI
import SDWebImage
import SDWebImageSwiftUI

struct CuisineRow: View {
    var cuisineType: String
    var restaurants: [Restaurant]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(self.cuisineType)
                .font(.headline)
                .padding(.leading, 15)
                .padding(.top, 5)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 0) {
                    ForEach(self.restaurants) { r in
                        NavigationLink(
                            destination: RestaurantDetail(
                                restaurant: r
                            )
                        ) {
                            CuisineItem(restaurant: r)
                        }
                    }
                }
            }
            .frame(height: 185)
        }
    }
}

struct CuisineItem: View {
    var restaurant: Restaurant
    @State private var showingMenuPopup: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            WebImage(url: URL(string: restaurant.icon))
                .renderingMode(.original)
                .resizable()
                .frame(width: 155, height: 155)
                .cornerRadius(5)
            
            Button(
                action: { self.showingMenuPopup.toggle(); },
                label: { Text(restaurant.name)
                    .foregroundColor(.primary)
                    .font(.caption) })
                .popover(isPresented: self.$showingMenuPopup) {
                    VStack {
                        MenuPopover(menu: self.restaurant.menu);
                        Button(action: {
                            self.showingMenuPopup.toggle();
                        }) {
                            Text("Hide popup menu")
                        }
                    }
                }
        }
        .padding(.leading, 15)
    }
}
