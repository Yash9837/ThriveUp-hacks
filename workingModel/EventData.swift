//
//  EventData.swift
//  ThriveUp
//
//  Created by Yash's Mackbook on 19/11/24.
//

import Foundation
import FirebaseFirestore
// MARK: - Push Events to Firestore
//class PushEventsToDatabase {
//    
//    private let db = Firestore.firestore()
//    
//    func pushEvents() {
//        // All event data
//        let events: [EventModel] = [
//            EventModel(
//                eventId: "19", title: "Aaruush Grand",
//                category: "Trending",
//                attendanceCount: 1000,
//                organizerName: "Aaruush Team",
//                date: "Wed, 3 Jan",
//                time: "18:00 - 22:00 IST",
//                location: "Main Arena",
//                locationDetails: "Central Lawn",
//                imageName: "AarushIn",
//                speakers: [Speaker(name: "Samay Raina", imageURL: "samayrainaimg"), Speaker(name: "Rohit Saraf", imageURL: "rohitsaraf")],
//                description: "The grand finale of Aaruush, featuring cultural and tech highlights.",
//                latitude: 13.0604,
//                longitude: 80.2496
//            ),
//            EventModel(
//                eventId: "1", title: "Samay Raina Comedy Night",
//                category: "Fun and Entertainment",
//                attendanceCount: 100,
//                organizerName: "Fun Team",
//                date: "Fri, 15 Dec",
//                time: "19:00 - 21:00 IST",
//                location: "Auditorium A",
//                locationDetails: "Downtown Center",
//                imageName: "SamayRaina",
//                speakers: [Speaker(name: "Samay Raina", imageURL: "samayrainaimg")],
//                description: "A hilarious evening of stand-up comedy by Samay Raina.",
//                latitude: 13.0827,
//                longitude: 80.2707
//            ),
//            EventModel(
//                eventId: "2", title: "Aditi Mittal Comedy Show",
//                category: "Fun and Entertainment",
//                attendanceCount: 150,
//                organizerName: "Laughter Club",
//                date: "Sat, 16 Dec",
//                time: "18:00 - 20:00 IST",
//                location: "Auditorium B",
//                locationDetails: "City Square",
//                imageName: "AditiMittal",
//                speakers: [Speaker(name: "Aditi Mittal", imageURL: "aditimittalimg")],
//                description: "Experience the wit and humor of Aditi Mittal.",
//                latitude: 13.0780,
//                longitude: 80.2500
//            ),
//            EventModel(
//                eventId: "3", title: "Sahil Shah Live",
//                category: "Fun and Entertainment",
//                attendanceCount: 200,
//                organizerName: "Event Pro",
//                date: "Sun, 17 Dec",
//                time: "20:00 - 22:00 IST",
//                location: "Grand Theatre",
//                locationDetails: "East Avenue",
//                imageName: "Sahilshah",
//                speakers: [Speaker(name: "Sahil Shah", imageURL: "sahilshahimg")],
//                description: "Join Sahil Shah for a night full of entertainment.",
//                latitude: 13.0750,
//                longitude: 80.2600
//            ),
//            EventModel(
//                eventId: "4", title: "Square One Fest",
//                category: "Fun and Entertainment",
//                attendanceCount: 250,
//                organizerName: "City Events",
//                date: "Mon, 18 Dec",
//                time: "10:00 - 22:00 IST",
//                location: "City Park",
//                locationDetails: "Greenwood",
//                imageName: "SqareOne",
//                speakers: [],
//                description: "Enjoy a full day of activities, music, and fun at Square One Fest.",
//                latitude: 13.0800,
//                longitude: 80.2400
//            ),
//            EventModel(
//                eventId: "5", title: "Roboriot Championship",
//                category: "Tech and Innovation",
//                attendanceCount: 300,
//                organizerName: "Tech Society",
//                date: "Tue, 19 Dec",
//                time: "09:00 - 17:00 IST",
//                location: "Tech Hall",
//                locationDetails: "Innovation Avenue",
//                imageName: "Roboriot",
//                speakers: [],
//                description: "Robotics championship featuring teams from across the region.",
//                latitude: 13.0450,
//                longitude: 80.2200
//            ),
//            EventModel(
//                eventId: "6", title: "Figma Summit",
//                category: "Tech and Innovation",
//                attendanceCount: 150,
//                organizerName: "Designers Guild",
//                date: "Wed, 20 Dec",
//                time: "10:00 - 16:00 IST",
//                location: "Creative Hub",
//                locationDetails: "Design Plaza",
//                imageName: "FigmaSummit",
//                speakers: [],
//                description: "Explore the latest in UI/UX design with industry experts.",
//                latitude: 13.0480,
//                longitude: 80.2120
//            ),
//            EventModel(
//                eventId: "7", title: "Ideathon",
//                category: "Tech and Innovation",
//                attendanceCount: 100,
//                organizerName: "Innovation Lab",
//                date: "Thu, 21 Dec",
//                time: "10:00 - 18:00 IST",
//                location: "Campus Center",
//                locationDetails: "Innovation Lane",
//                imageName: "Ideathon",
//                speakers: [],
//                description: "A full-day idea generation competition for students and professionals.",
//                latitude: 13.0530,
//                longitude: 80.2150
//            ),
//            EventModel(
//                eventId: "8", title: "DShack Coding Challenge",
//                category: "Tech and Innovation",
//                attendanceCount: 200,
//                organizerName: "Tech Coders",
//                date: "Fri, 22 Dec",
//                time: "09:00 - 21:00 IST",
//                location: "Coding Arena",
//                locationDetails: "Code Street",
//                imageName: "DShack",
//                speakers: [],
//                description: "A high-energy coding challenge for developers of all skill levels.",
//                latitude: 13.0650,
//                longitude: 80.2300
//            ),
//            EventModel(
//                                eventId: "9", title: "DSA Club Meetup",
//                                category: "Club and Societies",
//                                attendanceCount: 50,
//                                organizerName: "DSA Club",
//                                date: "Sat, 23 Dec",
//                                time: "15:00 - 17:00 IST",
//                                location: "Library Hall",
//                                locationDetails: "SRMIST Campus",
//                                imageName: "DSA",
//                                speakers: [],
//                                description: "Meetup for Data Structures and Algorithms enthusiasts.",
//                                latitude: 13.0604,
//                                longitude: 80.2496
//                            ),
//                            EventModel(
//                                eventId: "10", title: "D-Bug Workshop",
//                                category: "Club and Societies",
//                                attendanceCount: 75,
//                                organizerName: "Coding Club",
//                                date: "Sun, 24 Dec",
//                                time: "10:00 - 13:00 IST",
//                                location: "Tech Lab 2",
//                                locationDetails: "SRMIST Campus",
//                                imageName: "Dbug",
//                                speakers: [],
//                                description: "Learn debugging techniques for efficient coding.",
//                                latitude: 13.0604,
//                                longitude: 80.2496
//                            ),
//                            EventModel(
//                                eventId: "11", title: "MLSA Knowledge Sharing",
//                                category: "Club and Societies",
//                                attendanceCount: 60,
//                                organizerName: "Microsoft Club",
//                                date: "Mon, 25 Dec",
//                                time: "14:00 - 16:00 IST",
//                                location: "Room 203",
//                                locationDetails: "IT Block",
//                                imageName: "MLSA",
//                                speakers: [],
//                                description: "Knowledge sharing session hosted by MLSA members.",
//                                latitude: 13.0604,
//                                longitude: 80.2496
//                            ),                EventModel(
//                                eventId: "12", title: "Big Deal Dance Battle",
//                                category: "Cultural",
//                                attendanceCount: 200,
//                                organizerName: "Cultural Committee",
//                                date: "Tue, 26 Dec",
//                                time: "18:00 - 21:00 IST",
//                                location: "Main Stage",
//                                locationDetails: "Central Lawn",
//                                imageName: "BigDeal",
//                                speakers: [],
//                                description: "Dance competition featuring amazing talent.",
//                                latitude: 13.0604,
//                                longitude: 80.2496
//                            ),
//                            EventModel(
//                                eventId: "13", title: "Musication Evening",
//                                category: "Cultural",
//                                attendanceCount: 300,
//                                organizerName: "Music Club",
//                                date: "Wed, 27 Dec",
//                                time: "19:00 - 22:00 IST",
//                                location: "Auditorium C",
//                                locationDetails: "SRMIST Campus",
//                                imageName: "Musication",
//                                speakers: [],
//                                description: "An evening filled with soothing music performances.",
//                                latitude: 13.0604,
//                                longitude: 80.2496
//                            ), EventModel(
//                                eventId: "14", title: "Aaruush Live Session 1",
//                                category: "Networking",
//                                attendanceCount: 100,
//                                organizerName: "Networking Club",
//                                date: "Thu, 28 Dec",
//                                time: "10:00 - 12:00 IST",
//                                location: "Lecture Hall 1",
//                                locationDetails: "Networking Block",
//                                imageName: "AarushLive1",
//                                speakers: [],
//                                description: "Interactive live session with industry professionals.",
//                                latitude: 13.0604,
//                                longitude: 80.2496
//                            ),
//                            EventModel(
//                                eventId: "15", title: "TEDx Youth",
//                                category: "Networking",
//                                attendanceCount: 400,
//                                organizerName: "TEDx Team",
//                                date: "Fri, 29 Dec",
//                                time: "14:00 - 17:00 IST",
//                                location: "Grand Theatre",
//                                locationDetails: "East Avenue",
//                                imageName: "TedX",
//                                speakers: [],
//                                description: "A platform for sharing inspiring ideas and innovation.",
//                                latitude: 13.0604,
//                                longitude: 80.2496
//                            ),EventModel(
//                                eventId: "16", title: "Beach Cleanup Drive",
//                                category: "Wellness",
//                                attendanceCount: 50,
//                                organizerName: "NCC Club",
//                                date: "Sat, 30 Dec",
//                                time: "06:00 - 09:00 IST",
//                                location: "Marina Beach",
//                                locationDetails: "Chennai",
//                                imageName: "BeachClean",
//                                speakers: [],
//                                description: "Volunteer drive to clean up Marina Beach.",
//                                latitude: 13.0604,
//                                longitude: 80.2496
//                            ), EventModel(
//                                eventId: "17", title: "Twisted Trivia",
//                                category: "Sports",
//                                attendanceCount: 80,
//                                organizerName: "Sports Club",
//                                date: "Mon, 1 Jan",
//                                time: "16:00 - 18:00 IST",
//                                location: "Sports Complex",
//                                locationDetails: "SRMIST Campus",
//                                imageName: "TwistedTrivia",
//                                speakers: [],
//                                description: "Fun trivia challenge focusing on sports topics.",
//                                latitude: 13.0604,
//                                longitude: 80.2496 ), EventModel(
//                                eventId: "18", title: "Career Guidance Session",
//                                category: "Career Connect",
//                                attendanceCount: 200,
//                                organizerName: "Placement Cell",
//                                date: "Tue, 2 Jan",
//                                time: "10:00 - 12:00 IST",
//                                location: "Lecture Hall 2",
//                                locationDetails: "Placement Block",
//                                imageName: "ppt1",
//                                speakers: [],
//                                description: "Session on shaping careers and leveraging opportunities.",
//                                latitude: 13.0604,
//                                longitude: 80.2496
//                            ),
//        ]
//        
//        // Push each event to Firestore
//        for event in events {
//            pushEventToFirestore(event)
//        }
//    }
//    
//    private func pushEventToFirestore(_ event: EventModel) {
//            // Prepare the event data for Firestore
//            let eventData: [String: Any] = [
//                "eventId": event.eventId,
//                "title": event.title,
//                "category": event.category,
//                "attendanceCount": event.attendanceCount,
//                "organizerName": event.organizerName,
//                "date": event.date,
//                "time": event.time,
//                "location": event.location,
//                "locationDetails": event.locationDetails,
//                "imageName": event.imageName,
//                "speakers": event.speakers.map { ["name": $0.name, "imageURL": $0.imageURL] },
//                "description": event.description ?? "",
//                "latitude": event.latitude ?? 0.0,
//                "longitude": event.longitude ?? 0.0
//            ]
//            
//            // Save to Firestore
//            db.collection("events").document(event.eventId).setData(eventData) { error in
//                if let error = error {
//                    print("Error uploading event \(event.eventId): \(error.localizedDescription)")
//                } else {
//                    print("Successfully uploaded event \(event.eventId)")
//                }
//            }
//        }
//    }

