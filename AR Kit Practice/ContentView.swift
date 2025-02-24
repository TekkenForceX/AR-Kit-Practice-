//
//  ContentView.swift
//  AR Kit Practice
//
//  Created by Matthew Fails on 12/17/24.
//

import SwiftUI
import RealityKit
import ARKit

// Custom AR Session
class CustomARSession: NSObject, ARSessionDelegate {
    private let session = ARSession()
    private var arView: ARView?
    private let cloudKitManager = CloudKitManager()
    
    override init() {
        super.init()
        session.delegate = self
    }
    
    func configureARView(with arView: ARView) {
        self.arView = arView
        arView.session = session
        
        // Configure AR session
        let config = ARWorldTrackingConfiguration()
        session.run(config)
    }
    
    func placeUSDZInFrontOfCamera() {
        guard let frame = session.currentFrame else {
            print("Unable to get the current ARFrame")
            return
        }
        
        // Get the camera's transform
        let cameraTransform = frame.camera.transform // A component that defines the scale, rotation, and translation of an entity
        
        // Calculate position 0.5 meters in front of the camera
        let distance: Float = 0.5
        // SIMD(Single Instruction, Multiple Data) Very useful for image processing & 3D graphics //
        let forward = normalize(SIMD3<Float>(-cameraTransform.columns.2.x,
                                             -cameraTransform.columns.2.y,
                                             -cameraTransform.columns.2.z))
        let positionInFrontOfCamera = SIMD3<Float>(cameraTransform.columns.3.x,
                                    cameraTransform.columns.3.y,
                                    cameraTransform.columns.3.z) + forward * distance
        
        // Create an anchor at this position
        let anchor = AnchorEntity(world: positionInFrontOfCamera)
        arView?.scene.addAnchor(anchor)
        
        // Load the USDZ model and attach it to the anchor
        do {
            let modelEntity = try Entity.load(named: "FeedBack Now") // Input Entity
            modelEntity.scale = SIMD3<Float>(1, 1, 1) // Adjust scale as needed for the size of the entity
            
            // Ensure the model is facing the camera but remains upright
            modelEntity.look(at: positionInFrontOfCamera, from: anchor.position, relativeTo: nil)
                       
            
            anchor.addChild(modelEntity)
        } catch {
            print("Failed to load USDZ model: \(error)")
        }
    }
}

// ARView Container for SwiftUI
struct ARViewContainer: UIViewRepresentable {
    let customARSession = CustomARSession()
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        customARSession.configureARView(with: arView)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    // Function to place a USDZ model in front of the camera
    func placeUSDZModelInFrontOfCamera() {
        customARSession.placeUSDZInFrontOfCamera()
    }
}

// ContentView
struct ContentView: View {
    let arViewContainer = ARViewContainer()
    
    var body: some View {
        ZStack {
            // ARView container
            arViewContainer
                .edgesIgnoringSafeArea(.all)
            
            // Button to place the model in front of the camera
            VStack {
                Spacer()
                Button(action: {
                    arViewContainer.placeUSDZModelInFrontOfCamera()
                }) {
                    Text("Place Model in Front of Camera")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding()
            }
        }
    }
}

// simd_float4x4 Extension
extension simd_float4x4 {
    var translation: SIMD3<Float> {
        return SIMD3(x: columns.3.x, y: columns.3.y, z: columns.3.z)
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
