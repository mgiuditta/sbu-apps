import SbuKit
import SwiftUI

/// The cards of the tool screen under the figure: the credits, the ways into the libretto, then
/// how the average went and the secondary figures.
struct DashboardOverview: View {
    let settings: CourseSettings
    let transcript: Transcript
    let countdown: ExamCountdown
    /// The exam names by id, for the chart's callout.
    let names: [ExamRecord.ID: String]

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space6) {
            CreditsSection(transcript: transcript, settings: settings)
            SbuListCard(DashboardDestination.allCases) { destination in
                NavigationLink {
                    view(for: destination)
                } label: {
                    OverviewLink(title: destination.title, systemImage: destination.systemImage,
                                 detail: destination == .upcoming ? countdown.next?.day.text : nil)
                }
                .buttonStyle(.plain)
                // The link is the whole row: the card's own padding goes inside its 44 pt target.
                .padding(.vertical, -SbuTheme.space3)
                .accessibilityIdentifier(destination.id)
            }
            StatisticsSection(transcript: transcript, names: names)
        }
    }

    @ViewBuilder
    private func view(for destination: DashboardDestination) -> some View {
        switch destination {
        case .simulate: SimulatorView(settings: settings)
        case .studyPlan: StudyPlanView(settings: settings)
        case .upcoming: UpcomingExamsView()
        case .timetable: TimetableView()
        }
    }
}

#Preview("Light") {
    DashboardOverviewPreview()
        .modelContainer(.preview)
}

#Preview("Dark") {
    DashboardOverviewPreview()
        .modelContainer(.preview)
        .preferredColorScheme(.dark)
}

private struct DashboardOverviewPreview: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                DashboardOverview(
                    settings: LaunchMode.sample.courseSettings(),
                    transcript: Transcript([
                        ExamRecord(credits: 12, result: .graded(.mark(24)), date: .now.addingTimeInterval(-86_400 * 30)),
                        ExamRecord(credits: 6, result: .graded(.mark(30)), date: .now),
                    ], rules: .standard),
                    countdown: ExamCountdown([], now: .now, calendar: .current),
                    names: [:]
                )
                .padding(SbuTheme.space4)
            }
            .background(SbuTheme.paper)
        }
        .tint(SbuTheme.ink)
    }
}
