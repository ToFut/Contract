import SwiftUI

struct ResultsView: View {
    var results: AnalysisResults?

    var body: some View {
        NavigationStack {
            VStack {
                if let results = results {
                    ScrollView {
                        // Key Metrics Section
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Key Metrics")
                                .font(.title2)
                                .bold()
                                .padding(.horizontal)
                            
                            HStack {
                                ForEach(results.keyMetrics, id: \.key) { metric in
                                    MetricCard(key: metric.key, value: metric.value)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Business Overview Section
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Business Overview")
                                .font(.title2)
                                .bold()
                                .padding(.horizontal)
                            
                            ForEach(results.businessOverview, id: \.key) { overview in
                                OverviewCard(key: overview.key, value: overview.value)
                            }
                        }
                        .padding(.bottom)

                        // Forecast and Analysis Section
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Forecast and Analysis")
                                .font(.title2)
                                .bold()
                                .padding(.horizontal)

                            // Example placeholder for chart data
                            // Replace with actual data visualizations
                            Text("Forecast data here")
                                .font(.subheadline)
                                .padding(.bottom)
                        }
                        .padding(.bottom)

                        // Must-Do Tasks Section
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Must-Do Tasks")
                                .font(.title2)
                                .bold()
                                .padding(.horizontal)

                            ForEach(results.mustDoTasks.flatMap { $0.value }, id: \.self) { task in
                                Text("• \(task)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.bottom)

                        // Partner Relationships Section
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Partner Relationships")
                                .font(.title2)
                                .bold()
                                .padding(.horizontal)

                            ForEach(results.partnerRelationships, id: \.partner) { relationship in
                                RelationshipCard(partner: relationship.partner, details: relationship.details)
                            }
                        }
                        .padding(.bottom)

                        // Opportunities Section
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Opportunities")
                                .font(.title2)
                                .bold()
                                .padding(.horizontal)

                            ForEach(results.opportunities, id: \.opportunity) { opportunity in
                                OpportunityCard(opportunity: opportunity.opportunity, details: opportunity.details)
                            }
                        }
                        .padding(.bottom)

                        // Suggestions Section
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Suggestions")
                                .font(.title2)
                                .bold()
                                .padding(.horizontal)

                            ForEach(results.suggestions, id: \.self) { suggestion in
                                Text("• \(suggestion)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal)
                    }
                } else {
                    Text("No results available.")
                        .font(.title2)
                        .padding()
                }
            }
            .navigationTitle("Analysis Dashboard")
        }
    }
}

struct MetricCard: View {
    var key: String
    var value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(key)
                .font(.headline)
                .foregroundColor(.blue)
            Text(value)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct OverviewCard: View {
    var key: String
    var value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(key)
                .font(.headline)
                .foregroundColor(.blue)
            Text(value)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct RelationshipCard: View {
    var partner: String
    var details: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(partner)
                .font(.headline)
                .foregroundColor(.blue)
            Text(details)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct OpportunityCard: View {
    var opportunity: String
    var details: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(opportunity)
                .font(.headline)
                .foregroundColor(.blue)
            Text(details)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}
