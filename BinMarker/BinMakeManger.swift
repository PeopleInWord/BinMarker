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

}
