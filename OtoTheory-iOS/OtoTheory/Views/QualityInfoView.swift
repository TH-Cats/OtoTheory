//
//  QualityInfoView.swift
//  OtoTheory
//
//  Chord quality information display view for contextMenu preview
//

import SwiftUI

struct QualityInfoView: View {
    let bodyText: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(bodyText)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                    .textSelection(.enabled)
            }
            .padding(16)
            .frame(maxWidth: 360, alignment: .leading)
        }
    }
}

#Preview {
    QualityInfoView(
        bodyText: "ポップス、R&Bの王道おしゃれサウンド。"
    )
}
