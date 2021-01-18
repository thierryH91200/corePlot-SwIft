//
//  File.swift
//  corePlot
//
//  Created by thierryH24 on 28/11/2020.
//

import Foundation



//class CPTAnimationTimingFunction {
//
//    let shared = CPTAnimationTimingFunction()

// elapsedTime should be between 0 and duration for all timing functions

// MARK: Linear

/**
 *  @brief Computes a linear animation timing function.
 *  @param elapsedTime The elapsed time of the animation between zero (@num{0}) and @par{duration}.
 *  @param duration The overall duration of the animation in seconds.
 *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{elapsedTime}.
 **/
    func  CPTAnimationTimingFunctionLinear(elapsedTime: CGFloat , duration : CGFloat )-> CGFloat
//    func  linear(elapsedTime: CGFloat , duration : CGFloat )-> CGFloat
    {
        
        var elapsedTime = elapsedTime
        
        if ( elapsedTime <= CGFloat(0.0)) {
            return CGFloat(0.0)
        }
        
        elapsedTime /= duration;
        
        if ( elapsedTime >= CGFloat(1.0)) {
            return CGFloat(1.0)
        }
        
        return elapsedTime;
    }
//}

// MARK: - Back
//
///**
// *  @brief Computes a backing in animation timing function.
// *  @param elapsedTime The elapsed time of the animation between zero (@num{0}) and @par{duration}.
// *  @param duration The overall duration of the animation in seconds.
// *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{elapsedTime}.
// **/
func CPTAnimationTimingFunctionBackIn(elapsedTime: CGFloat ,duration: CGFloat )-> CGFloat
{
    var elapsedTime = elapsedTime
    let s = CGFloat(1.70158);

    if ( elapsedTime <= CGFloat(0.0)) {
        return CGFloat(0.0);
    }

    elapsedTime /= duration;

    if ( elapsedTime >= CGFloat(1.0)) {
        return CGFloat(1.0);
    }
    return elapsedTime * elapsedTime * ((s + CGFloat(1.0)) * elapsedTime - s);
}

// *  @brief Computes a backing out animation timing function.
// *  @param elapsedTime The elapsed time of the animation between zero (@num{0}) and @par{duration}.
// *  @param duration The overall duration of the animation in seconds.
// *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{elapsedTime}.
// **/
//
func CPTAnimationTimingFunctionBackOut(elapsedTime: CGFloat , duration: CGFloat )-> CGFloat
{
    var elapsedTime = elapsedTime
    let s = CGFloat(1.70158);

    if ( elapsedTime <= CGFloat(0.0)) {
        return CGFloat(0.0);
    }

    elapsedTime = elapsedTime / duration - CGFloat(1.0);

    if ( elapsedTime >= CGFloat(0.0)) {
        return CGFloat(1.0);
    }

    return elapsedTime * elapsedTime * ((s + CGFloat(1.0)) * elapsedTime + s) + CGFloat(1.0);
}


// *  @brief Computes a backing in and out animation timing function.
// *  @param elapsedTime The elapsed time of the animation between zero (@num{0}) and @par{duration}.
// *  @param duration The overall duration of the animation in seconds.
// *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{elapsedTime}.
// **/
func  CPTAnimationTimingFunctionBackInOut(elapsedTime: CGFloat ,duration:  CGFloat )-> CGFloat
{
    var elapsedTime = elapsedTime
    let s = CGFloat(1.70158 * 1.525);

    if ( elapsedTime <= CGFloat(0.0)) {
        return CGFloat(0.0);
    }

    elapsedTime /= duration * CGFloat(0.5);

    if ( elapsedTime >= CGFloat(2.0)) {
        return CGFloat(1.0);
    }

    if ( elapsedTime < CGFloat(1.0)) {
        return CGFloat(0.5) * (elapsedTime * elapsedTime * ((s + CGFloat(1.0)) * elapsedTime - s));
    }
    else {
        elapsedTime -= CGFloat(2.0);

        return CGFloat(0.5) * (elapsedTime * elapsedTime * ((s + CGFloat(1.0)) * elapsedTime + s) + CGFloat(2.0));
    }
}


