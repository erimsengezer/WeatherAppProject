import Foundation

class LocationData : Decodable {
    var woeid : Int
    var title : String
    enum CodingKeys: String, CodingKey {
        case woeid = "woeid"
        case title = "title"
    }
    
    init(woeid: Int, title: String) {
        self.woeid = woeid
        self.title = title
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        woeid = try values.decode(Int.self, forKey: .woeid)
        title = try values.decode(String.self, forKey: .title)
    }
}
