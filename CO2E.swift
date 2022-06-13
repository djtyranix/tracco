import Foundation

struct CO2E
{
    var carbon: Double

    var massUnits: SystemUnits { didSet {
        let multiplier = oldValue.rawValue / massUnits.rawValue
        carbon *= multiplier
    }}

    var distanceUnits: SystemUnits { didSet {
        let multiplier = distanceUnits.rawValue / oldValue.rawValue
        carbon *= multiplier
    }}

    var baseObject: CO2EBase { get { return CO2EBase(self) } }

    init(_ base: CO2EBase)
    {
        carbon = base.carbon
        massUnits = .base
        distanceUnits = .base
    }
    
    static func * (left: CO2E, right: CO2E) -> CO2E
    {
        var temp = left
        temp.carbon *= matchSI(right, to: left).carbon
        return temp
    }
    
    static func / (left: CO2E, right: CO2E) -> CO2E
    {
        var temp = left
        temp.carbon /= matchSI(right, to: left).carbon
        return temp
    }
    
    static func + (left: CO2E, right: CO2E) -> CO2E
    {
        var temp = left
        temp.carbon += matchSI(right, to: left).carbon
        return temp
    }
    
    static func - (left: CO2E, right: CO2E) -> CO2E
    {
        var temp = left
        temp.carbon -= matchSI(right, to: left).carbon
        return temp
    }
    
    private static func matchSI(_ from: CO2E, to: CO2E) -> CO2E
    {
        var temp = from
        temp.massUnits      = to.massUnits
        temp.distanceUnits  = to.distanceUnits
        return temp
    }
}

// carbon emission based on base system units (gram / meter)
struct CO2EBase: Equatable, ExpressibleByFloatLiteral
{
    var carbon: Double

    var convertibleObject: CO2E { get { return CO2E(self) } }

    init(floatLiteral: Double)
    {
        self.carbon = floatLiteral
    }

    init(_ co2e: CO2E)
    {
        // convert every units to base first, closure on init will invoke didSet
        var temp            = co2e
        temp.massUnits      = .base
        temp.distanceUnits  = .base
        // assign it to the wrapped value
        self.carbon         = temp.carbon
    }
    
    static func * (left: CO2EBase, right: CO2EBase) -> CO2EBase
    {
        return CO2EBase(floatLiteral: left.carbon * right.carbon)
    }
    
    static func / (left: CO2EBase, right: CO2EBase) -> CO2EBase
    {
        return CO2EBase(floatLiteral: left.carbon / right.carbon)
    }
    
    static func + (left: CO2EBase, right: CO2EBase) -> CO2EBase
    {
        return CO2EBase(floatLiteral: left.carbon + right.carbon)
    }
    
    static func - (left: CO2EBase, right: CO2EBase) -> CO2EBase
    {
        return CO2EBase(floatLiteral: left.carbon - right.carbon)
    }
}
