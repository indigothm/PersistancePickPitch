//
//  RecordSoundsViewController.swift
//  Pick Your Pitch
//
//  Created by Udacity on 1/5/15.
//  Copyright (c) 2014 Udacity. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var recordingInProgress: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    
    var audioRecorder:AVAudioRecorder!
    var recordedAudio:RecordedAudio!
    var shouldSegueToSoundPlayer = false
    
    func audioFileURL() ->  NSURL {
        let filename = "usersVoice.wav"
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
        let pathArray = [dirPath, filename]
        let fileURL =  NSURL.fileURLWithPathComponents(pathArray)!
        
        return fileURL
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if NSFileManager.defaultManager().fileExistsAtPath(audioFileURL().path!) {
            
            print("The file already exists!")
            
            let alert = UIAlertController(title: "Sounds file already exists", message: "Do you wish to record a new one?", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) in self.goToPlay()}))
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
            
        }
        
    }
    
    func goToPlay() {
        
        recordedAudio = RecordedAudio(filePathUrl: audioFileURL(), title: audioFileURL().lastPathComponent)
        self.performSegueWithIdentifier("stopRecording", sender: self)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        //Hide the stop button
        stopButton.hidden = true
        recordButton.enabled = true
    }

    @IBAction func recordAudio(sender: UIButton) {
        // Update the UI
        stopButton.hidden = false
        recordingInProgress.hidden = false
        recordButton.enabled = false
        
        // Setup audio session
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch _ {
        }
        
        // Create the path to the file.
        let fileURL =  audioFileURL()

        // Initialize and prepare the recorder
        do {
            try audioRecorder = AVAudioRecorder(URL: fileURL, settings: [String : AnyObject]())
        } catch _ {}

        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true;
        audioRecorder.prepareToRecord()

        audioRecorder.record()
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {

        if flag {
            recordedAudio = RecordedAudio(filePathUrl: recorder.url, title: recorder.url.pathExtension)
            self.performSegueWithIdentifier("stopRecording", sender: self)
        } else {
            print("Recording was not successful")
            recordButton.enabled = true
            stopButton.hidden = true
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "stopRecording" {
            let playSoundsVC:PlaySoundsViewController = segue.destinationViewController as! PlaySoundsViewController
            let data = recordedAudio
            playSoundsVC.receivedAudio = data
        }
    }
    
    @IBAction func stopAudio(sender: UIButton) {
        recordingInProgress.hidden = true
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance();
        do {
            try audioSession.setActive(false)
        } catch _ {
        }
        
        // This function stops the audio. We will then wait to hear back from the recorder, 
        // through the audioRecorderDidFinishRecording method
    }
}

