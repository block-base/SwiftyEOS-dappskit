//
//  main.swift
//  EOS
//
//  Created by Taiju Sanagi on 2018/11/17.
//  Copyright © 2018 BlockBase. All rights reserved.
//

import Foundation

print("Hello, EOS!")

//Generate PrivateKey
let (pk, pub, mn) = generateRandomKeyPair(enclave: .Secp256k1)
print("private key: \(pk!.rawPrivateKey())")
print("public key : \(pub!.rawPublicKey())")
print("mnemonic : \(mn ?? "")")

//Import Key
let myAccount = "ookimakitest"  //account
let privateKey = ""             //wif

let importedPk = try PrivateKey(keyString: privateKey)
let importedPub = PublicKey(privateKey: importedPk!)

//Transfer method can use thi
var transfer = Transfer()
transfer.from = myAccount
transfer.to = "daidaides123"
transfer.quantity = "1.0000 EOS"
transfer.memo = "todoke!!"

//Tipping
Currency.transferCurrency(transfer: transfer, code: "eosio.token", privateKey: importedPk!, completion: { (result, error) in
    if error != nil {
        if error is RPCErrorResponse {
            print("\((error as! RPCErrorResponse).errorDescription())")
        } else {
            print("other error: \(String(describing: error?.localizedDescription))")
        }
    } else {
        print("done.")
    }
})

//Get table row
let decoder = JSONDecoder();
EOSRPC.sharedInstance.getTableRows(scope: "daidaides123", code: "daidaides123", table: "memov1", completion:
    {(result: TableRowResponse<AnyCodable>? ,error: Error?) in
    let data = try! JSONEncoder().encode(result)
    let json = String(data: data, encoding: .utf8)!
    print(json)
})

//Transaction call
let content = "QmTPWPuYVjsB4P4QcVANn8Kt8jpEV6wc1os9DWA6pAsxsn"
let account = "ookimakitest"

let data = "{\"username\":\"" + account  + "\", \"content\":\"" + content + "\"}"
let abi = try! AbiJson(code: "daidaides123", action: "addmemo", json: data)

TransactionUtil.pushTransaction(abi: abi, account: account, privateKey: importedPk!, completion: { (result, error) in
        if error != nil {
        if (error! as NSError).code == RPCErrorResponse.ErrorCode {
        print("\(((error! as NSError).userInfo[RPCErrorResponse.ErrorKey] as! RPCErrorResponse).errorDescription())")
        } else {
        print("other error: \(String(describing: error?.localizedDescription))")
        }
        } else {
        print("Ok. Txid: \(result!.transactionId)")
        }
})


RunLoop.main.run()
