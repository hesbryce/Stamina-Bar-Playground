import SwiftUI
import HealthKit

struct ContentView: View {
    let healthStore = HKHealthStore()
    @State private var activeEnergy: Double = 0.0
    @State private var restingEnergy: Double = 0.0
    
    var totalEnergy: Double {
        return activeEnergy + restingEnergy
    }
    
    var body: some View {
        VStack {
            Text("Active Energy")
                .font(.headline)
            Text("\(activeEnergy, specifier: "%.0f") kcal")
                .font(.largeTitle)
            
            Text("Resting Energy")
                .font(.headline)
            Text("\(restingEnergy, specifier: "%.0f") kcal")
                .font(.largeTitle)
            
            Text("Total Energy")
                .font(.headline)
            Text("\(totalEnergy, specifier: "%.0f") kcal")
                .font(.largeTitle)
        }
        .onAppear {
            authorizeHealthKit()
            startActiveEnergyQuery()
            startRestingEnergyQuery()
        }
    }
    
    private func authorizeHealthKit() {
        let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        let restingEnergyType = HKObjectType.quantityType(forIdentifier: .basalEnergyBurned)!
        healthStore.requestAuthorization(toShare: nil, read: Set([activeEnergyType, restingEnergyType])) { (success, error) in
            if success {
                print("Successfully authorized to read active and resting energy data")
            } else {
                print("Failed to authorize to read active and resting energy data: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    private func startActiveEnergyQuery() {
        let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictEndDate)
        let query = HKStatisticsQuery(quantityType: activeEnergyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Failed to retrieve active energy data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            self.activeEnergy = sum.doubleValue(for: HKUnit.kilocalorie())
        }
        healthStore.execute(query)
    }
    
    private func startRestingEnergyQuery() {
        let restingEnergyType = HKObjectType.quantityType(forIdentifier: .basalEnergyBurned)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictEndDate)
        let query = HKStatisticsQuery(quantityType: restingEnergyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Failed to retrieve resting energy data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            self.restingEnergy = sum.doubleValue(for: HKUnit.kilocalorie())
        }
        healthStore.execute(query)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
