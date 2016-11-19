//
//  DatabaseTypes.swift
//  SVSCBadgePrinter
//
//  Created by Nathan Taylor on 2/27/16.
//  Copyright © 2016 Nathan Taylor. All rights reserved.
//

import Foundation

typealias Edit = (
    previous: Member,
    new: Member,
    date: Date
)

enum Gender: String {
    case Male = "M"
    case Female = "F"
}

typealias Contact = (
    id: Int,
    first_name: String,
    middle_name: String?,
    last_name: String,
    preferred_name: String?,
    address1: String?,
    address2: String?,
    city: String?,
    state: String?,
    zip: String?,
    birth_date: Date?,
    email: String,
    alt_email: String?,
    home_phone: String?,
    work_phone: String?,
    mobile_phone: String?,
    gender: Gender?
)

typealias Note = (
    contact_id: Int,
    text: String,
    date: Date?
)

typealias Sponsor = (
    contact_id: Int,
    name: String?,
    id: Int?,
    email: String?
)

enum MembershipType: String {
    case Regular = "Regular - Adult"
    case Probationary = "Member - Probationary"
    case Youth = "Youth"
    case Senior = "Senior"
    case Youth_Probationary = "Youth Member - Probationary"
    case Life = "Life Member - Adult"
    case Applicant = "Membership Applicant"
    case SVPD = "Scotts Valley PD"
    case Seaside = "Seaside Company Security"
    case Disabled_Veteran = "Disabled Veteran"
    case TEST = "TEST - FAKE MEMBERS FOR ADMIN TESTING"
    
    func shortName() -> String? {
        switch self {
        case .Regular:
            return "Regular"
        case .Youth:
            return "Youth"
        case .Probationary:
            return "Probationary"
        case .Youth_Probationary:
            return "Youth Probationary"
        case .Life:
            return "Life"
        case .SVPD:
            return "SVPD"
        case .Seaside:
            return "Seaside"
        case .Disabled_Veteran:
            return "Veteran"
        case .Senior:
            return "Senior"
        case .Applicant:
            return "Applicant"
        default:
            return nil
        }
    }
    func className() -> String? {
        switch self {
        case .Regular, .Probationary, .Applicant:
            return "Regular"
        case .Youth, .Youth_Probationary:
            return "Youth"
        case .Life:
            return "Life"
        case .SVPD:
            return "SVPD"
        case .Seaside:
            return "Seaside"
        case .Disabled_Veteran:
            return "Veteran"
        case .Senior:
            return "Senior"
        default:
            return nil
        }
    }

}

enum MembershipStatus: String {
    case Active = "Active"
    case Lapsed = "Lapsed"
    case PendingNew = "PendingNew"
    case PendingRenewal = "PendingRenewal"
    case PendingUpgrade = "PendingUpgrade"
}

enum GateStatus: String {
    case Active = "Active"
    case Locked = "Locked"
    case Returned = "Returned"
    case NotIssued = "Not Issued"
}

enum HolsterRating: String {
    case Yes = "Yes"
    case No = "No"
    case Requested = "Requested"
}

enum DistributionMethod: String {
    case AtMeeting = "At Meeting"
    case Mailed = "Mailed"
    case NotYetDistributed = "Not Distributed Yet"
}

typealias Membership = (
    contact_id: Int,
    member_id: Int?,
    level: MembershipLevel,
    status: MembershipStatus?,
    change_date: Date?,
    
    gate_card: String?,
    gate_status: GateStatus?,
    holster: HolsterRating?,
    
    application_date: Date?,
    membership_date: Date?,
    orientation_date: Date?,
    
    perm_id_dist_date: Date?,
    perm_id_dist_method: DistributionMethod?,
    
    prob_id_dist_date: Date?,
    meeting1: Date?,
    meeting2: Date?,
    meeting3: Date?,
    prob_exp_date: Date?
)

typealias NRAMembership = (
    contact_id: Int,
    id: String,
    exp_date: Date?
)

typealias MembershipLevel = (
    id: Int,
    type: MembershipType,
    url: String
)

typealias ClubEvent = (
    id: Int,
    name: String,
    location: String,
    start_date: Date,
    end_date: Date,
    registration_enabled: Bool,
    registration_limit: Int?,
    registrations: [ClubEventRegistration]?,
    registration_count: Int?,
    checked_in_attendees_count: Int,
    url: String
)

typealias ClubEventRegistration = (
    event_id: Int,
    registration_type_id: Int?,
    contact_id: Int,
    checked_in: Bool,
    paid: Bool,
    date: Date
)

typealias GroupParticipation = (
    contact_id: Int,
    name: String,
    id: Int
)

typealias Event = (
    id: Int,
    name: String,
    descriptions: String,
    start: Date,
    end: Date?
)


enum Gate : String {
    case Upper = "Upper Gate"
    case Lower = "Lower Gate"
}

enum GateSide : Int {
    case enter = 1
    case exit = -1
    case denied = 0
}

typealias GateAccess = (
    id: Int,
    name: String?,
    gate: Gate,
    side: GateSide,
    date: Date
)
