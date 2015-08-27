//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Khoa Vo on 7/28/15.
//  Copyright (c) 2015 AppSynth. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var recordButton: UIButton!
  
    @IBOutlet weak var recordingLabel: UILabel!
    
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var pauseRecordButton: UIButton!
    
    var audioRecorder:AVAudioRecorder! // declare global variable for audioRecorder
    var recordedAudio:RecordedAudio! // create an instance of the RecordedAudio class
    
    var reset = UIImage(named: "Reset")
    var stop = UIImage(named: "Stop")
    
    var paused:Int! = 0 // initialize variable to toggle between recording/paused state
    var canSegue:Int! = 1
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Hide stop and pause buttons when app first appears
        stopButton.hidden = true
        pauseRecordButton.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Starts recording audio
    func startRecording() {
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String // returns a string containing the filepath of the Document directory
        
      
        let recordingName = "my_recording.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        
        // Setup audio session
        var session = AVAudioSession.sharedInstance()
        session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
        
        // Route audio playback through phone's loudspeaker
        session.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker, error: nil)
        
        
        // Initialize and prepare the recorder
        audioRecorder = AVAudioRecorder(URL: filePath, settings: nil, error: nil)
        audioRecorder.delegate = self // self refers to the RecordSoundsViewController. This makes the view controller the delegate of the audioRecorder object
        audioRecorder.meteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }

    @IBAction func recordAudio(sender: UIButton) {
        
        // Change text to recording state"
        recordingLabel.text = "recording..."
        
        // Disable record button
        recordButton.enabled = false
        
        // Show stop button
        stopButton.hidden = false
        
        // Show the pause recording button
        pauseRecordButton.hidden = false
        
        // Change stop button image back to stop
        stopButton.setImage(stop, forState: UIControlState.Normal)
        
        // Runs after paused button is pressed
        if paused == 1 {
            
            // Change stop button image back to stop
            stopButton.setImage(stop, forState: UIControlState.Normal)
            
            // Resumes recording
            audioRecorder.record()
            println("Recording resumed...")
            
            // Change paused state back to false
            paused = 0
            println("paused: " + String(paused))
            
            // Enable segue
            canSegue = 1
            println("canSegue: " + String(canSegue))
            
        // Record a new audio file if paused is 0
        } else {
            startRecording()
            println("Recording...")
            
            // Enable segue
            canSegue = 1
            println("canSegue: " + String(canSegue))
        }
    }
    
    // Run when audio has finished recording:
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        
        if (flag) { // only run if finished recording successfully
            
            // Save the recorded audio
            recordedAudio = RecordedAudio(filePathUrl: recorder.url, title: recorder.url.lastPathComponent!) // initialize RecordedAudio object
            recordedAudio.filePathUrl = recorder.url // assign filepath of recorded audio file
            recordedAudio.title = recorder.url.lastPathComponent // assign the name of the file in the last path
            
            println("Audio recorded successfully")
            
            // Enable perform segue only if recording is not paused
            if canSegue == 1 {
                
                // Move to the next scene (perform segue)
                self.performSegueWithIdentifier("stopRecording", sender: recordedAudio) // self refers to this view controller. The identifier is the name of the segue that will be performed. The sender is the object that initiates the segue.
            }
            
        } else {
            recordingLabel.text = "recording failed... try again"
            println("Recording was not successful.")
            recordButton.enabled = true
            stopButton.hidden = true
        }
    }
    
    // Passes recorded audio to PlaySoundsViewController (gets called just before a segue is performed)
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "stopRecording") {
            println("prepareForSegue called")
            
            // Define the destination view controller for the segue
            let playSoundsVC = segue.destinationViewController as! PlaySoundsViewController
            
            // Specify the sender as a RecordedAudio object
            let data = sender as! RecordedAudio
            
            // Pass the recorded audio to the PlaySoundsViewController
            playSoundsVC.receivedAudio = data
        }
    }

    @IBAction func stopRecording(sender: UIButton) {
        // Reset label to non-recording state
        recordingLabel.text = "tap mic to record"
            
        // Re-enable the record button
        recordButton.enabled = true
        
        // Hide the stop and pause buttons
        pauseRecordButton.hidden = true
        stopButton.hidden = true
        
        // Stop recording and save audio file
        audioRecorder.stop()
        println("Recording stopped")
        
        // Resets audio session
        var audioSession = AVAudioSession.sharedInstance() // accesses the shared audio session (AVAudioSession is a singleton object)
        audioSession.setActive(false, error: nil) // deactivates the audio session
        
        // Change paused state back to 0 so that when recording is paused, recorder can reset and record a new audio file
        paused = 0
        println("paused: " + String(paused))
    }
    
    @IBAction func pauseRecording(sender: UIButton) {
        
        // Pause recording
        audioRecorder.pause()
        println("Recording paused...")
        
        // Re-enable the record button 
        recordButton.enabled = true
        
        // Change recording label text 
        recordingLabel.text = "recording paused... tap mic to resume"
        
        // Change stop button image to reset
        stopButton.setImage(reset, forState: UIControlState.Normal)
        
        // Hide pause button 
        pauseRecordButton.hidden = true 
        
        // Change paused state to 1 so audio can resume recording instead of starting over
        paused = 1
        println("paused: " + String(paused))
        
        // Disable segue so that audio recorder can be reset
        canSegue = 0
        println("canSegue: " + String(canSegue))
    }
    
}

