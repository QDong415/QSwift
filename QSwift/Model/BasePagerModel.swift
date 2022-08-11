//
//  BaseResponse.swift
//  QSwift
//
//  Created by DongJin on 2021/3/28.
//

// 假设这是服务端返回的统一定义的response格式
class BasePagerModel<T: JsonModelProtocol>: JsonModelProtocol {
    
    var total: Int? // 一共有多少条数据
    var totalpage: Int? // 一共多少页
    var currentpage: Int? // 当前请求的是第几页
    var items: [T]? // 具体的data的格式和业务相关，故用泛型定义
    
    public required init() {}
    
    func hasMore() -> Bool {
        return totalpage ?? 0 > currentpage ?? 0;
    }

}
