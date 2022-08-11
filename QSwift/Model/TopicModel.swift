//
//  UserSimpleModel.swift
//  QSwift
//
//  Created by QDong on 2021/3/28.
//

class TopicModel: JsonModelProtocol {
    
    var tid: Int64!
    var userid: Int64!
    var name: String!
    var avatar: String?
    var content: String?
    
    public required init() {}
}
