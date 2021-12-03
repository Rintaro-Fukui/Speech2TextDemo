//
//  SpeechRecorder.swift
//  Speech_to_text_sample
//
//  Created by RintaroFukui on 2021/12/03.
//

import Foundation
import Combine
import AVFoundation
import Speech
 
final class SpeechRecorder: ObservableObject {
    @Published var audioText: String = ""
    @Published var audioRunning: Bool = false
    private var audioEngine = AVAudioEngine()
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    func toggleRecording(){
        if self.audioEngine.isRunning {
            self.stopRecording()
        }
        else{
            try! self.startRecording()
        }
    }
    
    func stopRecording(){
        self.recognitionTask?.cancel()
        self.recognitionTask?.finish()
        self.recognitionRequest?.endAudio()
        self.recognitionRequest = nil
        self.recognitionTask = nil
        self.audioEngine.stop()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playback)
            try audioSession.setMode(AVAudioSession.Mode.default)
        } catch{
            print("AVAudioSession error")
        }
        self.audioRunning = false
    }
    
    func startRecording() throws {
        self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0)
        self.recognitionTask = SFSpeechRecognitionTask()
        self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        if(self.recognitionTask == nil || self.recognitionRequest == nil){
            self.stopRecording()
            return
        }
        self.audioText = ""
        recognitionRequest?.shouldReportPartialResults = true
        if #available(iOS 13, *) {
            recognitionRequest?.requiresOnDeviceRecognition = false
        }
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest!) { result, error in
            if(error != nil){
                print (String(describing: error))
                self.stopRecording()
                return
            }
            var isFinal = false
            if let result = result {
                isFinal = result.isFinal
                self.audioText = result.bestTranscription.formattedString
                print(result.bestTranscription.formattedString)
            }
            if isFinal { //録音タイムリミット
                print("recording time limit")
                self.stopRecording()
                inputNode.removeTap(onBus: 0)
            }
        }
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        self.audioEngine.prepare()
        try self.audioEngine.start()
        self.audioRunning = true
    }
}
