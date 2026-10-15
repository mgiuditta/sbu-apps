import CoreLocation

/// One GPS fix, reduced to what the speedometer needs.
nonisolated struct SpeedSample: Equatable, Sendable {
    var timestamp: Date
    /// Metres per second; negative when the fix has no speed.
    var speed: Double
    /// Metres per second; negative when the speed is not valid.
    var speedAccuracy: Double
    var latitude: Double
    var longitude: Double
    /// Metres; negative when the position is not valid.
    var horizontalAccuracy: Double
    /// Metres above sea level.
    var altitude: Double
    /// Metres; negative when the altitude is not valid.
    var verticalAccuracy: Double
    /// Degrees clockwise from true north, 0 up to 360; negative when not valid.
    var course: Double
    /// Degrees; negative when the course is not valid.
    var courseAccuracy: Double

    var hasValidSpeed: Bool { speed >= 0 && speedAccuracy >= 0 }

    var hasValidPosition: Bool { horizontalAccuracy >= 0 }

    init(
        timestamp: Date,
        speed: Double,
        speedAccuracy: Double,
        latitude: Double,
        longitude: Double,
        horizontalAccuracy: Double,
        altitude: Double = 0,
        verticalAccuracy: Double = -1,
        course: Double = -1,
        courseAccuracy: Double = -1
    ) {
        self.timestamp = timestamp
        self.speed = speed
        self.speedAccuracy = speedAccuracy
        self.latitude = latitude
        self.longitude = longitude
        self.horizontalAccuracy = horizontalAccuracy
        self.altitude = altitude
        self.verticalAccuracy = verticalAccuracy
        self.course = course
        self.courseAccuracy = courseAccuracy
    }

    init(location: CLLocation) {
        self.init(
            timestamp: location.timestamp,
            speed: location.speed,
            speedAccuracy: location.speedAccuracy,
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            horizontalAccuracy: location.horizontalAccuracy,
            altitude: location.altitude,
            verticalAccuracy: location.verticalAccuracy,
            course: location.course,
            courseAccuracy: location.courseAccuracy
        )
    }

    /// Straight-line distance in metres to another sample.
    func distance(from other: SpeedSample) -> Double {
        CLLocation(latitude: latitude, longitude: longitude)
            .distance(from: CLLocation(latitude: other.latitude, longitude: other.longitude))
    }
}
