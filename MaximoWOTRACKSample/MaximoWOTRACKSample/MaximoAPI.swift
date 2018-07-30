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
    var siteID : String = ""
    var orgID : String = ""

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
        
        if let lID = loggedUser["locationsite"] {
            siteID = lID as! String;
        }
        
        if let lID = loggedUser["locationsite"] {
            orgID = lID as! String
        }
        return loggedUser
    }

    public func listWorkOrders() throws -> [[String: Any]] {
        workOrderSet = connector!.resourceSet(osName: "mxwo")
        _ = workOrderSet!.pageSize(pageSize: 10)
        _ = workOrderSet!._where(whereClause:
            "spi:istask=0 and spi:status=\"WAPPR\"")
        _ = workOrderSet!.paging(type: true)
        _ = try workOrderSet!.fetch()

        let count = try workOrderSet!.count()
        var workOrders : [[String: Any]] = []
        if (count > 0) {
            for index in 0...count-1 {
                let resource = try workOrderSet!.member(index: index)
                workOrders.append(try resource!.toJSON())
            }
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

    public func updateWorkOrder(workOrder: [String: Any]) throws {
        let uri = connector!.getCurrentURI() + "/os/mxwo/" + String(workOrder["workorderid"] as! Int)
        _ = try connector!.update(uri: uri, jo: workOrder, properties: nil)
    }

    public func deleteWorkOrder(workOrder: [String: Any]) throws {
        let uri = connector!.getCurrentURI() + "/os/mxwo/" + String(workOrder["workorderid"] as! Int)
        _ = try connector!.delete(uri: uri)
    }

    public func createWorkOrder(workOrder: [String: Any]) throws {
        let uri = connector!.getCurrentURI() + "/os/mxwo"
        _ = try connector!.create(uri: uri, jo: workOrder, properties: nil)
    }

    public func listWorkOrderStatuses() throws -> [[String: Any]] {
        let statusSet = connector?.resourceSet(osName: "mxdomain")
        var resultList : [[String: Any]] = []
        _ = statusSet!._where(whereClause: "spi:domainid=\"WOSTATUS\"")
        _ = try statusSet!.fetch()
        if let woStatusDomain = try statusSet!.member(index: 0) {
            var woStatusJSON = try woStatusDomain.toJSON()
            var values : [Any] = woStatusJSON["synonymdomain"] as! [Any]
            var i = 0
            while (i < values.count) {
                let domainValue : [String: Any] = values[i] as! [String : Any]
                if (domainValue["defaults"] as! Int) == 1 {
                    resultList.append(domainValue)
                }
                i += 1
            }
        }
        return resultList
    }
}
