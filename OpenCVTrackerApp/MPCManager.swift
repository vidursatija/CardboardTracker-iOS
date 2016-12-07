//
//  MPCManager.swift
//  OpenCVTrackerApp
//
//  Created by Vidur Satija on 15/10/16.
//  Copyright © 2016 Aromatic Studios. All rights reserved.
//
import MultipeerConnectivity

protocol MPCManagerDelegate {
    //func foundPeer()
    
    //func lostPeer()
    
    func invitationWasReceived(_ fromPeer: String)
    
    func connectedWithPeer(_ peerID: MCPeerID)
}

class MPCManager: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {
    
    var delegate: MPCManagerDelegate?
    
    
    var session: MCSession!
    
    var peer: MCPeerID!
    
    var browser: MCNearbyServiceBrowser!
    
    var advertiser: MCNearbyServiceAdvertiser!
    
    var foundPeers = [MCPeerID]()
    
    var invitationHandler: ((Bool, MCSession)->Void)!
    
    override init() {
        super.init()
        
        peer = MCPeerID(displayName: "CAMERA")
        
        session = MCSession(peer: peer, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: "opencv-track")
        browser.delegate = self
        
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: "opencv-track")
        advertiser.delegate = self
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        
        foundPeers.append(peerID)
        
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print(error.localizedDescription)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        for (index, aPeer) in foundPeers.enumerated(){
            if aPeer == peerID {
                foundPeers.remove(at: index)
                break
            }
        }
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print(error.localizedDescription)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        self.invitationHandler = invitationHandler
        
        delegate?.invitationWasReceived(peerID.displayName)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state{
        case MCSessionState.connected:
            print("Connected to session: \(session)")
            delegate?.connectedWithPeer(peerID)
            
        case MCSessionState.connecting:
            print("Connecting to session: \(session)")
            
        default:
            print("Did not connect to session: \(session)")
        }
    }
    
    func sendData(dictionaryWithData dictionary: Dictionary<String, String>, toPeer targetPeer: MCPeerID) -> Bool {
        let dataToSend = NSKeyedArchiver.archivedData(withRootObject: dictionary)
        let peersArray = NSArray(object: targetPeer)
        
        do{
            try session.send(dataToSend, toPeers: peersArray as! [MCPeerID], with: MCSessionSendDataMode.reliable)
        }catch _{
            return false
        }
        
        
        return true
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let dataDictionary = NSKeyedUnarchiver.unarchiveObject(with: data) as! Dictionary<String, String>
        
        print(dataDictionary["message"])
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) { }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) { }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) { }
    
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }

}
