//
//  ContentView.swift
//  Speech_to_text_sample
//
//  Created by RintaroFukui on 2021/12/03.
//

import SwiftUI
import Speech
import AVFoundation

struct ContentView: View {
    @ObservedObject private var speechRecorder = SpeechRecorder()
    @State var showingAlert = false
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading, spacing: 5) {
                HStack() {
                    Spacer()
                    Button(action: {
                        if(AVCaptureDevice.authorizationStatus(for: AVMediaType.audio) == .authorized &&
                            SFSpeechRecognizer.authorizationStatus() == .authorized){
                            self.showingAlert = false
                            self.speechRecorder.toggleRecording()
                            if !self.speechRecorder.audioRunning {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                    
                                }
                            }
                        }
                        else{
                            self.showingAlert = true
                        }
                    })
                    {
                        if !self.speechRecorder.audioRunning {
                            Text("Start")
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.blue, lineWidth: 1))
                        } else {
                            Text("Stop")
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.red, lineWidth: 1))
                        }
                    }
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("マイクの使用または音声の認識が許可されていません"))
                    }
                    Spacer()
                }
                Text(self.speechRecorder.audioText)
            }
            .onAppear{
                AVCaptureDevice.requestAccess(for: AVMediaType.audio) { granted in
                    OperationQueue.main.addOperation {
                        
                    }
                }
                SFSpeechRecognizer.requestAuthorization { status in
                    OperationQueue.main.addOperation {
                        //switch status {
                        //    case .authorized:
                        //
                        //    default:
                        //
                        //}
                    }
                }
            }
        }.padding(.vertical)
    }
}
 
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