// MARK: - Bounce
//
///**
// *  @brief Computes a bounce in animation timing function.
// *  @param elapsedTime The elapsed time of the animation between zero (@num{0}) and @par{duration}.
// *  @param duration The overall duration of the animation in seconds.
// *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{elapsedTime}.
// **/
func CPTAnimationTimingFunctionBounceIn(elapsedTime: CGFloat , duration :CGFloat )-> CGFloat
{
    return CGFloat(1.0) - CPTAnimationTimingFunctionBounceOut(elapsedTime: duration - elapsedTime, duration: duration);
}
//
///**
// *  @brief Computes a bounce out animation timing function.
// *  @param elapsedTime The elapsed time of the animation between zero (@num{0}) and @par{duration}.
// *  @param duration The overall duration of the animation in seconds.
// *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{elapsedTime}.
// **/
func CPTAnimationTimingFunctionBounceOut(elapsedTime: CGFloat ,duration:  CGFloat )-> CGFloat
{
    var elapsedTime = elapsedTime

    if ( elapsedTime <= CGFloat(0.0)) {
        return CGFloat(0.0);
    }

    elapsedTime /= duration;

    if ( elapsedTime >= CGFloat(1.0)) {
        return CGFloat(1.0);
    }

    if ( elapsedTime < CGFloat(1.0 / 2.75)) {
        return CGFloat(7.5625) * elapsedTime * elapsedTime;
    }
    else if ( elapsedTime < CGFloat(2.0 / 2.75)) {
        elapsedTime -= CGFloat(1.5 / 2.75);

        return CGFloat(7.5625) * elapsedTime * elapsedTime + CGFloat(0.75);
    }
    else if ( elapsedTime < CGFloat(2.5 / 2.75)) {
        elapsedTime -= CGFloat(2.25 / 2.75);

        return CGFloat(7.5625) * elapsedTime * elapsedTime + CGFloat(0.9375);
    }
    else {
        elapsedTime -= CGFloat(2.625 / 2.75);

        return CGFloat(7.5625) * elapsedTime * elapsedTime + CGFloat(0.984375);
    }
}

///**
// *  @brief Computes a bounce in and out animation timing function.
// *  @param elapsedTime The elapsed time of the animation between zero (@num{0}) and @par{duration}.
// *  @param duration The overall duration of the animation in seconds.
// *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{elapsedTime}.
// **/
func CPTAnimationTimingFunctionBounceInOut(elapsedTime: CGFloat ,  duration: CGFloat ) -> CGFloat
{
    if ( elapsedTime < duration * CGFloat(0.5)) {
        return CPTAnimationTimingFunctionBounceIn(elapsedTime: elapsedTime * CGFloat(2.0), duration: duration) * CGFloat(0.5);
    }
    else {
        return CPTAnimationTimingFunctionBounceOut(elapsedTime: elapsedTime * CGFloat(2.0) - duration, duration: duration) * CGFloat(0.5) +
               CGFloat(0.5);
    }
}
//

