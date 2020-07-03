//
//  File.swift
//  DramaDemo
//
//  Created by Raymondting on 2020/7/1.
//  Copyright © 2020 Raymondting. All rights reserved.
//

import Foundation
import UIKit

extension Double
{
    func rounding(toDecimal decimal: Int) -> Double
    {
        let numberOfDigits = pow(10.0, Double(decimal))
        return (self * numberOfDigits).rounded(.toNearestOrAwayFromZero) / numberOfDigits
    }
}

extension UIFont
{
    convenience init? (familyName: String, size: CGFloat = UIFont.systemFontSize, varianName: String? = nil)
    {
        guard let name = UIFont.familyNames.filter ({$0.contains(familyName)}).flatMap({UIFont.fontNames(forFamilyName: $0)}).filter({varianName != nil ? $0.contains(varianName!) : true}).first else
        {
            return nil
        }
        
        self.init(name: name, size: size)
    }
}

//extension UIImageView
//{
//    func downloaded(from url: URL ,contentMode mode: UIView.ContentMode = .scaleAspectFit)
//    {
//        contentMode = mode
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            guard
//                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
//                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
//                let data = data, error == nil,
//                let image = UIImage(data: data)
//            else
//            {
//                return
//                
//            }
//            
//            DispatchQueue.main.async() { [weak self] in
//                self?.image = image
//                DramaDataMgr.shared.saveImageData(link: url.absoluteString, imageData: data)
//            }
//            
//        }.resume()
//    }
//    
//    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit)
//    {
//        guard let url = URL(string: link) else
//        {
//            return
//        }
//
//        downloaded(from: url, contentMode: mode)
//    }
//    
//}
