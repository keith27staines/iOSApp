//
//  Person.swift
//  F4SPrototypes
//
//  Created by Keith Staines on 22/12/2018.
//  Copyright © 2018 Keith Staines. All rights reserved.
//

import Foundation

struct PersonViewData {
    var uuid: String? = nil
    var firstName: String? = nil
    var lastName: String? = nil
    var bio: String? = nil
    var role: String? = nil
    var imageName: String? = nil
    
    var fullName: String { return "\(firstName ?? "") \(lastName ?? "")" }
    var fullNameAndRole: String { return "\(fullName), \(role ?? "")"}
    var linkedInUrl: String? = "https://www.bbc.co.uk"
    var islinkedInHidden: Bool {
        return linkedInUrl == nil
    }
}


extension PersonViewData {

    static func makePeople() -> [PersonViewData] {
        return [
            PersonViewData(
                uuid: "1",
                firstName: "Sam",
                lastName: "AlexanderAlexanderAlexander",
                bio: """
            I have been at my company for two years and I love the challenges my job brings.
            I am passionate about the need to give young people great work experience which will
            not only give them a great start in their working life but will also help us find the great employees we need to succeed as a company
            I have been at my company for two years and I love the challenges my job brings.
            I am passionate about the need to give young people great work experience which will
            not only give them a great start in their working life but will also help us find the great employees we need to succeed as a company
            I have been at my company for two years and I love the challenges my job brings.
            I am passionate about the need to give young people great work experience which will
            not only give them a great start in their working life but will also help us find the great employees we need to succeed as a company
            I have been at my company for two years and I love the challenges my job brings.
            I am passionate about the need to give young people great work experience which will
            not only give them a great start in their working life but will also help us find the great employees we need to succeed as a company
            """,
                role: "CEO",
                imageName: "person1",
                linkedInUrl: "https://www.bbc.co.uk"),
            PersonViewData(
                uuid: "2",
                firstName: "Robin",
                lastName: "Beckett",
                bio: "I have been at my company for five years and I have mentored many interns",
                role: "Account manager",
                imageName: "person2",
                linkedInUrl: nil),
            PersonViewData(
                uuid: "3",
                firstName: "Karen",
                lastName: "Chatsworth",
                bio: "I have been at my company for five years and I have mentored many interns",
                role: "Developer",
                imageName: "person3",
                linkedInUrl: "https://www.bbc.co.uk"),
            PersonViewData(
                uuid: "4",
                firstName: "Nicky",
                lastName: "Fox",
                bio: "I have been at my company for five years and I have mentored many interns",
                role: "Chief Engineer",
                imageName: "person4",
                linkedInUrl: nil),
        ]
    }
}





