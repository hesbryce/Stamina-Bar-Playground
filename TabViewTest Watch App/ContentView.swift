import SwiftUI
import HealthKit

struct ContentView: View {
    let healthStore = HKHealthStore()
    @State private var activeEnergy: Double = 0.0
    
    var body: some View {
        VStack {
            Text("Active Energy")
                .font(.headline)
            Text("\(activeEnergy, specifier: "%.0f") kcal")
                .font(.largeTitle)
            Button {
            authorizeHealthKit()
            startActiveEnergyQuery()
                
        } label: {
            Image(systemName: "arrow.clockwise")
        }
            .cornerRadius(5)
            .tint(.mint)
        }
        .onAppear {
            authorizeHealthKit()
            startActiveEnergyQuery()
        }
    }
    
    private func authorizeHealthKit() {
        let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        healthStore.requestAuthorization(toShare: nil, read: Set([activeEnergyType])) { (success, error) in
            if success {
                print("Successfully authorized to read active energy data")
            } else {
                print("Failed to authorize to read active energy data: \(error?.localizedDescription ?? "Unknown error")")
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

