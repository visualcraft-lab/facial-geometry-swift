import XCTest
@testable import FacialGeometry

final class FacialGeometryTests: XCTestCase {
    func testCanthalTiltPositive() throws {
        let tilt = try FacialGeometry.canthalTiltDegrees(
            medial: .init(x: 100, y: 200),
            lateral: .init(x: 140, y: 193)
        )
        XCTAssertGreaterThan(tilt, 9.0)
        XCTAssertLessThan(tilt, 10.5)
    }

    func testCanthalTiltThrowsOnZeroSpan() {
        XCTAssertThrowsError(
            try FacialGeometry.canthalTiltDegrees(
                medial: .init(x: 100, y: 200),
                lateral: .init(x: 100, y: 195)
            )
        ) { error in
            XCTAssertEqual(error as? FacialGeometry.GeometryError, .degenerateHorizontalSpan)
        }
    }

    func testFacialThirdsPerfectBalance() throws {
        let thirds = try FacialGeometry.computeFacialThirds(
            trichionY: 100,
            glabellaY: 200,
            subnasaleY: 300,
            mentonY: 400
        )
        XCTAssertEqual(thirds.upper, 1.0 / 3.0, accuracy: 1e-9)
        XCTAssertEqual(thirds.middle, 1.0 / 3.0, accuracy: 1e-9)
        XCTAssertEqual(thirds.lower, 1.0 / 3.0, accuracy: 1e-9)
        XCTAssertEqual(thirds.balanceScore, 1.0, accuracy: 1e-9)
    }

    func testGoldenRatioDelta() throws {
        let result = try FacialGeometry.goldenRatioDelta(faceHeight: 161.8033988749895, faceWidth: 100)
        XCTAssertEqual(result.ratio, FacialGeometry.phi, accuracy: 1e-9)
        XCTAssertEqual(result.delta, 0.0, accuracy: 1e-9)
    }

    func testBilateralSymmetryPerfect() throws {
        let pairs: [FacialGeometry.LandmarkPair] = [
            .init(left: .init(x: 160, y: 200), right: .init(x: 240, y: 200)),
            .init(left: .init(x: 170, y: 260), right: .init(x: 230, y: 260))
        ]
        let score = try FacialGeometry.bilateralSymmetry(pairs: pairs, midlineX: 200, faceWidth: 160)
        XCTAssertEqual(score, 1.0, accuracy: 1e-9)
    }
}
