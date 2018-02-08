//
//  RoundedButton.swift
//  MaximoWOTRACKSample
//
//  Created by Silvino Vieira de Vasconcelos Neto on 08/02/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import UIKit

class RoundedButton : UIButton {
 
    override func awakeFromNib() {
        super.awakeFromNib()

        layer.borderWidth = 1 / UIScreen.main.nativeScale
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
        layer.borderColor = tintColor.cgColor
    }
}
