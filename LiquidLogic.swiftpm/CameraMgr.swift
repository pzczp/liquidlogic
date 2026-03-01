import AVFoundation
import Vision
import CoreGraphics

class HandTracker: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    static let shared = HandTracker()
    
    var indexTip: CGPoint?
    var middleTip: CGPoint?
    
    let session = AVCaptureSession() 
    private var isSetup = false
    
    func start() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            guard granted else { 
                print("Camera permission denied!")
                return 
            }
            DispatchQueue.global(qos: .userInitiated).async {
                self.setup()
                if !self.session.isRunning {
                    self.session.startRunning()
                }
            }
        }
    }
    
    func stop() {
        DispatchQueue.global(qos: .userInitiated).async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
    
    private func setup() {
        guard !isSetup else { return }
        isSetup = true
        
        session.beginConfiguration()
        
        // SAFE FALLBACK: Try front wide-angle, then back camera, then ANY video device.
        var videoDevice: AVCaptureDevice? = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        if videoDevice == nil { videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) }
        if videoDevice == nil { videoDevice = AVCaptureDevice.default(for: .video) }
        
        guard let finalDevice = videoDevice,
              let videoDeviceInput = try? AVCaptureDeviceInput(device: finalDevice) else {
            print("Failed to find a camera device.")
            session.commitConfiguration()
            return
        }
        
        if session.canAddInput(videoDeviceInput) { session.addInput(videoDeviceInput) }
        
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "visionQueue"))
        if session.canAddOutput(videoDataOutput) { session.addOutput(videoDataOutput) }
        
        session.commitConfiguration()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
        let request = VNDetectHumanHandPoseRequest { req, _ in
            guard let obs = req.results?.first as? VNHumanHandPoseObservation else {
                self.indexTip = nil
                self.middleTip = nil
                return
            }
            
            if let indexNode = try? obs.recognizedPoint(.indexTip),
               let middleNode = try? obs.recognizedPoint(.middleTip),
               indexNode.confidence > 0.3 && middleNode.confidence > 0.3 {
                // Flip X because the camera feed is usually mirrored
                self.indexTip = CGPoint(x: 1.0 - indexNode.location.x, y: indexNode.location.y)
                self.middleTip = CGPoint(x: 1.0 - middleNode.location.x, y: middleNode.location.y)
            } else {
                self.indexTip = nil
                self.middleTip = nil
            }
        }
        request.maximumHandCount = 1
        try? handler.perform([request])
    }
}
