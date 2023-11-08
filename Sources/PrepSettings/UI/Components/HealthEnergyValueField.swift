import SwiftUI
import PrepShared

struct HealthEnergyValueField<S: GenericSource>: View {
    
    @Binding var value: Double?
    @Binding var energyUnit: EnergyUnit
    @Binding var interval: HealthInterval?
    var date: Date
    let source: S
    
    var body: some View {
        HStack {
            Spacer()
            switch source.isManual {
            case true:
                manualValue
            case false:
                calculatedValue
            }
        }
    }
    
    var calculatedValue: some View {
        CalculatedEnergyView(
            valueBinding: $value,
            unitBinding: $energyUnit,
            intervalBinding: $interval,
            date: date,
            source: source
        )
    }
    
    var manualValue: some View {
        let binding = Binding<Double>(
            get: { value ?? 0 },
            set: { value = $0 }
        )

        return HStack {
            Spacer()
            NumberTextField(placeholder: "Required", roundUp: true, binding: binding)
            MenuPicker<EnergyUnit>($energyUnit)
        }
    }
}
