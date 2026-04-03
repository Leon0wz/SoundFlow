import SwiftData

@Model
class Preset {
    var name: String = ""

    init(name: String = "") {
        self.name = name
    }
}
