//
//  ContentView.swift
//  StringDeviceSimulator
//
//  Created by Odei Bretón on 06/04/2023.
//

import SwiftUI
import CoreBluetooth

struct ContentView: View {
    
    @StateObject var viewModel = MainViewModel()
    
    var body: some View {
        VStack {
            HStack {
                Text("Peripheral manager state:")
                Text(viewModel.blePeripheralState)
                    .bold()
            }
            
            HStack {
                Text("Is peripheral advertising:")
                Text(String(viewModel.isAdvertising))
                    .bold()
            }
            
            HStack {
                Text("Subscribed to readings characteristic:")
                Text(String(viewModel.subscribedToReadingsCharacteristic))
                    .bold()
            }
            
            HStack {
                Text("Is recording:")
                Text(String(viewModel.isRecording))
                    .bold()
            }
            
            if viewModel.isAdvertising {
                Button("Stop advertising") {
                    viewModel.stopAdvertising()
                }
            } else {
                Button("Start advertising") {
                    viewModel.startAdvertising()
                }
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
