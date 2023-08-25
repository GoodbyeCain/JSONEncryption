//
//  Data+Ext.swift
//  JsonEncryption
//
//  Created by saycain on 2023/8/25.
//

import Foundation
import CryptoKit

public extension Data {
    
    init?(hexString: String) {
        let len = hexString.count / 2
        var data = Data(capacity: len)
        var i = hexString.startIndex
        for _ in 0..<len {
          let j = hexString.index(i, offsetBy: 2)
          let bytes = hexString[i..<j]
          if var num = UInt8(bytes, radix: 16) {
            data.append(&num, count: 1)
          } else {
            return nil
          }
          i = j
        }
        self = data
    }
    
    var hexadecimal: String {
      return map { String(format: "%02x", $0) }
          .joined()
    }
    
    func chaChaPolyEncrypt(keyStr: String) throws -> Data? {
        guard let keyData = Data(hexString:keyStr)  else { return nil }
        
        let key = SymmetricKey(data: keyData)
        let encryptedContent = try! ChaChaPoly.seal(self, using: key).combined
        return encryptedContent
    }
    
    
    func chaChaPolyDecrypt(keyStr: String) throws -> Data? {
        guard let keyData = Data(hexString:keyStr)  else { return nil }
        
        let key = SymmetricKey(data: keyData)
        let sealedBox = try! ChaChaPoly.SealedBox(combined: self)
        let decryptedData = try! ChaChaPoly.open(sealedBox, using: key)
        return decryptedData
    }

}
