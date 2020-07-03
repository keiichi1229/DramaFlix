//
//  Theme.swift
//  DramaDemo
//
//  Created by Raymondting on 2020/7/2.
//  Copyright © 2020 Raymondting. All rights reserved.
//

import Foundation
import UIKit

struct Theme
{
    static func apply()
    {
        guard let headerFont = UIFont(familyName: "Lobster", size: UIFont.systemFontSize * 2, varianName: nil) else
        {
            print("Fail to load header font")
            return
        }
        
        guard let primaryFont = UIFont(familyName: "Quicksand") else
        {
            print("Fail to load application font")
            return
        }
        
        let tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        UIApplication.shared.delegate?.window??.tintColor = tintColor
        
        let navBarLable = UILabel.appearance(whenContainedInInstancesOf: [UINavigationBar.self])
        let barButton = UIBarButtonItem.appearance()
        let buttonLabel = UILabel.appearance(whenContainedInInstancesOf: [UIButton.self])
        let navBar = UINavigationBar.appearance()

        navBar.titleTextAttributes = [.font: headerFont, .foregroundColor: UIColor.red]
        navBar.barTintColor = tintColor
        navBarLable.font = primaryFont
        
        barButton.setTitleTextAttributes([.font: primaryFont], for: .normal)
        barButton.setTitleTextAttributes([.font: primaryFont], for: .highlighted)
        barButton.tintColor = UIColor.red
        buttonLabel.font = primaryFont
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
}
