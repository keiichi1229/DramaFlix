//
//  DramaDataModel.swift
//  DramaDemo
//
//  Created by Raymondting on 2020/6/30.
//  Copyright © 2020 Raymondting. All rights reserved.
//

import Foundation
import UIKit
import Network

struct DramaData : Codable, Equatable
{
    let dramaID : Int?
    let dramaName : String?
    let dramaViewer : Int?
    let dramaImgURL : String?
    
    static func == (lhs: DramaData, rhs: DramaData) -> Bool
    {
        return lhs.dramaID == rhs.dramaID && lhs.dramaName == rhs.dramaName && lhs.dramaViewer == rhs.dramaViewer && lhs.dramaImgURL == rhs.dramaImgURL && lhs._dramaCreateDate == rhs._dramaCreateDate && lhs.dramaRating == rhs.dramaRating
    }
    
    private var _dramaCreateDate: String?
    var dramaCreateDate : String
    {
        get
        {
            guard _dramaCreateDate != nil else
            {
                return ""
            }
            
            let dateFormatterGet = DateFormatter()
            //sample: 2017-11-23T02:04:39.000Z
            dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "yyyy-MM-dd"
            
            if let date = dateFormatterGet.date(from: _dramaCreateDate ?? "")
            {
                return dateFormatterPrint.string(from: date)
            }
            else
            {
               return ""
            }
        }
        set
        {
            return _dramaCreateDate = newValue
        }
    }
    
    private var _dramaRating: Double?
    var dramaRating : Double?
    {
        get
        {
            guard _dramaRating != nil else
            {
                return 0
            }
            
            return _dramaRating?.rounding(toDecimal: 1)
        }
        set
        {
            _dramaRating = newValue
        }
    }
    
    enum CodingKeys : String, CodingKey
    {
        case dramaID = "drama_id"
        case dramaName = "name"
        case dramaViewer = "total_views"
        case dramaImgURL = "thumb"
        case _dramaCreateDate = "created_at"
        case _dramaRating = "rating"
    }
}

enum DramaDataMgrStatus : Error
{
    case FailedToLoadData
    case NetworkFail
    case NetworkResume
}

final class DramaDataMgr
{
    static let shared = DramaDataMgr()
    
    // NOTE:: Test it on real device for this to work. Testing on simulator will get a half-baked result.
    private let netwrokMonitor = NWPathMonitor()
    
    private let queryDramaDataUrl: String = "https://static.linetv.tw/interview/dramas-sample.json"
    private let dramaListCacheFileName: String = "demoList.json"
    
    let dataSerialQueue = DispatchQueue(label: "dramaDataSerial")
    
    var updateUIHandler : (() -> Void)?
    var statusHandler : ((DramaDataMgrStatus) -> Void)?
    
    private var dataIsSearching = false
    
    private init()
    {
        netwrokMonitor.pathUpdateHandler = {(path) in
            if path.status == .satisfied
            {
                //print("Connect Success")
                self.statusHandler?(DramaDataMgrStatus.NetworkResume)
            }
            else
            {
                //print("Connect Fail")
                self.statusHandler?(DramaDataMgrStatus.NetworkFail)
            }
        }

        let networkQueue = DispatchQueue(label: "NetworkStatus")
        netwrokMonitor.start(queue: networkQueue)
        
    }
    
    private var dramas = [DramaData]()
    {
        didSet
        {
            self.updateUIHandler?()
            self.loadListImage(dramas: self.dramas)
        }
    }
    
    var documentsFolder : URL
    {
        return FileManager.default.urls(for: .documentDirectory,
                                        in: .allDomainsMask).first!
    }
    
    private func saveCacheDramaList(dramaList: [DramaData]) throws
    {
        let dramaData = try JSONEncoder().encode(dramaList)
        let fileName = dramaListCacheFileName
        let destinationURL = self.documentsFolder.appendingPathComponent(fileName)
        
        try dramaData.write(to: destinationURL)
    }
    
    private func loadCacheDramaList() -> [DramaData]?
    {
        let dataFileName = dramaListCacheFileName
        let dataURL = self.documentsFolder.appendingPathComponent(dataFileName)
        
        // Attempt to load the data in this file
        if let data = try? Data(contentsOf: dataURL),
           let dramaList = try? JSONDecoder().decode([DramaData].self, from: data)
        {
            return dramaList
        }
        else
        {
            return nil
        }
    }
    
    func loadDramaData() -> Void
    {
        // check cache data if exist
        if let cacheData = loadCacheDramaList()
        {
            dataSerialQueue.sync {
                self.dramas = cacheData
            }
        }
        
        refreshDramaData()
    }
    
