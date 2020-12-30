//
//  SessionRow.swift
//  Stray Scanner
//
//  Created by Kenneth Blomqvist on 11/15/20.
//  Copyright © 2020 Stray Robots. All rights reserved.
//

import SwiftUI

struct SessionRow: View {
    var session: Recording
    var body: some View {
        let duration = String(format: "%ds", Int(round(session.duration)))
        let name: String = session.name ?? ""
        HStack {
            VStack(alignment: .leading) {
                Text(name)
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 0.0)
                Text("\(duration)")
                    .font(.caption)
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 0.0)
            }
            Spacer()
        }
    }
}

