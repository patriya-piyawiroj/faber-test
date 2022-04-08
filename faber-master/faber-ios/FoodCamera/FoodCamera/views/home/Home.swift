/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view showing featured landmarks above a list of all of the landmarks.
*/

import SwiftUI
import Alamofire

struct Home: View {
    @EnvironmentObject var homeVM: AnyViewModel<HomeState, HomeInput>
    @State private var searchText : String = ""
    
    var body: some View {
        VStack {
            Text(homeVM.state.isFetching ? "fetching data" : "")
            HomeSearchBar(text: $searchText)
            NavigationView {
                List{
                    ForEach(homeVM.state.restaurantsByTypes.keys.sorted(), id: \.self) { key in
                        CuisineRow(cuisineType: key, restaurants: self.homeVM.state.restaurantsByTypes[key]!)
                    }
                    .listRowInsets(EdgeInsets())
                }
            }

        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