// MARK: - Circular
//
///**
// *  @brief Computes a circular in animation timing function.
// *  @param elapsedTime The elapsed time of the animation between zero (@num{0}) and @par{duration}.
// *  @param duration The overall duration of the animation in seconds.
// *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{elapsedTime}.
// **/
func CPTAnimationTimingFunctionCircularIn(elapsedTime: CGFloat ,  duration: CGFloat ) -> CGFloat
{
    var elapsedTime = elapsedTime
    if ( elapsedTime <= CGFloat(0.0)) {
        return CGFloat(0.0);
    }

    elapsedTime /= duration;

    if ( elapsedTime >= CGFloat(1.0)) {
        return CGFloat(1.0);
    }

    return -(sqrt(CGFloat(1.0) - elapsedTime * elapsedTime) - CGFloat(1.0));
}
//
///**
// *  @brief Computes a circular out animation timing function.
// *  @param elapsedTime The elapsed time of the animation between zero (@num{0}) and @par{duration}.
// *  @param duration The overall duration of the animation in seconds.
// *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{elapsedTime}.
// **/
func CPTAnimationTimingFunctionCircularOut(elapsedTime: CGFloat ,  duration: CGFloat ) -> CGFloat
{
    var elapsedTime = elapsedTime

    if ( elapsedTime <= CGFloat(0.0)) {
        return CGFloat(0.0);
    }

    elapsedTime = elapsedTime / duration - CGFloat(1.0);

    if ( elapsedTime >= CGFloat(0.0)) {
        return CGFloat(1.0);
    }

    return sqrt(CGFloat(1.0) - elapsedTime * elapsedTime);
}
//
///**
// *  @brief Computes a circular in and out animation timing function.
// *  @param elapsedTime The elapsed time of the animation between zero (@num{0}) and @par{duration}.
// *  @param duration The overall duration of the animation in seconds.
// *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{elapsedTime}.
// **/
func CPTAnimationTimingFunctionCircularInOut(elapsedTime: CGFloat ,  duration: CGFloat ) -> CGFloat
{
    var elapsedTime = elapsedTime
    if ( elapsedTime <= CGFloat(0.0)) {
        return CGFloat(0.0);
    }

    elapsedTime /= duration * CGFloat(0.5);

    if ( elapsedTime >= CGFloat(2.0)) {
        return CGFloat(1.0);
    }

    if ( elapsedTime < CGFloat(1.0)) {
        return CGFloat(-0.5) * (sqrt(CGFloat(1.0) - elapsedTime * elapsedTime) - CGFloat(1.0));
    }
    else {
        elapsedTime -= CGFloat(2.0);

        return CGFloat(0.5) * (sqrt(CGFloat(1.0) - elapsedTime * elapsedTime) + CGFloat(1.0));
    }
}
//
// MARK: - Elastic
//
///**
// *  @brief Computes a elastic in animation timing function.
// *  @param elapsedTime The elapsed time of the animation between zero (@num{0}) and @par{duration}.
// *  @param duration The overall duration of the animation in seconds.
// *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{elapsedTime}.
// **/
func CPTAnimationTimingFunctionElasticIn(elapsedTime: CGFloat ,  duration: CGFloat ) -> CGFloat
{
    var elapsedTime = elapsedTime

    if ( elapsedTime <= CGFloat(0.0)) {
        return CGFloat(0.0);
    }

    elapsedTime /= duration;

    if ( elapsedTime >= CGFloat(1.0)) {
        return CGFloat(1.0);
    }

    let period = duration * CGFloat(0.3);
    let s      = period * CGFloat(0.25);

    elapsedTime -= CGFloat(1.0);

    return -(pow(CGFloat(2.0), CGFloat(10.0) * elapsedTime) * sin((elapsedTime * duration - s) * CGFloat(2.0 * Double.pi) / period));
}
//
///**
// *  @brief Computes a elastic out animation timing function.
// *  @param elapsedTime The elapsed time of the animation between zero (@num{0}) and @par{duration}.
// *  @param duration The overall duration of the animation in seconds.
// *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{elapsedTime}.
// **/
func CPTAnimationTimingFunctionElasticOut(elapsedTime: CGFloat ,  duration: CGFloat ) -> CGFloat
{
    var elapsedTime = elapsedTime
    if ( elapsedTime <= CGFloat(0.0)) {
        return CGFloat(0.0);
    }

    elapsedTime /= duration;

    if ( elapsedTime >= CGFloat(1.0)) {
        return CGFloat(1.0);
    }

    let period = duration * CGFloat(0.3);
    let s      = period * CGFloat(0.25);

    return pow(CGFloat(2.0), CGFloat(-10.0) * elapsedTime) * sin((elapsedTime * duration - s) * CGFloat(2.0 * Double.pi) / period) + CGFloat(1.0);
}
//
///**
// *  @brief Computes a elastic in and out animation timing function.
// *  @param elapsedTime The elapsed time of the animation between zero (@num{0}) and @par{duration}.
// *  @param duration The overall duration of the animation in seconds.
// *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{elapsedTime}.
// **/
func CPTAnimationTimingFunctionElasticInOut(elapsedTime: CGFloat ,  duration: CGFloat ) -> CGFloat
{
    var elapsedTime = elapsedTime
    if ( elapsedTime <= CGFloat(0.0)) {
        return CGFloat(0.0);
    }

    elapsedTime /= duration * CGFloat(0.5);

    if ( elapsedTime >= CGFloat(2.0)) {
        return CGFloat(1.0);
    }

    let period = duration * CGFloat(0.3 * 1.5);
    let s      = period * CGFloat(0.25);

    elapsedTime -= CGFloat(1.0);

    if ( elapsedTime < CGFloat(0.0)) {
        return CGFloat(-0.5) * (pow(CGFloat(2.0), CGFloat(10.0) * elapsedTime) * sin((elapsedTime * duration - s) * CGFloat(2.0 * Double.pi) / period));
    }
    else {
        return pow(CGFloat(2.0), CGFloat(-10.0) * elapsedTime) * sin((elapsedTime * duration - s) * CGFloat(2.0 * Double.pi) / period) * CGFloat(0.5) + CGFloat(1.0);
    }
}

