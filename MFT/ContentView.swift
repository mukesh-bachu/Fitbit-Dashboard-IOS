import SwiftUI

struct ContentView: View {
    @State private var isHealthKitAuthorized = false
    @State private var weeklyStepsData: [Date: Double] = [:]
    @State private var weeklyCaloriesData: [Date: Double] = [:]
    @State private var currentStartDate: Date = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
    
    private var healthController = HealthController()
    private let calendar = Calendar.current

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if isHealthKitAuthorized {
                        weekNavigationButtons
                        graphsView
                        logOutButton.padding(.top, 10)
                    } else {
                        authorizeButton.padding(.top, 20)
                    }
                }
                .padding()
                .navigationTitle("Miracle Fitness Tracker")
            }
        }
    }
    
    private var weekNavigationButtons: some View {
        HStack {
            Button(action: previousWeek) {
                Label("Previous Week", systemImage: "chevron.left")
            }
            
            Spacer()
            
            Button(action: nextWeek) {
                Label("Next Week", systemImage: "chevron.right")
            }
            .disabled(isNextWeekDisabled())
        }
        .padding()
    }
    
//    private var graphsView: some View {
//        Group {
//            if !weeklyStepsData.isEmpty {
//                BarGraphView(data: weeklyStepsData, title: "Weekly Steps")
//                    .padding(.horizontal) // Ensure there's padding around the graph
//            }
//            if !weeklyCaloriesData.isEmpty {
//                BarGraphView(data: weeklyCaloriesData, title: "Weekly Calories")
//                    .padding(.horizontal) // Ensure there's padding around the graph
//            }
//        }
//        .frame(height: 200) // Set a fixed height for the graph container
//    }
    
    private var graphsView: some View {
        Group {
              if !weeklyStepsData.isEmpty || !weeklyCaloriesData.isEmpty {
                  BarGraphView(stepsData: weeklyStepsData, caloriesData: weeklyCaloriesData, title: "Weekly Data")
                      .padding(.horizontal) // Ensure there's padding around the graph
              }
          }// Add padding around the graph
            .frame(height: 220) // Adjust height to fit the graph and Y-axis labels
                      .padding(.top)
    }
    private var logOutButton: some View {
        Button("Log Out") {
            logOut()
        }
        .foregroundColor(.red)
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.red, lineWidth: 2)
        )
    }
    
    private var authorizeButton: some View {
        Button("Authorize HealthKit") {
            authorizeHealthKit()
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.blue, lineWidth: 2)
        )
    }
    
    private func authorizeHealthKit() {
        healthController.requestHealthKitAuthorization { authorized in
            DispatchQueue.main.async {
                self.isHealthKitAuthorized = authorized
                if authorized {
                    self.fetchWeeklyData()
                }
            }
        }
    }
    
    private func fetchWeeklyData() {
        let endDate = calendar.date(byAdding: .day, value: 6, to: currentStartDate)!
        healthController.fetchDailyStepsData(startDate: currentStartDate, endDate: endDate) { stepsData in
            DispatchQueue.main.async {
                self.weeklyStepsData = !stepsData.isEmpty ? self.healthController.generateMockStepsData(startDate: self.currentStartDate, days: 7) : stepsData
            }
        }
        healthController.fetchDailyCaloriesData(startDate: currentStartDate, endDate: endDate) { caloriesData in
            DispatchQueue.main.async {
                self.weeklyCaloriesData = !caloriesData.isEmpty ? self.healthController.generateMockCaloriesData(startDate: self.currentStartDate, days: 7) : caloriesData
            }
        }
    }
    
    private func previousWeek() {
        currentStartDate = calendar.date(byAdding: .weekOfYear, value: -1, to: currentStartDate)!
        fetchWeeklyData()
    }
    
    private func nextWeek() {
        currentStartDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentStartDate)!
        fetchWeeklyData()
    }
    
    private func isNextWeekDisabled() -> Bool {
        return currentStartDate >= calendar.startOfDay(for: Date())
    }
    
    private func logOut() {
        isHealthKitAuthorized = false
        weeklyStepsData = [:]
        weeklyCaloriesData = [:]
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

