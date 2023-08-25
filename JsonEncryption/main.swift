//
//  main.swift
//  JsonEncryption
//
//  Created by saycain on 2023/8/25.
//

import Foundation
import CryptoKit

enum EncryptionMethod: String {
    case encrypt = "e"
    case decrypt = "d"
}

func main() {
    let arguments = CommandLine.arguments
    if arguments.count < 3 {
        print("Failed: Arguments count not right, \(arguments)")
        return
    }
    
    let encryptPath = arguments[2]
    guard let type: EncryptionMethod = EncryptionMethod(rawValue: arguments[1]),
          let keyStr = ProcessInfo.processInfo.environment["CHACHAPOLY_KEY"]  else {
        print("Failed: EncryptionMethod, e => encrypt, d => decrypt")
        return
    }
    
    if keyStr.count != 64 {
        print("Failed: CHACHAPOLY_KEY length != 64")
    }
    
    let fileManager = FileManager.default
    let inputPath = arguments[3]
    let inputURL = URL(filePath: inputPath)
    if type == .encrypt {
        
        if fileManager.fileExists(atPath: inputPath) {
            do {
                let data = try Data(contentsOf: inputURL)
                let encrypted = try data.chaChaPolyEncrypt(keyStr: keyStr)!
                try encrypted.write(to: URL(filePath: encryptPath))
            } catch {
                print(error)
            }
        } else {
            print("Failed: original file not exist, \(inputPath)")
        }
    } else {
        if fileManager.fileExists(atPath: encryptPath) {
            do {
                let encryptedData = try Data(contentsOf: URL(filePath: encryptPath))
                guard let decryptedData = try encryptedData.chaChaPolyDecrypt(keyStr: keyStr) else {
                    print("Failed: decrypted failed, \(encryptPath)")
                    return
                }
       
                try decryptedData.write(to: inputURL)
            } catch {
                print(error)
            }
        } else {
            print("Failed: encrypt file not exist, \(encryptPath)")
        }
    }
}

main()