// MARK: - Exponential

/**
 *  @brief Computes a exponential in animation timing function.
 *  @param elapsedTime The elapsed time of the animation between zero (@num{0}) and @par{duration}.
 *  @param duration The overall duration of the animation in seconds.
 *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{elapsedTime}.
 **/
func CPTAnimationTimingFunctionExponentialIn(elapsedTime: CGFloat ,  duration: CGFloat ) -> CGFloat
{
    var elapsedTime = elapsedTime
    if ( elapsedTime <= CGFloat(0.0)) {
        return CGFloat(0.0);
    }

    elapsedTime /= duration;

    if ( elapsedTime >= CGFloat(1.0)) {
        return CGFloat(1.0);
    }

    return pow(CGFloat(2.0), CGFloat(10.0) * (elapsedTime - CGFloat(1.0)));
}

/**
 *  @brief Computes a exponential out animation timing function.
 *  @param elapsedTime The elapsed time of the animation between zero (@num{0}) and @par{duration}.
 *  @param duration The overall duration of the animation in seconds.
 *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{elapsedTime}.
 **/
func CPTAnimationTimingFunctionExponentialOut(elapsedTime: CGFloat ,  duration: CGFloat ) -> CGFloat
{
    var elapsedTime = elapsedTime
    if ( elapsedTime <= CGFloat(0.0)) {
        return CGFloat(0.0);
    }

    elapsedTime /= duration;

    if ( elapsedTime >= CGFloat(1.0)) {
        return CGFloat(1.0);
    }

    return -pow(CGFloat(2.0), CGFloat(-10.0) * elapsedTime) + CGFloat(1.0);
}

/**
 *  @brief Computes a exponential in and out animation timing function.
 *  @param elapsedTime The elapsed time of the animation between zero (@num{0}) and @par{duration}.
 *  @param duration The overall duration of the animation in seconds.
 *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{elapsedTime}.
 **/
func CPTAnimationTimingFunctionExponentialInOut(elapsedTime: CGFloat ,  duration: CGFloat ) -> CGFloat
{
    var elapsedTime = elapsedTime
    if ( elapsedTime <= CGFloat(0.0)) {
        return CGFloat(0.0);
    }

    elapsedTime /= duration * CGFloat(0.5);
    elapsedTime -= CGFloat(1.0);

    if ( elapsedTime >= CGFloat(1.0)) {
        return CGFloat(1.0);
    }

    if ( elapsedTime < CGFloat(0.0)) {
        return CGFloat(0.5) * pow(CGFloat(2.0), CGFloat(10.0) * elapsedTime);
    }
    else {
        return CGFloat(0.5) * (-pow(CGFloat(2.0), CGFloat(-10.0) * elapsedTime) + CGFloat(2.0));
    }
}
//
// MARK: - Sinusoidal
//
///**
// *  @brief Computes a sinusoidal in animation timing function.
// *  @param elapsedTime The elapsed time of the animation between zero (@num{0}) and @par{duration}.
// *  @param duration The overall duration of the animation in seconds.
// *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{elapsedTime}.
// **/
func CPTAnimationTimingFunctionSinusoidalIn(elapsedTime: CGFloat ,  duration: CGFloat ) -> CGFloat
{
    var elapsedTime = elapsedTime
    if ( elapsedTime <= CGFloat(0.0)) {
        return CGFloat(0.0);
    }

    elapsedTime /= duration;

    if ( elapsedTime >= CGFloat(1.0)) {
        return CGFloat(1.0);
    }

    return -cos(elapsedTime * CGFloat(Double.pi/2)) + CGFloat(1.0);
}
//
///**
// *  @brief Computes a sinusoidal out animation timing function.
// *  @param elapsedTime The elapsed time of the animation between zero (@num{0}) and @par{duration}.
// *  @param duration The overall duration of the animation in seconds.
// *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{elapsedTime}.
// **/
func CPTAnimationTimingFunctionSinusoidalOut(elapsedTime: CGFloat ,  duration: CGFloat ) -> CGFloat
{
    var elapsedTime = elapsedTime
    if ( elapsedTime <= CGFloat(0.0)) {
        return CGFloat(0.0);
    }

    elapsedTime /= duration;

    if ( elapsedTime >= CGFloat(1.0)) {
        return CGFloat(1.0);
    }

    return sin(elapsedTime * CGFloat(Double.pi/2));
}

