import Foundation
import HealthKit

class HealthController {
    let healthStore = HKHealthStore()
    
    init() {
        if !HKHealthStore.isHealthDataAvailable() {
            print("HealthKit is not available on this device.")
        }
    }
    
    func requestHealthKitAuthorization(completion: @escaping (Bool) -> Void) {
        guard let stepsCount = HKObjectType.quantityType(forIdentifier: .stepCount),
              let caloriesBurned = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion(false)
            return
        }
        
        healthStore.requestAuthorization(toShare: [], read: [stepsCount, caloriesBurned]) { success, error in
            if let error = error {
                print("Error requesting HealthKit authorization: \(error.localizedDescription)")
            }
            completion(success)
        }
    }

    func fetchDailyStepsData(startDate: Date, endDate: Date, completion: @escaping ([Date: Double]) -> Void) {
        fetchDailyData(for: .stepCount, unit: HKUnit.count(), startDate: startDate, endDate: endDate, completion: completion)
    }

    func fetchDailyCaloriesData(startDate: Date, endDate: Date, completion: @escaping ([Date: Double]) -> Void) {
        fetchDailyData(for: .activeEnergyBurned, unit: HKUnit.kilocalorie(), startDate: startDate, endDate: endDate, completion: completion)
    }

    private func fetchDailyData(for identifier: HKQuantityTypeIdentifier, unit: HKUnit, startDate: Date, endDate: Date, completion: @escaping ([Date: Double]) -> Void) {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: identifier) else {
            completion([:])
            return
        }

        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        
        let anchorDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: startDate)!
        
        let daily = DateComponents(day: 1)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKStatisticsCollectionQuery(quantityType: quantityType,
                                                quantitySamplePredicate: predicate,
                                                options: [.cumulativeSum],
                                                anchorDate: anchorDate,
                                                intervalComponents: daily)
        
        query.initialResultsHandler = { query, results, error in
            guard let statsCollection = results else {
                completion([:])
                return
            }
            
            var data: [Date: Double] = [:]
            
            statsCollection.enumerateStatistics(from: startDate, to: endDate) { statistics, stop in
                let date = statistics.startDate
                let total = statistics.sumQuantity()?.doubleValue(for: unit) ?? 0
                data[date] = total
            }
            
            DispatchQueue.main.async {
                completion(data)
            }
        }
        
        healthStore.execute(query)
    }

    // Mock data generation
    // Inside HealthController.swift

    func generateMockStepsData(startDate: Date, days: Int) -> [Date: Double] {
        var mockData: [Date: Double] = [:]
        for day in 0..<days {
            guard let date = Calendar.current.date(byAdding: .day, value: day, to: startDate) else { continue }
            mockData[date] = Double.random(in: 1000...12000) // Random steps between 5000 and 15000
        }
        return mockData
    }

    func generateMockCaloriesData(startDate: Date, days: Int) -> [Date: Double] {
        var mockData: [Date: Double] = [:]
        for day in 0..<days {
            guard let date = Calendar.current.date(byAdding: .day, value: day, to: startDate) else { continue }
            mockData[date] = Double.random(in: 1200...3600) // Random calories between 200 and 600
        }
        return mockData
    }

}

