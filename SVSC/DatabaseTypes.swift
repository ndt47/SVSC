//
//  DatabaseTypes.swift
//  SVSCBadgePrinter
//
//  Created by Nathan Taylor on 2/27/16.
//  Copyright © 2016 Nathan Taylor. All rights reserved.
//

import Foundation

typealias Member = (
    contact: Contact,
    membership: Membership?,
    sponsor: Sponsor?,
    nra: NRAMembership?,
    notes: Note?
)

typealias Edit = (
    previous: Member,
    new: Member,
    date: NSDate
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
    birth_date: NSDate?,
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
    date: NSDate?
)

typealias Sponsor = (
    contact_id: Int,
    name: String?,
    id: Int?,
    email: String?
)

enum MembershipType: String {
    case Regular = "Regular - Adult"
    case Regular_Service = "Regular + Service Obligation Fee - Adult"
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
    change_date: NSDate?,
    
    gate_card: String?,
    gate_status: GateStatus?,
    holster: HolsterRating?,
    
    application_date: NSDate?,
    membership_date: NSDate?,
    orientation_date: NSDate?,
    
    perm_id_dist_date: NSDate?,
    perm_id_dist_method: DistributionMethod?,
    
    prob_id_dist_date: NSDate?,
    meeting1: NSDate?,
    meeting2: NSDate?,
    meeting3: NSDate?,
    prob_exp_date: NSDate?
)

typealias NRAMembership = (
    contact_id: Int,
    id: String,
    exp_date: NSDate?
)

typealias MembershipLevel = (
    id: Int,
    type: MembershipType,
    url: String
)

