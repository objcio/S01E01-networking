//: To run this playground start a SimpleHTTPServer on the commandline like this:
//:
//: `python -m SimpleHTTPServer 8000`
//:
//: It will serve up the current directory, so make sure to be in the directory containing episodes.json

import UIKit
import PlaygroundSupport


let url = URL(string: "http://localhost:8000/episodes.json")!


struct Episode: Decodable {
    let id: String
    let title: String
}


struct Media: Decodable {}


struct Resource<A: Decodable> {
    let url: URL
    let parse: (Data) -> A?
}


extension Resource {
    init(url: URL) {
        self.url = url
        self.parse = { data in
            return try? JSONDecoder().decode(A.self, from: data)
        }
    }
}


extension Episode {
    static let all = Resource<[Episode]>(url: url)
}


final class Webservice {
    func load<A>(resource: Resource<A>, completion: @escaping (A?) -> ()) {
        URLSession.shared.dataTask(with: resource.url) { data, _, _ in
            guard let data = data else {
                completion(nil)
                return
            }
            completion(resource.parse(data))
        }.resume()
    }
}


PlaygroundPage.current.needsIndefiniteExecution = true

Webservice().load(resource: Episode.all) { result in
    print(result ?? "")
}

