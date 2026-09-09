//
//  Muscle.swift
//  MuscleMap
//
//  Created by Melih Colpan on 2026-02-09.
//  Copyright © 2026 Melih Colpan. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum BodySlug: String, CaseIterable {
    case abs
    case biceps
    case calves
    case chest
    case deltoids
    case feet
    case forearm
    case gluteal
    case hamstring
    case hands
    case hair
    case head
    case knees
    case lowerBack = "lower-back"
    case obliques
    case quadriceps
    case tibialis
    case trapezius
    case triceps
    case upperBack = "upper-back"

    // New muscle groups
    case rotatorCuff = "rotator-cuff"
    case serratus
    case rhomboids

    // Sub-groups
    case ankles
    case adductors
    case neck
    case hipFlexors = "hip-flexors"
    case upperChest = "upper-chest"
    case lowerChest = "lower-chest"
    case innerQuad = "inner-quad"
    case outerQuad = "outer-quad"
    case upperAbs = "upper-abs"
    case lowerAbs = "lower-abs"
    case frontDeltoid = "front-deltoid"
    case rearDeltoid = "rear-deltoid"
    case upperTrapezius = "upper-trapezius"
    case lowerTrapezius = "lower-trapezius"

    var muscle: Muscle? {
        switch self {
        case .hair: return nil
        default: return Muscle(rawValue: rawValue)
        }
    }
}
