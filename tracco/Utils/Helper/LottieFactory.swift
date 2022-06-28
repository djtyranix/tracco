//
//  LottieFactory.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 28/06/22.
//

import Foundation
import Lottie
import UIKit

class LottieFactory
{
    static func makeIndefiniteLoadingView(on: UIView) -> AnimationView
    {
        let lottieView = AnimationView(name: "LottieSummarize")
        layout(lottieView, on: on)
        lottieView.loopMode = .loop
        return lottieView
    }
    
    static func makeLogoView(on: UIView) -> AnimationView
    {
        let lottieView = AnimationView(name: "Lottie2")
        layout(lottieView, on: on)
        lottieView.loopMode = .playOnce
        return lottieView
    }
    
    static private func layout(_ lottieView: AnimationView, on: UIView)
    {
        lottieView.contentMode = .scaleAspectFill
        lottieView.frame = on.bounds
        on.addSubview(lottieView)
    }
}
