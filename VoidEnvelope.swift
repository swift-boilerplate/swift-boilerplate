//
//  VoidEnvelope.swift
//  Facestar
//
//  Created by JohnP on 2/17/17.
//  Copyright © 2017 JohnP. All rights reserved.
//

import Argo

public struct VoidEnvelope {
}

extension VoidEnvelope: Decodable {
    public static func decode(_ json: JSON) -> Decoded<VoidEnvelope> {
        return .success(VoidEnvelope())
    }
}
