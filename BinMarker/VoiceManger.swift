//
//  VoiceManger.swift
//  BinMarker
//
//  Created by 彭子上 on 2017/3/27.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

protocol VoiceDelegate : NSObjectProtocol {
    func voiceChange(_ volumeValue:Int32)
    func endOfSpeech()
    func onResults(_ results: String,_ resultArr:Array<String>)
}

class VoiceManger: NSObject,IFlySpeechRecognizerDelegate,IFlyPcmRecorderDelegate {
    
    
    weak var delegate:VoiceDelegate?
    static let shareInstance=VoiceManger()
    var volumeText = UILabel.init()
    var resultWord = ""
//    let IFLY_AUDIO_SOURCE_MIC = "1"
//    let IFLY_AUDIO_SOURCE_STREAM = "-1"
    var resultArr=Array<String>.init()
    let iFlySpeechRecognizer=IFlySpeechRecognizer.sharedInstance()
    let pcmRecorder=IFlyPcmRecorder.sharedInstance()
    
    
    override init() {
        super.init()

        IFlySetting.setLogFile(.LVL_ALL)
        IFlySetting.showLogcat(true)
        let cachePath=NSSearchPathForDirectoriesInDomains(.cachesDirectory,.userDomainMask, true).first
        IFlySetting.setLogFilePath(cachePath)

        IFlySpeechUtility.createUtility("appid=58d9cea5")
        
        
        iFlySpeechRecognizer?.setParameter("", forKey: IFlySpeechConstant.params())
        iFlySpeechRecognizer?.setParameter("iat", forKey: IFlySpeechConstant.ifly_DOMAIN())
        iFlySpeechRecognizer?.delegate=self
        
        if iFlySpeechRecognizer != nil {
            iFlySpeechRecognizer?.setParameter("30000", forKey: IFlySpeechConstant.speech_TIMEOUT())
            iFlySpeechRecognizer?.setParameter("3000", forKey: IFlySpeechConstant.vad_EOS())//后断点检测: 后端点静音检测时间,即用户停止说话多长时间内即认为不再输入,自动停止录音
            iFlySpeechRecognizer?.setParameter("3000", forKey: IFlySpeechConstant.vad_BOS())
            iFlySpeechRecognizer?.setParameter("20000", forKey: IFlySpeechConstant.net_TIMEOUT())//网络等待时间
            iFlySpeechRecognizer?.setParameter("16000", forKey: IFlySpeechConstant.sample_RATE())
            iFlySpeechRecognizer?.setParameter("zh_cn", forKey: IFlySpeechConstant.language())
            iFlySpeechRecognizer?.setParameter("0", forKey: IFlySpeechConstant.asr_PTT())//设置是否返回标点符号
            
        }
        
        pcmRecorder?.delegate=self
        pcmRecorder?.setSample("16000")
        pcmRecorder?.setSaveAudioPath(nil)

    }
    
    func onVolumeChanged(_ volume: Int32) {
        delegate?.voiceChange(volume)
    }
    
    
    func onError(_ errorCode: IFlySpeechError!) {
        
    }
    
    func onBeginOfSpeech() {
        
        
    }
    
    func onEndOfSpeech() {
        delegate?.endOfSpeech()
    }
    
    func onResults(_ results: [Any]!, isLast: Bool) {
        if results == nil {
            return
        }
        
        let resultDic=results[0] as! Dictionary<String,Any>
        let jsonString = resultDic.keys.first!
        let jsonData = jsonString.data(using: .utf8)
        let jsonResult = try! JSONSerialization.jsonObject(with: jsonData!, options: .mutableContainers) as! Dictionary<String, Any>
        let words=jsonResult["ws"] as! Array<Dictionary<String,Any>>
        
        for word in words {
            let tempArr1=word["cw"] as! Array<Dictionary<String,Any>>
            let singleWord = tempArr1[0]["w"] as! String
            resultArr.append(singleWord)
            resultWord += singleWord
        }
//        if isLast {
            delegate?.onResults(resultWord,resultArr)
//            resultWord=""
//        }
        
    }
    
    func startHanler() -> Void {
        resultArr.removeAll()
        iFlySpeechRecognizer?.setParameter("1", forKey: "audio_source")
        iFlySpeechRecognizer?.setParameter("json", forKey: IFlySpeechConstant.result_TYPE())
        iFlySpeechRecognizer?.setParameter("asr.pcm", forKey: IFlySpeechConstant.asr_AUDIO_PATH())
        let ret=iFlySpeechRecognizer?.startListening()
        resultWord=""
        if ret == false {
            print("启动识别服务失败，请稍后重试")
        }
        
    }
    
    func stopAndConfirm() -> [String?] {
        iFlySpeechRecognizer?.stopListening()
        return resultArr
    }
    
    
    func onIFlyRecorderError(_ recoder: IFlyPcmRecorder!, theError error: Int32) {
        print(error)
    }
    
    func onIFlyRecorderBuffer(_ buffer: UnsafeRawPointer!, bufferSize size: Int32) {
        print(size)
    }
}