/**
 *  @brief Computes a sinusoidal in and out animation timing function.
 *  @param elapsedTime The elapsed time of the animation between zero (@num{0}) and @par{duration}.
 *  @param duration The overall duration of the animation in seconds.
 *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{elapsedTime}.
 **/
func CPTAnimationTimingFunctionSinusoidalInOut(elapsedTime: CGFloat ,  duration: CGFloat ) -> CGFloat
{
    var elapsedTime = elapsedTime
    if ( elapsedTime <= CGFloat(0.0)) {
        return CGFloat(0.0);
    }

    elapsedTime /= duration;

    if ( elapsedTime >= CGFloat(1.0)) {
        return CGFloat(1.0);
    }

    return CGFloat(-0.5) * (cos(CGFloat(Double.pi) * elapsedTime) - CGFloat(1.0));
}
//
// MARK: - Cubic

/**
 *  @brief Computes a cubic in animation timing function.
 *  @param elapsedTime The elapsed time of the animation between zero (@num{0}) and @par{duration}.
 *  @param duration The overall duration of the animation in seconds.
 *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{elapsedTime}.
 **/
func CPTAnimationTimingFunctionCubicIn(elapsedTime: CGFloat ,  duration: CGFloat ) -> CGFloat
{
    var elapsedTime = elapsedTime
    if ( elapsedTime <= CGFloat(0.0)) {
        return CGFloat(0.0);
    }

    elapsedTime /= duration;

    if ( elapsedTime >= CGFloat(1.0)) {
        return CGFloat(1.0);
    }

    return elapsedTime * elapsedTime * elapsedTime;
}
//
///**
// *  @brief Computes a cubic out animation timing function.
// *  @param elapsedTime The elapsed time of the animation between zero (@num{0}) and @par{duration}.
// *  @param duration The overall duration of the animation in seconds.
// *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{elapsedTime}.
// **/
func CPTAnimationTimingFunctionCubicOut(elapsedTime: CGFloat ,  duration: CGFloat ) -> CGFloat
{
    var elapsedTime = elapsedTime
    if ( elapsedTime <= CGFloat(0.0)) {
        return CGFloat(0.0);
    }

    elapsedTime = elapsedTime / duration - CGFloat(1.0);

    if ( elapsedTime >= CGFloat(0.0)) {
        return CGFloat(1.0);
    }

    return elapsedTime * elapsedTime * elapsedTime + CGFloat(1.0);
}
//
///**
// *  @brief Computes a cubic in and out animation timing function.
// *  @param elapsedTime The elapsed time of the animation between zero (@num{0}) and @par{duration}.
// *  @param duration The overall duration of the animation in seconds.
// *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{elapsedTime}.
// **/
func CPTAnimationTimingFunctionCubicInOut(elapsedTime: CGFloat ,  duration: CGFloat ) -> CGFloat
{
    var elapsedTime = elapsedTime
    if ( elapsedTime <= CGFloat(0.0)) {
        return CGFloat(0.0);
    }

    elapsedTime /= duration * CGFloat(0.5);

    if ( elapsedTime >= CGFloat(2.0)) {
        return CGFloat(1.0);
    }

    if ( elapsedTime < CGFloat(1.0)) {
        return CGFloat(0.5) * elapsedTime * elapsedTime * elapsedTime;
    }
    else {
        elapsedTime -= CGFloat(2.0);

        return CGFloat(0.5) * (elapsedTime * elapsedTime * elapsedTime + CGFloat(2.0));
    }
}

