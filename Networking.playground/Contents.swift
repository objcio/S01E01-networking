import UIKit
import XCPlayground

struct Episode {
    let id: String
    let title: String
}

typealias JSONDictionary = [String:AnyObject]

extension Episode {
    init?(dictionary: JSONDictionary) {
        guard let id = dictionary["id"] as? String,
            title = dictionary["title"] as? String else { return nil }
        self.id = id
        self.title = title
    }
}

struct Media {}

let url = NSURL(string: "http://localhost:8000/episodes.json")!

struct Resource<A> {
    let url: NSURL
    let parse: NSData -> A?
}

extension Resource {
    init(url: NSURL, parseJSON: AnyObject -> A?) {
        self.url = url
        self.parse = { data in
            let json = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
            return json.flatMap(parseJSON)
        }
    }
}

extension Episode {
    static let all = Resource<[Episode]>(url: url, parseJSON: { json in
        guard let dictionaries = json as? [JSONDictionary] else { return nil }
        return dictionaries.flatMap(Episode.init)
    })
}


final class Webservice {
    func load<A>(resource: Resource<A>, completion: (A?) -> ()) {
        NSURLSession.sharedSession().dataTaskWithURL(resource.url) { data, _, _ in
            guard let data = data else {
                completion(nil)
                return
            }
            completion(resource.parse(data))
        }.resume()
    }
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

Webservice().load(Episode.all) { result in
    print(result)
}
