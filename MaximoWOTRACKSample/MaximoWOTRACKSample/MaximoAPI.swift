//
//  MaximoAPI.swift
//  MaximoWOTRACKSample
//
//  Created by Silvino Vieira de Vasconcelos Neto on 02/02/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation
import MaximoRESTSDK

public class MaximoAPI {
    private static var sharedMaximoAPI : MaximoAPI = {
        let maximoAPI = MaximoAPI()

        return maximoAPI
    }()

    var options: Options?
    var connector: MaximoConnector?
    var loggedUser: [String: Any] = [:]
    var workOrderSet: ResourceSet?

    private init() {
    }

    public class func shared() -> MaximoAPI {
        return sharedMaximoAPI
    }

    public func login(userName: String, password: String, host: String, port: Int) throws -> [String: Any] {
        options = Options().user(user: userName).password(password: password).auth(authMode: "maxauth")
        options = options!.host(host: host).port(port: port).lean(lean: true)
        connector = MaximoConnector(options: options!)
        try connector!.connect()

        let personSet = connector!.resourceSet(osName: "mxperson")
        _ = try personSet._where(whereClause: "spi:personid=\"" + userName.uppercased() + "\"").fetch()
        let person = try personSet.member(index: 0)
        loggedUser = try person!.toJSON()
        return loggedUser
    }

    public func listWorkOrders() throws -> [[String: Any]] {
        workOrderSet = connector!.resourceSet(osName: "mxwo")
        _ = workOrderSet!.pageSize(pageSize: 10)
        _ = workOrderSet!._where(whereClause: "spi:istask=0")
        _ = workOrderSet!.paging(type: true)
        _ = try workOrderSet!.fetch()

        let count = try workOrderSet!.count()
        var workOrders : [[String: Any]] = []
        for index in 0...count-1 {
            let resource = try workOrderSet!.member(index: index)
            workOrders.append(try resource!.toJSON())
        }

        return workOrders
    }

    public func nextWorkOrdersPage() throws -> [[String: Any]] {
        _ = try workOrderSet?.nextPage()
        let count = try workOrderSet!.count()
        var workOrders : [[String: Any]] = []
        for index in 0...count-1 {
            let resource = try workOrderSet!.member(index: index)
            workOrders.append(try resource!.toJSON())
        }
        
        return workOrders
    }

    public func previousWorkOrdersPage() throws -> [[String: Any]] {
        _ = try workOrderSet?.previousPage()
        let count = try workOrderSet!.count()
        var workOrders : [[String: Any]] = []
        for index in 0...count-1 {
            let resource = try workOrderSet!.member(index: index)
            workOrders.append(try resource!.toJSON())
        }
        
        return workOrders
    }
}