// MARK: - Quadratic

/**
 *  @brief Computes a quadratic in animation timing function.
 *  @param elapsedTime The elapsed time of the animation between zero (@num{0}) and @par{duration}.
 *  @param duration The overall duration of the animation in seconds.
 *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{elapsedTime}.
 **/
func CPTAnimationTimingFunctionQuadraticIn(elapsedTime: CGFloat ,  duration: CGFloat ) -> CGFloat
{
    var elapsedTime = elapsedTime
    if ( elapsedTime <= CGFloat(0.0)) {
        return CGFloat(0.0);
    }

    elapsedTime /= duration;
    if ( elapsedTime >= CGFloat(1.0)) {
        return CGFloat(1.0);
    }
    return elapsedTime * elapsedTime;
}
//
///**
// *  @brief Computes a quadratic out animation timing function.
// *  @param elapsedTime The elapsed time of the animation between zero (@num{0}) and @par{duration}.
// *  @param duration The overall duration of the animation in seconds.
// *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{elapsedTime}.
// **/
func CPTAnimationTimingFunctionQuadraticOut(elapsedTime: CGFloat ,  duration: CGFloat ) -> CGFloat
{
    var elapsedTime = elapsedTime
    if ( elapsedTime <= CGFloat(0.0)) {
        return CGFloat(0.0);
    }

    elapsedTime /= duration;

    if ( elapsedTime >= CGFloat(1.0)) {
        return CGFloat(1.0);
    }
    return -elapsedTime * (elapsedTime - CGFloat(2.0));
}
//
///**
// *  @brief Computes a quadratic in and out animation timing function.
// *  @param elapsedTime The elapsed time of the animation between zero (@num{0}) and @par{duration}.
// *  @param duration The overall duration of the animation in seconds.
// *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{elapsedTime}.
// **/
func CPTAnimationTimingFunctionQuadraticInOut(elapsedTime: CGFloat ,  duration: CGFloat ) -> CGFloat
{
    var elapsedTime = elapsedTime
    if ( elapsedTime <= CGFloat(0.0)) {
        return CGFloat(0.0);
    }

    elapsedTime /= duration * CGFloat(0.5);

    if ( elapsedTime >= CGFloat(2.0)) {
        return CGFloat(1.0);
    }

    if ( elapsedTime < CGFloat(1.0)) {
        return CGFloat(0.5) * elapsedTime * elapsedTime;
    }
    else {
        elapsedTime -= CGFloat(1.0);

        return CGFloat(-0.5) * (elapsedTime * (elapsedTime - CGFloat(2.0)) - CGFloat(1.0));
    }
}

// MARK: - Quartic


//
///**
// *  @brief Computes a quartic in animation timing function.
// *  @param elapsedTime The elapsed time of the animation between zero (@num{0}) and @par{duration}.
// *  @param duration The overall duration of the animation in seconds.
// *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{elapsedTime}.
// **/
func CPTAnimationTimingFunctionQuarticIn(elapsedTime: CGFloat ,  duration: CGFloat ) -> CGFloat
{
    var elapsedTime = elapsedTime
    if ( elapsedTime <= CGFloat(0.0)) {
        return CGFloat(0.0);
    }

    elapsedTime /= duration;

    if ( elapsedTime >= CGFloat(1.0)) {
        return CGFloat(1.0);
    }

    return elapsedTime * elapsedTime * elapsedTime * elapsedTime;
}

/**
 *  @brief Computes a quartic out animation timing function.
 *  @param elapsedTime The elapsed time of the animation between zero (@num{0}) and @par{duration}.
 *  @param duration The overall duration of the animation in seconds.
 *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{elapsedTime}.
 **/
func CPTAnimationTimingFunctionQuarticOut(elapsedTime: CGFloat ,  duration: CGFloat ) -> CGFloat
{
    var elapsedTime = elapsedTime
    if ( elapsedTime <= CGFloat(0.0)) {
        return CGFloat(0.0);
    }
    
    elapsedTime = elapsedTime / duration - CGFloat(1.0);
    
    if ( elapsedTime >= CGFloat(0.0)) {
        return CGFloat(1.0);
    }
    
    return -(elapsedTime * elapsedTime * elapsedTime * elapsedTime - CGFloat(1.0));
}

