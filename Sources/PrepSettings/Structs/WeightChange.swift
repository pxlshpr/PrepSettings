import Foundation
import PrepShared

//public struct WeightChange: Hashable, Codable {
//    
//    public var kg: Double?
//    public var type: WeightChangeType
//    public var points: Points? = nil
//    
//    public init(
//        kg: Double? = nil,
//        type: WeightChangeType = .weights,
//        points: Points? = nil
//    ) {
//        self.kg = kg
//        self.type = type
//        self.points = points
//    }
//    
//    public struct Points: Hashable, Codable {
//        public var start: WeightChangePoint
//        public var end: WeightChangePoint
//        
//        init(date: Date, interval: HealthInterval) {
//            self.end = .init(date: date)
//            self.start = .init(date: interval.startDate(with: date))
//        }
//        
//        var weightChangeInKg: Double? {
//            guard let endKg = end.kg, let startKg = start.kg else { return nil }
//            return endKg - startKg
//        }
//    }
//}
//
//extension WeightChange {
//    
//    var isEmpty: Bool {
//        kg == nil
//    }
//
//    var energyEquivalentInKcal: Double? {
//        guard let kg else { return nil }
////        454 g : 3500 kcal
////        delta : x kcal
//        return (3500 * kg) / BodyMassUnit.lb.convert(1, to: .kg)
//    }
//    
//    func energyEquivalent(in energyUnit: EnergyUnit) -> Double? {
//        guard let kcal = energyEquivalentInKcal else { return nil }
//        return EnergyUnit.kcal.convert(kcal, to: energyUnit)
//    }
//}
