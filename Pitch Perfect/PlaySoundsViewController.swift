//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Khoa Vo on 8/3/15.
//  Copyright (c) 2015 AppSynth. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {
    
    var audioPlayer:AVAudioPlayer! // create global audioPlayer variable
    
    var audioPlayer2:AVAudioPlayer! // create global variable for second audioPlayer for echo playback
    
    var audioPlayer3:AVAudioPlayer! // create global variable for third audioPlayer for echo playback
    
    var receivedAudio:RecordedAudio! // create global variable for recorded audio data
    
    var audioEngine:AVAudioEngine! // create global AVAudioEngine variable
    
    var audioFile:AVAudioFile! // create global variable for AVAudioFile object
    
    var audioPlayerNode:AVAudioPlayerNode!
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        super.viewDidLoad()
        
        // Create instance of AVAudioPlayer using filepath
        audioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl, error: nil)
        audioPlayer.enableRate = true // enables playback rate adjustment
        audioPlayer.prepareToPlay()
        
        // Note: audioPlayers 2 and 3 are created to keep echo effects independent of audioPlayer to avoid playback conflicts:
        
        // Create instance of second AVAudioPlayer 
        audioPlayer2 = AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl, error: nil)
        audioPlayer2.prepareToPlay()
        
        // Create instance of third AVAudioPlayer
        audioPlayer3 = AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl, error: nil)
        audioPlayer3.prepareToPlay()
        
        // Create audio engine object
        audioEngine = AVAudioEngine()
        
        audioFile = AVAudioFile(forReading: receivedAudio.filePathUrl, error: nil) // Initialize AVAudioFile object using filepath of receivedAudio
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func slowAudio(sender: UIButton) {
        // play slow audio
        playAudio(0.5)
    }
    
    @IBAction func fastAudio(sender: UIButton) {
        // play fast audio 
        playAudio(2.0)
    }
    
    @IBAction func chipMunkAudio(sender: UIButton) {
        
        playAudioWithVariablePitch(1000)
    }
    
    @IBAction func darthVaderAudio(sender: UIButton) {
        playAudioWithVariablePitch(-1000)
    }
    
    func playAudioWithVariablePitch(pitch: Float) {
        
       stopSounds()
        
        // Create AVAudioPlayerNode object
        audioPlayerNode = AVAudioPlayerNode()
        
        // Attach AVAudioPlayerNode to AVAudioEngine
        audioEngine.attachNode(audioPlayerNode)
        
        // Create AVAudioUnitTimePitch
        var changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        
        // Attach AVAudioUnitTimePitch to AVAudioEngine
        audioEngine.attachNode(changePitchEffect)
        
        // Connect AVAudioPlayerNode to AVAudioUnitTimePitch
        audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
        
        // Connect AVAudioUnitTimePitch to Output
        audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)
        
        // Schedule playing of an audio file
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        
        // Start audio engine
        audioEngine.startAndReturnError(nil)
        
        // Play the audio
        audioPlayerNode.play()
    }
    
    func playAudio(rate:Float) {
        // Stop all sounds currently playing
        stopSounds()
        audioPlayer.rate = rate
        audioPlayer.play()
    }
    
    @IBAction func playEcho(sender: UIButton) {
        
        stopSounds()
        audioPlayer2.play() // play first audio player
        
        let delay:NSTimeInterval = 0.3 // 300 ms
        var playTime:NSTimeInterval
        // set audioPlayer3 to play at a 300 ms delay
        playTime = audioPlayer3.deviceCurrentTime + delay
        audioPlayer3.volume = 0.4;
        audioPlayer3.playAtTime(playTime)
    }
    
    @IBAction func playReverb(sender: UIButton) {
        
        stopSounds()
        
        // Create AVAudioPlayerNode object
        audioPlayerNode = AVAudioPlayerNode()
        
        // Attach AVAudioPlayerNode to AVAudioEngine
        audioEngine.attachNode(audioPlayerNode)
        
        // Create AVAudioUnitReverb
        var reverb = AVAudioUnitReverb()
        reverb.wetDryMix = 50
        
        // Attach AVAudioUnitReverb to AVAudioEngine
        audioEngine.attachNode(reverb)
        
        // Connect AVAudioPlayerNode to AVAudioUnitReverb
        audioEngine.connect(audioPlayerNode, to: reverb, format: nil)
        
        // Connect AVAudioUnitReverb to Output
        audioEngine.connect(reverb, to: audioEngine.outputNode, format: nil)
        
        // Schedule playing of an audio file
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        
        // Start audio engine
        audioEngine.startAndReturnError(nil)
        
        // Play the audio
        audioPlayerNode.play()

    }
    
    // Stop all sounds from playing
    func stopSounds() {
        
        audioPlayer.stop()
        audioPlayer.currentTime = 0 // resets playback to the beginning
        audioPlayer2.stop()
        audioPlayer2.currentTime = 0
        audioPlayer3.stop()
        audioPlayer3.currentTime = 0
        audioEngine.stop()
        audioEngine.reset()
    }
    
    @IBAction func stopAudio(sender: UIButton) {
        // Stops all audio
        stopSounds()
    }

}