/**
 *  @brief Computes a quartic in and out animation timing function.
 *  @param elapsedTime The elapsed time of the animation between zero (@num{0}) and @par{duration}.
 *  @param duration The overall duration of the animation in seconds.
 *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{elapsedTime}.
 **/
func CPTAnimationTimingFunctionQuarticInOut(elapsedTime: CGFloat, duration: CGFloat) -> CGFloat
{
    var elapsedTime = elapsedTime
    guard elapsedTime > CGFloat(0) else { return CGFloat(0.0) }

    elapsedTime /= duration * CGFloat(0.5);
    if ( elapsedTime >= CGFloat(2.0)) {
        return CGFloat(1.0);
    }

    if ( elapsedTime < CGFloat(1.0)) {
        return CGFloat(0.5) * elapsedTime * elapsedTime * elapsedTime * elapsedTime;
    }
    else {
        elapsedTime -= CGFloat(2.0);

        return CGFloat(-0.5) * (elapsedTime * elapsedTime * elapsedTime * elapsedTime - CGFloat(2.0));
    }
}
//
// MARK: - Quintic
//
///**
// *  @brief Computes a quintic in animation timing function.
// *  @param elapsedTime The elapsed time of the animation between zero (@num{0}) and @par{duration}.
// *  @param duration The overall duration of the animation in seconds.
// *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{elapsedTime}.
// **/
func CPTAnimationTimingFunctionQuinticIn(elapsedTime: CGFloat ,  duration: CGFloat ) -> CGFloat
{
    var elapsedTime = elapsedTime
    if ( elapsedTime <= CGFloat(0.0)) {
        return CGFloat(0.0);
    }

    elapsedTime /= duration;

    if ( elapsedTime >= CGFloat(1.0)) {
        return CGFloat(1.0);
    }

    return elapsedTime * elapsedTime * elapsedTime * elapsedTime * elapsedTime;
}
//
///**
// *  @brief Computes a quintic out animation timing function.
// *  @param elapsedTime The elapsed time of the animation between zero (@num{0}) and @par{duration}.
// *  @param duration The overall duration of the animation in seconds.
// *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{elapsedTime}.
// **/
func CPTAnimationTimingFunctionQuinticOut(elapsedTime: CGFloat ,  duration: CGFloat ) -> CGFloat
{
    var elapsedTime = elapsedTime
    if ( elapsedTime <= CGFloat(0.0)) {
        return CGFloat(0.0);
    }

    elapsedTime = elapsedTime / duration - CGFloat(1.0);

    if ( elapsedTime >= CGFloat(0.0)) {
        return CGFloat(1.0);
    }

    return elapsedTime * elapsedTime * elapsedTime * elapsedTime * elapsedTime + CGFloat(1.0);
}
//
///**
// *  @brief Computes a quintic in and out animation timing function.
// *  @param elapsedTime The elapsed time of the animation between zero (@num{0}) and @par{duration}.
// *  @param duration The overall duration of the animation in seconds.
// *  @return The animation progress in the range zero (@num{0}) to one (@num{1}) at the given @par{elapsedTime}.
// **/
func CPTAnimationTimingFunctionQuinticInOut(elapsedTime: CGFloat ,  duration: CGFloat ) -> CGFloat
{
    var elapsedTime = elapsedTime
    if ( elapsedTime <= CGFloat(0.0)) {
        return CGFloat(0.0);
    }

    elapsedTime /= duration * CGFloat(0.5);

    if ( elapsedTime >= CGFloat(2.0)) {
        return CGFloat(1.0);
    }

    if ( elapsedTime < CGFloat(1.0)) {
        return CGFloat(0.5) * elapsedTime * elapsedTime * elapsedTime * elapsedTime * elapsedTime;
    }
    else {
        elapsedTime -= CGFloat(2.0);

        return CGFloat(0.5) * (elapsedTime * elapsedTime * elapsedTime * elapsedTime * elapsedTime + CGFloat(2.0));
    }
}

