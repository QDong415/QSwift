//
//  HttpManager.swift
//  TSWeChat
//
//  Created by Hilen on 11/3/15.
//  Copyright © 2015 Hilen. All rights reserved.
//

import Alamofire

typealias ResponseSuccess<T: JsonModelProtocol> = (T) -> Void
typealias ResponseFail = (_ errorMessage: String) -> Void

class HttpManager: NSObject {
    
    static let shared: HttpManager  = HttpManager()
    
    //禁止别的地方初始化本类
    fileprivate override init() {
        super.init()
    }
    
    public func request<T: JsonModelProtocol>(_ method: HTTPMethod = .get, path: String!,
                            params: [String: String]?,
                            success: @escaping ResponseSuccess<T>,
                            failure: @escaping ResponseFail) {
        
        //header中拼接token
        var headersMap = [String : String]()
        headersMap["token"] = "xxxxx"
        let headers: HTTPHeaders = HTTPHeaders(headersMap)
        
        //拼接sign参数
//        params["sign"] = md5params(dict: params)
        
        //正式的调用AF发出网络请求
        executeRequest(method, path: path, headers: headers, params: params, success: success, failure: failure)
    }
    
    //正式的调用AF
    public func executeRequest<T: JsonModelProtocol>(_ method: HTTPMethod = .get, path: String!,
                            headers: HTTPHeaders? = nil,
                            params: [String: String]?,
                            success: @escaping ResponseSuccess<T>,
                            failure: @escaping ResponseFail) {
        
        let url: String = path.hasPrefix("http") ? path : (DOMAIN_API_URL + path)

        printLog(url)
        printLog(params)
        
        AF.request(url,
                   method: method,
                   parameters: params, encoder: URLEncodedFormParameterEncoder.default, headers: headers)
            .responseString { (response :AFDataResponse<String>) in
//                printLog(response.response?.statusCode)
                switch response.result {
                case .success(let successValue):
                    //服务器有响应
                    printLog(successValue)
                    if let jsonModel: T = T.deserialize(from: successValue) {
                        //json能解析成功
//                        if jsonModel as? BaseResponse {
//                            //是我们的类型，检查是否被踢出
//                            jsonModel.isKick()
//                        }
                        success(jsonModel)
                    } else {
                        //json解析失败
                        failure("json解析失败")
                    }
                case .failure(let errorValue):
                    //服务器未响应
                    printLog(errorValue)
                    failure("服务器未响应")
                }
            }
    }
}

extension HttpManager {
    
    private func md5params(dict: [String : String]) -> String! {

        let keyArray = dict.keys.sorted()
        var signString: String = String()
        
        for key: String in keyArray {
            signString.append(dict[key]!)
        }
        return signString.md5
    }

}


extension String {
    var md5:String {
        let utf8 = cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(utf8, CC_LONG(utf8!.count - 1), &digest)
        return digest.reduce("") { $0 + String(format:"%02x", $1) }
    }
}
