import SbuKit
import SwiftUI

/// Where moonrise and moonset are worked out: the iPhone's position, read once, or a city from
/// the list in the app, found without network.
struct PlaceSheet: View {
    let places: PlaceModel

    @State private var query = ""
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    private var cities: [City] {
        CityCatalog.cities(matching: query)
    }

    var body: some View {
        NavigationStack {
            List {
                if query.isEmpty {
                    CurrentLocationSection(
                        state: places.locationState,
                        isSelected: places.place?.isCurrentLocation == true,
                        useCurrentLocation: useCurrentLocation,
                        openSettings: openSettings
                    )
                }

                // No header over an empty list: the search's own message says nothing matched.
                if cities.isEmpty == false {
                    Section("Città") {
                        ForEach(cities) { city in
                            CityRow(city: city, isSelected: places.city == city) {
                                choose(city)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .overlay {
                if cities.isEmpty {
                    ContentUnavailableView.search(text: query)
                }
            }
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("Cerca una città"))
            .navigationTitle("Luogo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fine") { dismiss() }
                }
            }
        }
    }

    private func choose(_ city: City) {
        places.choose(city)
        dismiss()
    }

    private func useCurrentLocation() {
        Task {
            if await places.useCurrentLocation() {
                dismiss()
            }
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            openURL(url)
        }
    }
}

#Preview("Light") {
    PlaceSheet(places: PlaceModel(defaults: UserDefaults(suiteName: "preview") ?? .standard))
        .tint(SbuTheme.accentMoon)
}

#Preview("Dark") {
    PlaceSheet(places: PlaceModel(defaults: UserDefaults(suiteName: "preview") ?? .standard))
        .tint(SbuTheme.accentMoon)
        .preferredColorScheme(.dark)
}