    func refreshDramaData()
    {
        // drama data query
        refreshData(fromLink: self.queryDramaDataUrl)
    }
    
    internal func refreshData(fromLink link: String)
    {
        HttpMgr.shared.doHttpRequest(withURL: link, completeHandler: {
            (data, resp, error) in
            if error == nil
            {
                do
                {
                    let dramaData = try JSONDecoder().decode([String : [DramaData]].self, from: data!)
                    
                    let dramaList = dramaData["data"] ?? []
                    // compare with cache
                    let cacheDramaList = self.loadCacheDramaList()
                    guard cacheDramaList != nil else {
                        do
                        {
                            try self.saveCacheDramaList(dramaList: dramaList)
                            
                            if !self.dataIsSearching
                            {
                                self.dataSerialQueue.sync {
                                    self.dramas = dramaList
                                }
                            }
                        }
                        catch
                        {
                            return
                        }
                        
                        return
                    }
                    
                    let dataUpdate = cacheDramaList?.elementsEqual(dramaList, by: {(cacheDrama, remoteDrama) in
                        return cacheDrama != remoteDrama
                    })
                    
                    if dataUpdate ?? true
                    {
                        do
                        {
                            try self.saveCacheDramaList(dramaList: dramaList)
                        }
                        catch
                        {
                            
                        }
                    }
                    
                    if !self.dataIsSearching
                    {
                        self.dataSerialQueue.sync {
                            self.dramas = dramaList
                        }
                    }
                    
                    return
                }
                catch let decodeError
                {
                    NSLog("Decode Error : \(decodeError)")
                    self.statusHandler?(.FailedToLoadData)
                    
                    return
                }
            }
            else
            {
                self.statusHandler?(.FailedToLoadData)
            }
        })
    }
    
    private func loadListImage(dramas: [DramaData])
    {
        let links = dramas.map({$0.dramaImgURL})
        
        for link in links
        {
            guard let url = URL(string: link!) else
            {
                continue
            }
            
            HttpMgr.shared.doHttpRequest(withURL: link!, completeHandler: { (data, resp, error) in
                guard
                    let httpURLResponse = resp as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let mimeType = resp?.mimeType, mimeType.hasPrefix("image"),
                    let data = data, error == nil
                else
                {
                    return
                }

                self.saveImageData(link: url.absoluteString, imageData: data)
            })
        }
    }
    
    func saveImageData(link: String, imageData: Data)
    {
        let dataFileName = link.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        if dataFileName == nil
        {
            return
        }
        
        let imageFileURL = self.documentsFolder.appendingPathComponent(dataFileName!)
        
        if let data = try? Data(contentsOf: imageFileURL)
        {
            if data != imageData
            {
                do
                {
                    try imageData.write(to: imageFileURL)
                    self.updateUIHandler?()
                }
                catch let error
                {
                    print("write to cache error: \(error)")
                }
            }
        }
        else
        {
            do
            {
                try imageData.write(to: imageFileURL)
                self.updateUIHandler?()
            }
            catch
            {
                print("write to cache error: \(error)")
            }
        }
    }
    
    internal func deleteDramaImage(link: String) throws
    {
        let dataFileName = link.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        if dataFileName == nil
        {
            return
        }
        
        let imageFileURL = self.documentsFolder.appendingPathComponent(dataFileName!)
        if FileManager.default.fileExists(atPath: imageFileURL.path)
        {
            try FileManager.default.removeItem(at: imageFileURL)
        }
    }
    
    func getDramaImage(link: String?) -> UIImage?
    {
        if link == nil
        {
            return UIImage(named: "noImage")
        }
        
        let dataFileName = link!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        if dataFileName == nil
        {
            return UIImage(named: "noImage")
        }
        let dataURL = self.documentsFolder.appendingPathComponent(dataFileName!)
        
        // Attempt to load the data in this file
        if let data = try? Data(contentsOf: dataURL)
        {
            return UIImage(data: data)
        }
        else
        {
            return UIImage(named: "noImage")
        }
    }
    
    func countOfDramas() -> Int
    {
        return dramas.count
    }
    
    func getDramaItem(withIdex index: Int) -> DramaData?
    {
        dataSerialQueue.sync {
            guard index < self.dramas.count else {
                return nil
            }
            
            return dramas[index]
        }
    }
    
    func startSearching(withText text: String)
    {
        if text.count == 0
        {
            stopSearching()
            return
        }
        
        let cacheDramas = loadCacheDramaList()
        let filterDramas = cacheDramas?.filter({($0.dramaName?.contains(text) ?? false)})
        dramas = filterDramas ?? []
        dataIsSearching = true
    }
    
    func stopSearching()
    {
        dataIsSearching = false
        loadDramaData()
    }
}
