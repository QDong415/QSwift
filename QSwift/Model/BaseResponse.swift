//
//  BaseResponse.swift
//  QSwift
//
//  Created by QDong on 2021/3/28.
//

import HandyJSON

//使用别名，这样如果换成别的json解析库可以很容易更换
typealias JsonModelProtocol = HandyJSON

// 假设这是服务端返回的统一定义的response格式
class BaseResponse<T: HandyJSON>: JsonModelProtocol {
    
    var code: Int? // 服务端返回码
    var data: T? // 具体的data的格式和业务相关，故用泛型定义
    var message: String? // 服务端返回信息
    
    public required init() {}
    
    func isSuccess() -> Bool {
        return code == 1;
    }

}
