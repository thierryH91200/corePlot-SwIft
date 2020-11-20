//
//  CPTAnimation.swift
//  corePlot
//
//  Created by thierryH24 on 14/11/2020.
//

import Cocoa

enum CPTAnimationCurve : Int {
    case `default`         ///< Use the default animation curve.
    case linear           ///< Linear animation curve.
    case BackIn          ///< Backing in animation curve.
    case BackOut          ///< Backing out animation curve.
    case    BackInOut        ///< Backing in and out animation curve.
    case BounceIn         ///< Bounce in animation curve.
    case BounceOut        ///< Bounce out animation curve.
    case BounceInOut      ///< Bounce in and out animation curve.
    case CircularIn       ///< Circular in animation curve.
    case CircularOut      ///< Circular out animation curve.
    case CircularInOut    ///< Circular in and out animation curve.
    case ElasticIn        ///< Elastic in animation curve.
    case ElasticOut       ///< Elastic out animation curve.
    case ElasticInOut     ///< Elastic in and out animation curve.
    case ExponentialIn    ///< Exponential in animation curve.
    case ExponentialOut   ///< Exponential out animation curve.
    case ExponentialInOut ///< Exponential in and out animation curve.
    case SinusoidalIn     ///< Sinusoidal in animation curve.
    case SinusoidalOut    ///< Sinusoidal out animation curve.
    case SinusoidalInOut  ///< Sinusoidal in and out animation curve.
    case CubicIn          ///< Cubic in animation curve.
    case CubicOut         ///< Cubic out animation curve.
    case CubicInOut       ///< Cubic in and out animation curve.
    case QuadraticIn      ///< Quadratic in animation curve.
    case QuadraticOut     ///< Quadratic out animation curve.
    case QuadraticInOut   ///< Quadratic in and out animation curve.
    case QuarticIn        ///< Quartic in animation curve.
    case QuarticOut       ///< Quartic out animation curve.
    case QuarticInOut     ///< Quartic in and out animation curve.
    case QuinticIn        ///< Quintic in animation curve.
    case QuinticOut       ///< Quintic out animation curve.
    case QuinticInOut      ///< Quintic in and out animation curve.
};


protocol CPTAnimationDelegate {
    
    
    func animationDidStart(operation: CPTAnimationOperation )
    func animationDidFinish(operation: CPTAnimationOperation )
    func animationCancelled(operation: CPTAnimationOperation )
    func animationWillUpdate(operation: CPTAnimationOperation )
    func animationDidUpdate(operation: CPTAnimationOperation )

}


class CPTAnimation: NSObject {
    
    var timeOffset: CGFloat
    var defaultAnimationCurve = CPTAnimationCurve.default


}
