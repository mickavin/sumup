// RNSumUp.swift

import Foundation;
import SumUpSDK;

@objc(RNSumUp)
class RNSumUp: NSObject {

    @objc
    static func requiresMainQueueSetup() -> Bool {
        return true
    }



    @objc
    func setup(_ key: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        let setupResponse = SumUpSDK.setup(withAPIKey: key)
        if setupResponse {
            resolve(nil)
        } else {
            reject("000", "It was not possible to complete setup with SumUp SDK. Please, check your implementation.", nil)
        }
    }

    @objc
    func authenticate(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            let rootViewController = UIApplication.shared.delegate?.window??.rootViewController
            SumUpSDK.presentLogin(from: rootViewController!, animated: true) { success, error in
                if let error = error {
                    rootViewController?.dismiss(animated: true, completion: nil)
                    reject("000", "It was not possible to auth with SumUp. Please, check the username and password provided.", error)
                } else {
                    let merchantInfo = SumUpSDK.currentMerchant
                    let merchantCode = merchantInfo?.merchantCode
                    let currencyCode = merchantInfo?.currencyCode
                    resolve(["success": success, "userAdditionalInfo": ["merchantCode": merchantCode, "currencyCode": currencyCode]])
                }
            }
        }
    }

    @objc
    func authenticateWithToken(_ token: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        if SumUpSDK.isLoggedIn {
            resolve(nil)
        } else {
            SumUpSDK.login(withToken: token) { success, error in
                if !success {
                    reject("004", "It was not possible to login with SumUp using a token. Please, try again.", nil)
                } else {
                    resolve(nil)
                }
            }
        }
    }

    @objc
    func logout(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        SumUpSDK.logout { success, error in
            if !success {
                reject("004", "It was not possible to log out with SumUp. Please, try again.", nil)
            } else {
                resolve(nil)
            }
        }
    }

    @objc
    func prepareForCheckout(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        if SumUpSDK.isLoggedIn {
            SumUpSDK.prepareForCheckout()
            resolve(nil)
        } else {
            reject("003", "It was not possible to prepare for checkout. Please, log in first.", nil)
        }
    }

    @objc
    func checkout(_ request: [String: Any], resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        let total = NSDecimalNumber(string: request["totalAmount"] as? String)
        let title = request["title"] as? String
      let currencyCode = (request["currencyCode"] as? String)!
      let paymentOption = PaymentOptions(rawValue: RCTConvert2.uint(request["paymentOption"])!)
        let skipScreen = SkipScreenOptions.success
        let foreignTransactionID = request["foreignTransactionId"] as? String

        let checkoutRequest = CheckoutRequest(total: total, title: title, currencyCode: currencyCode, paymentOptions: paymentOption)
        checkoutRequest.foreignTransactionID = foreignTransactionID
        checkoutRequest.skipScreenOptions = skipScreen

        DispatchQueue.main.async {
            let rootViewController = UIApplication.shared.delegate?.window??.rootViewController
            SumUpSDK.checkout(with: checkoutRequest, from: rootViewController!) { result, error in
                if let error = error {
                    reject("001", "It was not possible to perform checkout with SumUp. Please, try again.", error)
                } else {
                    let additionalInformation = result?.additionalInfo
                    if additionalInformation == nil {
                        reject("001", "It was not possible to perform checkout with SumUp. Please, try again.", error)
                    } else {
                        let cardType = additionalInformation?["card.type"] as? String
                        let cardLast4Digits = additionalInformation?["card.last_4_digits"] as? String
                        let installments = additionalInformation?["installments"] as? String

                        resolve(["success": result?.success, "transactionCode": result?.transactionCode, "additionalInfo": ["cardType": cardType, "cardLast4Digits": cardLast4Digits, "installments": installments]])
                    }
                }
            }
        }
    }

    @objc
    func preferences(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            let rootViewController = UIApplication.shared.delegate?.window??.rootViewController
            SumUpSDK.presentCheckoutPreferences(from: rootViewController!, animated: true) { success, error in
                if success {
                    resolve(nil)
                } else {
                    reject("002", "It was not possible to open Preferences window. Please, try again.", nil)
                }
            }
        }
    }

    @objc
    func isLoggedIn(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        let isLoggedIn = SumUpSDK.isLoggedIn
        resolve(["isLoggedIn": isLoggedIn])
    }
}

@objc(RCTConvert2)
class RCTConvert2: NSObject {

    @objc
    static func SMPPaymentOptions(_ json: Any) -> PaymentOptions {
        if let string = json as? String {
            switch string {
            case "SMPPaymentOptionAny":
                return []
            case "SMPPaymentOptionCardReader":
                return .cardReader
            case "SMPPaymentOptionMobilePayment":
                return .mobilePayment
            default:
                return []
            }
        }
        return []
    }

    @objc
    static func SMPSkipScreenOptions(_ json: Any) -> SkipScreenOptions {
        if let string = json as? String {
            switch string {
            case "1":
                return .success
            default:
                return .success
            }
        }
        return .success
    }
  
  static func uint(_ json: Any) -> UInt? {
      if let intValue = json as? Int {
          return UInt(intValue)
      } else if let doubleValue = json as? Double {
          return UInt(doubleValue)
      } else if let stringValue = json as? String, let uintValue = UInt(stringValue) {
          return uintValue
      }
      return nil
  }
}

extension Dictionary where Key == String {
    func objectForKeyNotNull(_ key: String) -> Any? {
        let object = self[key]
        return (object is NSNull) ? nil : object
    }
}
