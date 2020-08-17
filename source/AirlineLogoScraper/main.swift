//
//  main.swift
//  AirlineLogoScraper
//
//  Created by Cal Stephens on 10/3/17.
//  Copyright © 2017 iOS Club. All rights reserved.
//

import Foundation
import AppKit

let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
let airlineLogosFolder = URL(fileURLWithPath: documents.appending("/Airline Logos"))
try! FileManager.default.createDirectory(at: airlineLogosFolder, withIntermediateDirectories: true, attributes: nil)

let letters = ["A", "B", "C", "D", "E",
     "F", "G", "H", "I", "J", "K", "L",
     "M", "N", "O", "P", "Q", "R", "S",
     "T", "U", "V", "W", "X", "Y", "Z"]

let numbers = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

let characters = letters + numbers

enum AirlineCode {
    /// Three-letter ICAO code
    case icao(String)
    
    // Two-letter IATA code
    case iata(String)
    
    var downloadUrl: URL? {
        switch self {
        case .icao(let icaoCode):
            return URL(string: "https://flightaware.com/images/airline_logos/90p/\(icaoCode).png")
        case .iata(let iataCode):
            return URL(string: "https://content.r9cdn.net/rimg/provider-logos/airlines/v/\(iataCode).png?crop=false&width=300&height=300")
        }
    }
    
    var stringValue: String {
        switch self {
        case .icao(let icaoCode):
            return icaoCode
        case .iata(let iataCode):
            return iataCode
        }
    }
}

func downloadLogo(for code: AirlineCode) {
    let semaphore = DispatchSemaphore(value: 0)
    
    guard let fetchUrl = code.downloadUrl else {
        print("nothing for \(code.stringValue)")
        return
    }
    
    let logoFileUrl = airlineLogosFolder.appendingPathComponent("/\(code.stringValue).png")
    
    URLSession.shared.dataTask(with: fetchUrl, completionHandler: { (data, _, _) -> Void in
        defer {
            semaphore.signal()
        }
        
        guard let data = data,
            NSImage(data: data) != nil else
        {
            print("nothing for \(code.stringValue)")
            return
        }
        
        print("downloaded \(code.stringValue)")
        try? data.write(to: logoFileUrl, options: [])
    }).resume()
    
    semaphore.wait()
}

for firstLetter in characters {
    for secondLetter in characters {
        downloadLogo(for: .iata("\(firstLetter)\(secondLetter)"))
        for thirdLetter in characters {
            downloadLogo(for: .icao("\(firstLetter)\(secondLetter)\(thirdLetter)"))
        }
    }
}