func populateFirestore() {
    let db = Firestore.firestore()
    
    let categories = [
        "Trending": [
            EventModel(
                eventId: "19",
                title: "Aaruush Grand Finale",
                category: "Trending",
                attendanceCount: 1000,
                organizerName: "Aaruush Team",
                date: "Wed, 3 Jan",
                time: "18:00 - 22:00 IST",
                location: "Main Arena",
                locationDetails: "Central Lawn",
                imageName: "AarushIn",
                speakers: [
                    Speaker(name: "Samay Raina", imageURL: "samayrainaimg"),
                    Speaker(name: "Rohit Saraf", imageURL: "rohitsaraf")
                ], userId: "",
                description: "The grand finale of Aaruush, featuring cultural and tech highlights.",
                latitude: 13.0604,
                longitude: 80.2496,
                tags: []
            )
        ],
        "Fun and Entertainment": [
            EventModel(
                eventId: "1",
                title: "Samay Raina Comedy Night",
                category: "Fun and Entertainment",
                attendanceCount: 100,
                organizerName: "Fun Team",
                date: "Fri, 15 Dec",
                time: "19:00 - 21:00 IST",
                location: "Auditorium A",
                locationDetails: "Downtown Center",
                imageName: "SamayRaina",
                speakers: [
                    Speaker(name: "Samay Raina", imageURL: "samayrainaimg")
                ], userId: "",
                description: "A hilarious evening of stand-up comedy by Samay Raina.",
                latitude: 13.0827,
                longitude: 80.2707,
                tags: []
            )
        ]
    ]
    
    for (category, events) in categories {
        let categoryRef = db.collection("categories").document(category)
        
        for event in events {
            let eventRef = categoryRef.collection("events").document(event.eventId)
            
            let eventData: [String: Any] = [
                "title": event.title,
                "category": event.category,
                "attendanceCount": event.attendanceCount,
                "organizerName": event.organizerName,
                "date": event.date,
                "time": event.time,
                "location": event.location,
                "locationDetails": event.locationDetails,
                "imageName": event.imageName,
                "description": event.description ?? "",
                "latitude": event.latitude ?? 0.0,
                "longitude": event.longitude ?? 0.0,
                "speakers": event.speakers.map { ["name": $0.name, "imageURL": $0.imageURL] }
            ]
            
            eventRef.setData(eventData) { error in
                if let error = error {
                    print("Error adding event: \(error.localizedDescription)")
                } else {
                    print("Event \(event.title) added successfully!")
                }
            }
        }
        
    }
}


