//
//  BinMakeManger.swift
//  BinMarker
//
//  Created by 彭子上 on 2017/1/11.
//  Copyright © 2017年 彭子上. All rights reserved.
//



import UIKit

enum BinPostion:UInt64 {
    case One
    case Two
    case Three
    case Four
}

enum DeviceType:UInt64 {
    case TV     = 5
    case DVD    = 6
    case AMP    = 7
    case BOX    = 8
}

class BinMakeManger: NSObject {
    
    static let shareInstance=BinMakeManger()
    var templatePath=String.init()
    override init() {
        super.init()
        templatePath=self.copyNewData(with: "P14AAA_0A");//目标模板8k文件,需要反复修改
    }
    
    func makeType(with deviceArray:Array<Dictionary <String,Any>>) -> String {
        for deviceInfo in deviceArray {
            let binName:String=deviceInfo["codeString"] as! String
            if (Bundle.main.path(forResource: binName, ofType: "bin") != nil) {
                let postionNum:NSNumber=deviceInfo["index"] as! NSNumber
                let postion = BinPostion(rawValue: postionNum.uint64Value)
                let sourcePath=Bundle.main.path(forResource: binName, ofType: "bin")
                self.pushBin(with: sourcePath!, into: postion!)
            }
        }
        return self.pushIntoTotalData(templatePath)
    }
    
    private func resourceName(_ Postion:BinPostion) -> String
    {
        switch Postion {
        case .One:
            return "T32DBA_40EF"
        case .Two:
            return "P14AAA_03"
        case .Three:
            return "T32DBA_08FE"
        case .Four:
            return "P14AAA_16"
        }
    }
    
    func pushBin(with sourcePath:String,into postion:BinPostion) -> Void {
        let sourceHandle=FileHandle.init(forReadingAtPath: sourcePath)
        sourceHandle?.seek(toFileOffset: (postion.rawValue)*0x800)
        let sourceData1 = sourceHandle?.readData(ofLength: 0x800)
        sourceHandle?.closeFile()
        
        let targetHandle=FileHandle.init(forWritingAtPath: templatePath)
        targetHandle?.seek(toFileOffset: (postion.rawValue)*0x800)
        targetHandle?.write(sourceData1!)
        targetHandle?.closeFile()
    }
    func copyNewData(with sourceName:String) -> String {//转化成文件
        let sourcePath=Bundle.main.path(forResource: sourceName, ofType: "bin")
        let sourceData=NSData.init(contentsOfFile: sourcePath!)
        
        let paths=NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path=paths[0]
        let targetPath = path + "/" + sourceName + ".bin"
        
        let manger=FileManager.default
        if manger.createFile(atPath: targetPath, contents: nil, attributes: nil) {
            let handle=FileHandle.init(forWritingAtPath: targetPath)
            handle?.write(Data.init(referencing: sourceData!))
            handle?.closeFile()
            return targetPath
        }
        else
        {
            return ""
        }
    }
    
    func pushIntoTotalData(_ sourcePath:String) -> String {
        var targetHandle=FileHandle.init(forReadingAtPath: sourcePath)//待写入的文件
        let sourceData2Total=targetHandle?.readDataToEndOfFile()//待写入的文件
        targetHandle?.closeFile()
        let totalDataPath=self.copyNewData(with: "Ir_Remote_ImageB");
        targetHandle=FileHandle.init(forWritingAtPath: totalDataPath)
        targetHandle?.seek(toFileOffset: 0x4800)
        targetHandle?.write(sourceData2Total!)
        targetHandle?.closeFile()
        return totalDataPath;
    }
    
//    频道参数内容： 设备号、码组号、频道值（例如： 12频道，则频道值为 0x00 0x12）
//    数据协议：长度10字节
//    格式：0xFE,0xA1,设备号（1），码组号（2），频道值（2），NOP(2)校验(1)
//    说明：0xA1 为频道功能标志，设备号1个字节，码组号 2个字节，频道值 2个字节，NOP表示0x00。

    func channelCommand(_ code:String ,_ channel:Int ,_ deviceType:Int) ->String{
        let deviceTypeStr:String={
            let temp:String=(deviceType+5).description
            return temp.full(withLengthCount: 3)
        }()
        let channelStr:String={
            let HighBit:Int=channel/100
            let LowBit:Int=channel%100
            let High16BitValue:String = (HighBit/100*16*16+HighBit%100/10*16+HighBit%10).description
            let Low16BitValue:String = (LowBit/100*16*16+LowBit%100/10*16+LowBit%10).description
            //化16进制
            return High16BitValue.full(withLengthCount: 3) + Low16BitValue.full(withLengthCount: 3)
        }()
        let codeStr:String={
            return String.divideCode(code)
        }()
        return "254161" + deviceTypeStr + codeStr + channelStr + "000000"
//        1.加入国内数据库
//        2.修复频道命令
    }
    
//    发码通讯协议（与红外伴侣相同）
//    通讯协议： 10字长度
//    起始标志 设备号    码组号    按键值    备用字节      校验
//    FEH,    05H,    00H,01H, 01H,  00H,00H,00H,00H,  05H
//    注： 各设备为： 电视机(05), DVD(06), 功放(07), 机顶盒(08)
//    校验为：第二个字节到第九个字节的异或和。
    
    func singleCommand(_ code:String,_ btnTag:Int ,_ deviceType:Int) ->String{
        let deviceTypeStr:String={
            let temp:String=(deviceType+5).description
            return temp.full(withLengthCount: 3)
            
        }()
        let btnTagStr:String={
            let temp:String=(btnTag-100).description
            return temp.full(withLengthCount: 3)
        }()
        
        let codeStr:String={
            return String.divideCode(code)
        }()
        return "254"+deviceTypeStr+codeStr+btnTagStr+"000000000000"
    }
    
//    查找遥控器
//    数据协议：长度 10字节
//    0xFE,0xA2,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xA2
    func foundCommand ()->String{
        return "254162000000000000000000000162"
    }

}
