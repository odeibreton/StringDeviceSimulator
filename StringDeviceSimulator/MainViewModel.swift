//
//  MainViewModel.swift
//  StringDeviceSimulator
//
//  Created by Odei Bretón on 06/04/2023.
//

import Foundation
import CoreBluetooth

class MainViewModel : NSObject, ObservableObject {
    @Published private(set) var blePeripheralState: String = "Unknown"
    @Published private(set) var isAdvertising: Bool = false
    @Published private(set) var subscribedToReadingsCharacteristic: Bool = false
    @Published private(set) var isRecording: Bool = false
    
    private let serviceId = CBUUID(string: "2cdaa35b-be1e-40d4-aba0-3add764a6a8b")
    private let readingsCharacteristicId = CBUUID(string: "85844cc1-2eac-4744-9b9d-462cfd8debd1")
    private let isRecordingCharacteristicId = CBUUID(string: "69872099-e938-4e1e-99c4-74afc913d553")
    
    private let readingsCharacteristic: CBMutableCharacteristic
    private let isRecordingCharacteristic: CBMutableCharacteristic
    
    private var rng = SystemRandomNumberGenerator()
    private let timer = RepeatingTimer(timeInterval: 0.01)
    
    private var peripheralManager: CBPeripheralManager!
    
    override init() {
        readingsCharacteristic = CBMutableCharacteristic(type: readingsCharacteristicId, properties: .notify, value: nil, permissions: .readable)
        isRecordingCharacteristic = CBMutableCharacteristic(type: isRecordingCharacteristicId, properties: .write, value: nil, permissions: .writeable)
        
        super.init()
        
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: DispatchQueue.main)
        
        timer.eventHandler = sendReading
    }
    
    func startAdvertising() {
        peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [serviceId]])
    }
    
    func stopAdvertising() {
        peripheralManager.stopAdvertising()
        isAdvertising = false
    }
    
    private func initialisePeripheralManager() {
        let service = CBMutableService(type: serviceId, primary: true)
        service.characteristics = [
            readingsCharacteristic,
            isRecordingCharacteristic
        ]
        
        self.peripheralManager.removeAllServices()
        self.peripheralManager.add(service)
    }
    
    private func sendReading() -> Void {
        let number = rng.next()
        
        let data = withUnsafeBytes(of: number) { Data($0) }
        
        peripheralManager.updateValue(data, for: readingsCharacteristic, onSubscribedCentrals: nil)
    }
}

extension MainViewModel : CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .unknown:
            blePeripheralState = "Unknown"
        case .resetting:
            blePeripheralState = "Resetting"
        case .unsupported:
            blePeripheralState = "Unsupported"
        case .unauthorized:
            blePeripheralState = "Unauthorized"
        case .poweredOff:
            blePeripheralState = "Powered off"
        case .poweredOn:
            blePeripheralState = "Powered on"
            initialisePeripheralManager()
        @unknown default:
            blePeripheralState = "Unknown"
        }
        
        print("New peripheral state: \(blePeripheralState)")
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        self.isAdvertising = peripheral.isAdvertising
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        if characteristic.uuid == readingsCharacteristicId {
            subscribedToReadingsCharacteristic = true
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        if characteristic.uuid == readingsCharacteristicId {
            subscribedToReadingsCharacteristic = false
            timer.suspend()
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
            if request.characteristic.uuid == isRecordingCharacteristicId {
                guard let value = request.value,
                      value.count == 1 else {
                    continue
                }
                
                let byte = value[0]
                
                switch byte {
                case 0:
                    isRecording = false
                    timer.suspend()
                case 1:
                    isRecording = true
                    timer.resume()
                default:
                    print("Unrecognised value received: \(byte)")
                }
            }
        }
    }
}