struct EventDataProvider {
    static func getCategories() -> [CategoryModel] {
        let trendingEvents = [
            EventModel(
                eventId: "19", title: "Aaruush Grand Finale",
                category: "Trending",
                attendanceCount: 1000,
                organizerName: "Aaruush Team",
                date: "Wed, 3 Jan",
                time: "18:00 - 22:00 IST",
                location: "Main Arena",
                locationDetails: "Central Lawn",
                imageName: "AarushIn",
                speakers: [Speaker(name: "Samay Raina", imageURL: "samayrainaimg"),Speaker(name: "Rohit Saraf", imageURL: "rohitsaraf")], userId: "",
                description: "The grand finale of Aaruush, featuring cultural and tech highlights.",
                latitude: 13.0604,
                longitude: 80.2496,
                tags: []
            ),
            EventModel(
                eventId: "1", title: "Samay Raina Comedy Night",
                category: "Fun and Entertainment",
                attendanceCount: 100,
                organizerName: "Fun Team",
                date: "Fri, 15 Dec",
                time: "19:00 - 21:00 IST",
                location: "Auditorium A",
                locationDetails: "Downtown Center",
                imageName: "SamayRaina",
                speakers: [Speaker(name: "Samay Raina", imageURL: "samayrainaimg")], userId: "",
                description: "A hilarious evening of stand-up comedy by Samay Raina.",
                latitude: 13.0827,
                longitude: 80.2707,
                tags: []
            ),
            EventModel(
                eventId: "19", title: "Aaruush Grand Finale",
                category: "Trending",
                attendanceCount: 1000,
                organizerName: "Aaruush Team",
                date: "Wed, 3 Jan",
                time: "18:00 - 22:00 IST",
                location: "Main Arena",
                locationDetails: "Central Lawn",
                imageName: "AarushIn",
                speakers: [], userId: "",
                description: "The grand finale of Aaruush, featuring cultural and tech highlights.",
                latitude: 13.0604,
                longitude: 80.2496,
                tags: []
            )
        ]
        let funEvents = [
                EventModel(
                    eventId: "1", title: "Samay Raina Comedy Night",
                    category: "Fun and Entertainment",
                    attendanceCount: 100,
                    organizerName: "Fun Team",
                    date: "Fri, 15 Dec",
                    time: "19:00 - 21:00 IST",
                    location: "Auditorium A",
                    locationDetails: "Downtown Center",
                    imageName: "SamayRaina",
                    speakers: [Speaker(name: "Samay Raina", imageURL: "samayrainaimg")], userId: "",
                    description: "A hilarious evening of stand-up comedy by Samay Raina.",
                    latitude: 13.0827,
                    longitude: 80.2707,
                    tags: []
                ),
                EventModel(
                    eventId: "2", title: "Aditi Mittal Comedy Show",
                    category: "Fun and Entertainment",
                    attendanceCount: 150,
                    organizerName: "Laughter Club",
                    date: "Sat, 16 Dec",
                    time: "18:00 - 20:00 IST",
                    location: "Auditorium B",
                    locationDetails: "City Square",
                    imageName: "AditiMittal",
                    speakers: [Speaker(name: "Aditi Mittal", imageURL: "aditimittalimg")], userId: "",
                    description: "Experience the wit and humor of Aditi Mittal.",
                    latitude: 13.0780,
                    longitude: 80.2500,
                    tags: []
                ),
                EventModel(
                    eventId: "3", title: "Sahil Shah Live",
                    category: "Fun and Entertainment",
                    attendanceCount: 200,
                    organizerName: "Event Pro",
                    date: "Sun, 17 Dec",
                    time: "20:00 - 22:00 IST",
                    location: "Grand Theatre",
                    locationDetails: "East Avenue",
                    imageName: "Sahilshah",
                    speakers: [Speaker(name: "Sahil Shah", imageURL: "sahilshahimg")], userId: "",
                    description: "Join Sahil Shah for a night full of entertainment.",
                    latitude: 13.0750,
                    longitude: 80.2600,
                    tags: []
                ),
                EventModel(
                    eventId: "4", title: "Square One Fest",
                    category: "Fun and Entertainment",
                    attendanceCount: 250,
                    organizerName: "City Events",
                    date: "Mon, 18 Dec",
                    time: "10:00 - 22:00 IST",
                    location: "City Park",
                    locationDetails: "Greenwood",
                    imageName: "SqareOne",
                    speakers: [], userId: "",
                    description: "Enjoy a full day of activities, music, and fun at Square One Fest.",
                    latitude: 13.0800,
                    longitude: 80.2400,
                    tags: []
                )
            ]

            let techEvents = [
                EventModel(
                    eventId: "5", title: "Roboriot Championship",
                    category: "Tech and Innovation",
                    attendanceCount: 300,
                    organizerName: "Tech Society",
                    date: "Tue, 19 Dec",
                    time: "09:00 - 17:00 IST",
                    location: "Tech Hall",
                    locationDetails: "Innovation Avenue",
                    imageName: "Roboriot",
                    speakers: [], userId: "",
                    description: "Robotics championship featuring teams from across the region.",
                    latitude: 13.0450,
                    longitude: 80.2200,
                    tags: []
                ),
                EventModel(
                    eventId: "6", title: "Figma Summit",
                    category: "Tech and Innovation",
                    attendanceCount: 150,
                    organizerName: "Designers Guild",
                    date: "Wed, 20 Dec",
                    time: "10:00 - 16:00 IST",
                    location: "Creative Hub",
                    locationDetails: "Design Plaza",
                    imageName: "FigmaSummit",
                    speakers: [], userId: "",
                    description: "Explore the latest in UI/UX design with industry experts.",
                    latitude: 13.0480,
                    longitude: 80.2120,
                    tags: []
                ),
                EventModel(
                    eventId: "7", title: "Ideathon",
                    category: "Tech and Innovation",
                    attendanceCount: 100,
                    organizerName: "Innovation Lab",
                    date: "Thu, 21 Dec",
                    time: "10:00 - 18:00 IST",
                    location: "Campus Center",
                    locationDetails: "Innovation Lane",
                    imageName: "Ideathon",
                    speakers: [], userId: "",
                    description: "A full-day idea generation competition for students and professionals.",
                    latitude: 13.0530,
                    longitude: 80.2150,
                    tags: []
                ),
                EventModel(
                    eventId: "8", title: "DShack Coding Challenge",
                    category: "Tech and Innovation",
                    attendanceCount: 200,
                    organizerName: "Tech Coders",
                    date: "Fri, 22 Dec",
                    time: "09:00 - 21:00 IST",
                    location: "Coding Arena",
                    locationDetails: "Code Street",
                    imageName: "DShack",
                    speakers: [], userId: "",
                    description: "A high-energy coding challenge for developers of all skill levels.",
                    latitude: 13.0650,
                    longitude: 80.2300,
                    tags: []
                )
            ]
        let clubAndSocietiesEvents = [
                EventModel(
                    eventId: "9", title: "DSA Club Meetup",
                    category: "Club and Societies",
                    attendanceCount: 50,
                    organizerName: "DSA Club",
                    date: "Sat, 23 Dec",
                    time: "15:00 - 17:00 IST",
                    location: "Library Hall",
                    locationDetails: "SRMIST Campus",
                    imageName: "DSA",
                    speakers: [], userId: "",
                    description: "Meetup for Data Structures and Algorithms enthusiasts.",
                    latitude: 13.0604,
                    longitude: 80.2496,
                    tags: []
                ),
                EventModel(
                    eventId: "10", title: "D-Bug Workshop",
                    category: "Club and Societies",
                    attendanceCount: 75,
                    organizerName: "Coding Club",
                    date: "Sun, 24 Dec",
                    time: "10:00 - 13:00 IST",
                    location: "Tech Lab 2",
                    locationDetails: "SRMIST Campus",
                    imageName: "Dbug",
                    speakers: [], userId: "",
                    description: "Learn debugging techniques for efficient coding.",
                    latitude: 13.0604,
                    longitude: 80.2496,
                    tags: []
                ),
                EventModel(
                    eventId: "11", title: "MLSA Knowledge Sharing",
                    category: "Club and Societies",
                    attendanceCount: 60,
                    organizerName: "Microsoft Club",
                    date: "Mon, 25 Dec",
                    time: "14:00 - 16:00 IST",
                    location: "Room 203",
                    locationDetails: "IT Block",
                    imageName: "MLSA",
                    speakers: [], userId: "",
                    description: "Knowledge sharing session hosted by MLSA members.",
                    latitude: 13.0604,
                    longitude: 80.2496,
                    tags: []
                )
            ]
            
            let culturalEvents = [
                EventModel(
                    eventId: "12", title: "Big Deal Dance Battle",
                    category: "Cultural",
                    attendanceCount: 200,
                    organizerName: "Cultural Committee",
                    date: "Tue, 26 Dec",
                    time: "18:00 - 21:00 IST",
                    location: "Main Stage",
                    locationDetails: "Central Lawn",
                    imageName: "BigDeal",
                    speakers: [], userId: "",
                    description: "Dance competition featuring amazing talent.",
                    latitude: 13.0604,
                    longitude: 80.2496,
                    tags: []
                ),
                EventModel(
                    eventId: "13", title: "Musication Evening",
                    category: "Cultural",
                    attendanceCount: 300,
                    organizerName: "Music Club",
                    date: "Wed, 27 Dec",
                    time: "19:00 - 22:00 IST",
                    location: "Auditorium C",
                    locationDetails: "SRMIST Campus",
                    imageName: "Musication",
                    speakers: [], userId: "",
                    description: "An evening filled with soothing music performances.",
                    latitude: 13.0604,
                    longitude: 80.2496,
                    tags: []
                )
            ]
            
            let networkingEvents = [
                EventModel(
                    eventId: "14", title: "Aaruush Live Session 1",
                    category: "Networking",
                    attendanceCount: 100,
                    organizerName: "Networking Club",
                    date: "Thu, 28 Dec",
                    time: "10:00 - 12:00 IST",
                    location: "Lecture Hall 1",
                    locationDetails: "Networking Block",
                    imageName: "AarushLive1",
                    speakers: [], userId: "",
                    description: "Interactive live session with industry professionals.",
                    latitude: 13.0604,
                    longitude: 80.2496,
                    tags: []
                ),
                EventModel(
                    eventId: "15", title: "TEDx Youth",
                    category: "Networking",
                    attendanceCount: 400,
                    organizerName: "TEDx Team",
                    date: "Fri, 29 Dec",
                    time: "14:00 - 17:00 IST",
                    location: "Grand Theatre",
                    locationDetails: "East Avenue",
                    imageName: "TedX",
                    speakers: [], userId: "",
                    description: "A platform for sharing inspiring ideas and innovation.",
                    latitude: 13.0604,
                    longitude: 80.2496,
                    tags: []
                )
            ]
            let wellnessEvents = [
                EventModel(
                    eventId: "16", title: "Beach Cleanup Drive",
                    category: "Wellness",
                    attendanceCount: 50,
                    organizerName: "NCC Club",
                    date: "Sat, 30 Dec",
                    time: "06:00 - 09:00 IST",
                    location: "Marina Beach",
                    locationDetails: "Chennai",
                    imageName: "BeachClean",
                    speakers: [], userId: "",
                    description: "Volunteer drive to clean up Marina Beach.",
                    latitude: 13.0604,
                    longitude: 80.2496,
                    tags: []
                )
            ]
            let sportsEvents = [
                EventModel(
                    eventId: "17", title: "Twisted Trivia",
                    category: "Sports",
                    attendanceCount: 80,
                    organizerName: "Sports Club",
                    date: "Mon, 1 Jan",
                    time: "16:00 - 18:00 IST",
                    location: "Sports Complex",
                    locationDetails: "SRMIST Campus",
                    imageName: "TwistedTrivia",
                    speakers: [], userId: "",
                    description: "Fun trivia challenge focusing on sports topics.",
                    latitude: 13.0604,
                    longitude: 80.2496,
                    tags: []
                )
            ]
            let careerConnectEvents = [
                EventModel(
                    eventId: "18", title: "Career Guidance Session",
                    category: "Career Connect",
                    attendanceCount: 200,
                    organizerName: "Placement Cell",
                    date: "Tue, 2 Jan",
                    time: "10:00 - 12:00 IST",
                    location: "Lecture Hall 2",
                    locationDetails: "Placement Block",
                    imageName: "ppt1",
                    speakers: [], userId: "",
                    description: "Session on shaping careers and leveraging opportunities.",
                    latitude: 13.0604,
                    longitude: 80.2496,
                    tags: []
                )
            ]

        return [
            CategoryModel(name: "Trending", events: trendingEvents),
            CategoryModel(name: "Fun and Entertainment", events: funEvents),
            CategoryModel(name: "Tech and Innovation", events: techEvents),
            CategoryModel(name: "Club and Societies", events: clubAndSocietiesEvents),
            CategoryModel(name: "Cultural", events: culturalEvents),
            CategoryModel(name: "Networking", events: networkingEvents),
            CategoryModel(name: "Wellness", events: wellnessEvents),
            CategoryModel(name: "Sports", events: sportsEvents),
            CategoryModel(name: "Career Connect", events: careerConnectEvents)
        ]
    }
}


    
        
        
    
