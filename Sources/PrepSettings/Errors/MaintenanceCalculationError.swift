import Foundation

public enum MaintenanceCalculationError: Int, Error, Codable {
    case noWeightData = 1
    case noNutritionData
    case noWeightOrNutritionData
    
    var message: String {
        switch self {
        case .noWeightData:
//            "You do not have enough weight data over the prior week to make a calculation."
            "You do not have enough weight data to make a calculation."
        case .noNutritionData:
            "You do not have any nutrition data to make a calculation."
        case .noWeightOrNutritionData:
            "You do not have enough weight and nutrition data to make an adaptive calculation."
        }
    }
    
    var title: String {
        switch self {
        case .noWeightData:
            "Insufficient Weight Data"
        case .noNutritionData:
            "Insufficient Nutrition Data"
        case .noWeightOrNutritionData:
            "Insufficient Data"
        }
    }
}
