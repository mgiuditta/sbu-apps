import SbuKit
import SwiftUI

/// The tool screen: today's minutes in Sbu Social, the Platforms one square each (a tap opens it in
/// the filtered browser), and the Limite di tempo.
struct HomeView: View {
    @Environment(UsageLog.self) private var usage
    @Environment(OptionStore.self) private var options
    @State private var opened: Platform?
    /// The launch Platform opens once per launch, not every time Home comes back.
    @State private var hasLaunched = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SbuTheme.space6) {
                SbuScreenTitle("Home", cartiglio: Cartiglio.today)
                SbuFigure(value: usage.minutesToday.formatted(), fullStop: fullStop, context: context)
                PlatformGrid(open: { opened = $0 })
                LimitPicker(usage: usage)
            }
            .padding(SbuTheme.space4)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .sbuPaper(grid: true)
        .navigationDestination(item: $opened) { platform in
            PlatformScreen(platform: platform)
        }
        .onAppear {
            guard !hasLaunched else { return }
            hasLaunched = true
            opened = options.launchPlatform
        }
    }

    /// Set while you are within the Limite di tempo; waiting with no limit or past it.
    private var fullStop: SbuFullStop.State {
        usage.limitMinutes > 0 && !usage.isOverLimit ? .set : .waiting
    }

    private var context: Text {
        if usage.isOverLimit { return Text("Limite raggiunto. I social si riaprono domani.") }
        if usage.limitMinutes > 0 { return Text("minuti oggi, su \(usage.limitMinutes)") }
        return Text("minuti oggi")
    }
}

#Preview("Light") {
    NavigationStack {
        HomeView()
    }
    .environment(UsageLog(defaults: UserDefaults(suiteName: "preview")!))
    .environment(OptionStore(defaults: UserDefaults(suiteName: "preview")!))
}

#Preview("Dark") {
    NavigationStack {
        HomeView()
    }
    .environment(UsageLog(defaults: UserDefaults(suiteName: "preview")!))
    .environment(OptionStore(defaults: UserDefaults(suiteName: "preview")!))
    .preferredColorScheme(.dark)
}
