import Foundation
import Regex

fileprivate let types = Condition.CeilingType.allCases
    .map { NSRegularExpression.escapedPattern(for: $0.rawValue) }
    .joined(separator: "|")
fileprivate let conditionsRxStr = "^(FEW|SCT|BKN|OVC|VV|///)(\\d+|///)(\(types))?$"
fileprivate let conditionsRx = try! Regex(string: conditionsRxStr)

func parseConditions(_ parts: inout Array<String.SubSequence>) throws -> Array<Condition> {
    var conditions = Array<Condition>()
    while let rawCondition = parts.first.map(String.init) {

        switch rawCondition {
        case "SKC":
            parts.removeFirst()
            return [.skyClear]
        case "CLR", "NCD":
            parts.removeFirst()
            return [.clear]
        case "NSC":
            parts.removeFirst()
            return [.noSignificantClouds]
        case "CAVOK":
            parts.removeFirst()
            return [.cavok]
        default:
            break
        }
        
        guard let match = conditionsRx.firstMatch(in: rawCondition) else { return conditions }
        parts.removeFirst()
            
        guard
            let raw = match.captures[0],
            let coverage = Condition.CoverageType(rawValue: raw)
        else { throw Error.invalidConditions(rawCondition) }
        
        let height = match.captures[1]
            .flatMap(UInt.init)
            .map(flightLeveltoFeet)
        
        let type: Condition.CeilingType? = try match.captures[2]
            .flatMap { rawCeiling in try .init(
                rawCondition: rawCondition,
                rawCeiling: rawCeiling,
                coverage: coverage)
            }

        switch (coverage, height) {
        case let (.few, .some(height)): conditions.append(.few(height, type: type))
        case let (.scattered, .some(height)): conditions.append(.scattered(height, type: type))
        case let (.broken, .some(height)): conditions.append(.broken(height, type: type))
        case let (.overcast, .some(height)): conditions.append(.overcast(height, type: type))
        case let (.verticalVisibility, .some(height)): conditions.append(.indefinite(height))
        case let (.undefined, height): conditions.append(.indefinite(height, type: type))
        default: throw Error.invalidConditions(rawCondition)
        }
    }
    
    return conditions
}

private func flightLeveltoFeet(_ fl: UInt) -> UInt {
    fl * 100
}

extension Condition.CoverageType {
    static var allowingCeilingTypeCases: [Self] {
        [
            .few,
            .scattered,
            .broken,
            .overcast,
            .undefined
        ]
    }
}

extension Condition.CeilingType {
    init?(rawCondition: String, rawCeiling: String, coverage: Condition.CoverageType) throws {
        guard Condition.CoverageType.allowingCeilingTypeCases.contains(coverage)
        else { throw Error.invalidConditions(rawCondition) }
        self.init(rawValue: rawCeiling)
    }
}
