//
//  InformationView.swift
//  StrayScanner
//
//  Created by Kenneth Blomqvist on 2/28/21.
//  Copyright © 2021 Stray Robots. All rights reserved.
//

import SwiftUI

struct InformationView: View {
    let paddingLeftRight: CGFloat = 15
    let paddingTextTop: CGFloat = 10
    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()
            ScrollView {
            VStack(alignment: .leading) {
                Text("About This App").font(.title)
                    .fontWeight(.bold)
                Group {
                bodyText("""
This app lets you record video and depth datasets using the camera and LIDAR scanner.
""")

                heading("Transfering Datasets To Your Desktop")
                
                bodyText("""
The recorded datasets can be transferred to your desktop computer by connecting your device to it with the lightning cable.

On Mac, you can access the files through Finder. In the sidebar, select your device. Under the "Files" tab, you should see an entry for StrayScanner. Expand it, then drag the folders to the desired location. There is one folder per dataset, each named after a random alphanumerical hash.

On Windows, you should be able to access the files through iTunes.
""")

                heading("Using The Data")
                
                bodyText("Below is a Python script which uses Open3D to make a 3D reconstruction of the scene. Here is also a detailed description of the data model.")
                
                link(text: "Example script", destination: "https://gist.github.com/kekeblom/f0e7925d514db3c733df8bc30dc1ff4b")
                link(text: "Data model", destination: "https://www.notion.so/Stray-Scanner-Data-Model-aea95b702b484d41b2de12d2e90781ce")
                    
                }
                Group {
                heading("Privacy Policy")

                bodyText("We do not track you. All of the data you record is stored on your device. We never call home or otherwise collect data about how you use the app.")

                link(text: "Privacy policy", destination: "https://www.notion.so/Privacy-Policy-f1a6b1bcf7ed48098ffe2f50281e5c34")

                heading("Disclaimer")
                bodyText("This application is provided as is.\nIn no event shall the authors or copyright holders be liable for any claim, damages or other liability arising from using, or in connection with using the software.")
                
                Spacer()
                }
            }.padding(.all, paddingLeftRight)
            }
            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        
        }
    }
    
    private func heading(_ text: String) -> some View {
        Text(text)
            .font(.title3)
            .fontWeight(.bold)
            .padding(.top, 20)
    }
    
    private func bodyText(_ text: String) -> some View {
        Text(text)
            .font(.body)
            .multilineTextAlignment(.leading)
            .lineSpacing(1.25)
            .padding(.top, paddingTextTop)
    }
    
    private func link(text: String, destination: String) -> some View {
        Text(text)
            .font(.body)
            .foregroundColor(Color.blue)
            .padding(.top, paddingTextTop)
            .onTapGesture {
                let url = URL.init(string: destination)
                guard let destinationUrl = url else { return }
                UIApplication.shared.open(destinationUrl)
            }
    }
}

struct InformationView_Previews: PreviewProvider {
    static var previews: some View {
        InformationView()
    }
}