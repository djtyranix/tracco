import Foundation

// system units and their multiplier based on "base"
enum SystemUnits: Double
{
    case peta   = 1e15
    case tera   = 1e12
    case giga   = 1e9
    case mega   = 1e6
    case kilo   = 1e3
    case hecto  = 1e2
    case deca   = 1e1
    case base   = 1
    case deci   = 1e-1
    case centi  = 1e-2
    case milli  = 1e-3
    case micro  = 1e-6
    case nano   = 1e-9
    case pico   = 1e-12
    case femto  = 1e-15
}

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
}
