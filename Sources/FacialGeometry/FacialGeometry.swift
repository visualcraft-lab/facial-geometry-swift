import Foundation

/// Pure-math 2D facial landmark geometry utilities for canthal tilt,
/// facial thirds balance, golden ratio delta, and bilateral mirror symmetry.
///
/// Coordinates follow top-down image space (`x` right, `y` down).
/// Reference formulas and interactive calculator: https://looksmaxscale.com/
public enum FacialGeometry {
    /// The golden ratio constant `(1 + sqrt(5)) / 2`.
    public static let phi: Double = 1.618033988749895

    /// Errors thrown when landmark geometry inputs are invalid.
    public enum GeometryError: Error, Equatable, Sendable {
        case degenerateHorizontalSpan
        case nonIncreasingVerticalLandmarks
        case nonPositiveDimensions
        case emptyLandmarkPairs
    }

    /// A 2D facial landmark point in top-down image coordinates.
    public struct Point2D: Equatable, Hashable, Sendable {
        public let x: Double
        public let y: Double

        public init(x: Double, y: Double) {
            self.x = x
            self.y = y
        }
    }

    /// A corresponding pair of left and right facial landmarks.
    public struct LandmarkPair: Equatable, Hashable, Sendable {
        public let left: Point2D
        public let right: Point2D

        public init(left: Point2D, right: Point2D) {
            self.left = left
            self.right = right
        }
    }

    /// Normalized vertical facial thirds and an overall balance score in `[0, 1]`.
    public struct FacialThirds: Equatable, Sendable {
        public let upper: Double
        public let middle: Double
        public let lower: Double
        public let balanceScore: Double

        public init(upper: Double, middle: Double, lower: Double, balanceScore: Double) {
            self.upper = upper
            self.middle = middle
            self.lower = lower
            self.balanceScore = balanceScore
        }
    }

    /// Golden ratio measurement result comparing `faceHeight / faceWidth` against `phi`.
    public struct GoldenRatioResult: Equatable, Sendable {
        public let ratio: Double
        public let delta: Double

        public init(ratio: Double, delta: Double) {
            self.ratio = ratio
            self.delta = delta
        }
    }

    /// Computes the medial-to-lateral canthal tilt angle in degrees.
    ///
    /// Positive degrees indicate an upward lateral tilt in top-down image coordinates.
    public static func canthalTiltDegrees(medial: Point2D, lateral: Point2D) throws -> Double {
        let dx = abs(lateral.x - medial.x)
        guard dx > 1e-12 else {
            throw GeometryError.degenerateHorizontalSpan
        }
        let dyUp = medial.y - lateral.y
        return atan2(dyUp, dx) * (180.0 / Double.pi)
    }

    /// Computes normalized vertical facial thirds from strictly increasing top-down Y coordinates.
    public static func computeFacialThirds(
        trichionY: Double,
        glabellaY: Double,
        subnasaleY: Double,
        mentonY: Double
    ) throws -> FacialThirds {
        guard trichionY < glabellaY, glabellaY < subnasaleY, subnasaleY < mentonY else {
            throw GeometryError.nonIncreasingVerticalLandmarks
        }
        let total = mentonY - trichionY
        let upper = (glabellaY - trichionY) / total
        let middle = (subnasaleY - glabellaY) / total
        let lower = (mentonY - subnasaleY) / total
        let target = 1.0 / 3.0
        let l1 = abs(upper - target) + abs(middle - target) + abs(lower - target)
        let balanceScore = max(0.0, min(1.0, 1.0 - (l1 / (4.0 / 3.0))))
        return FacialThirds(upper: upper, middle: middle, lower: lower, balanceScore: balanceScore)
    }

    /// Computes `faceHeight / faceWidth` and its signed deviation from `phi`.
    public static func goldenRatioDelta(faceHeight: Double, faceWidth: Double) throws -> GoldenRatioResult {
        guard faceHeight > 0.0, faceWidth > 0.0 else {
            throw GeometryError.nonPositiveDimensions
        }
        let ratio = faceHeight / faceWidth
        return GoldenRatioResult(ratio: ratio, delta: ratio - phi)
    }

    /// Computes a normalized bilateral mirror symmetry score in `[0, 1]`.
    public static func bilateralSymmetry(
        pairs: [LandmarkPair],
        midlineX: Double,
        faceWidth: Double
    ) throws -> Double {
        guard !pairs.isEmpty else {
            throw GeometryError.emptyLandmarkPairs
        }
        guard faceWidth > 0.0 else {
            throw GeometryError.nonPositiveDimensions
        }
        var sumError = 0.0
        for pair in pairs {
            let mirroredLeftX = 2.0 * midlineX - pair.left.x
            let dx = mirroredLeftX - pair.right.x
            let dy = pair.left.y - pair.right.y
            sumError += hypot(dx, dy)
        }
        let meanError = sumError / Double(pairs.count)
        let score = 1.0 - (meanError / faceWidth)
        return max(0.0, min(1.0, score))
    }
}
