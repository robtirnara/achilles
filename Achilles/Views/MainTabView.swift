import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("HQ", systemImage: "house.fill")
                }
                .tag(0)

            FuelView()
                .tabItem {
                    Label("Fuel", systemImage: "flame.fill")
                }
                .tag(1)

            OpsView()
                .tabItem {
                    Label("Ops", systemImage: "figure.strengthtraining.traditional")
                }
                .tag(2)

            IntelView()
                .tabItem {
                    Label("Intel", systemImage: "person.fill")
                }
                .tag(3)
        }
        .tint(Theme.amber)
        .preferredColorScheme(.dark)
    }
}
