//
//  CPTUtilities.swift
//  corePlot
//
//  Created by thierryH24 on 24/11/2020.
//

import Foundation

class CPTUtilities : NSObject {
    
    let shared = CPTUtilities()
    
    //#pragma mark -
    //#pragma mark Convert NSDecimal to primitive types
    //
    ///**
    // *  @brief Converts an @ref NSDecimal value to an 8-bit integer.
    // *  @param decimalNumber The @ref NSDecimal value.
    // *  @return The converted value.
    // **/
    //int8_t CPTDecimalCharValue(NSDecimal decimalNumber)
    //{
    //    return (int8_t)[NSDecimalNumber decimalNumberWithDecimal:decimalNumber].charValue;
    //}
    //
    ///**
    // *  @brief Converts an @ref NSDecimal value to a 16-bit integer.
    // *  @param decimalNumber The @ref NSDecimal value.
    // *  @return The converted value.
    // **/
    //int16_t CPTDecimalShortValue(NSDecimal decimalNumber)
    //{
    //    return (int16_t)[NSDecimalNumber decimalNumberWithDecimal:decimalNumber].shortValue;
    //}
    //
    ///**
    // *  @brief Converts an @ref NSDecimal value to a 32-bit integer.
    // *  @param decimalNumber The @ref NSDecimal value.
    // *  @return The converted value.
    // **/
    //int32_t CPTDecimalLongValue(NSDecimal decimalNumber)
    //{
    //    NSDecimalNumber *d = [NSDecimalNumber decimalNumberWithDecimal:decimalNumber];
    //
    //    d = [d decimalNumberByRoundingAccordingToBehavior:
    //         [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown
    //                                                                scale:0
    //                                                     raiseOnExactness:NO
    //                                                      raiseOnOverflow:NO
    //                                                     raiseOnUnderflow:NO
    //                                                  raiseOnDivideByZero:NO]];
    //
    //    return (int32_t)d.longValue;
    //}
    //
    ///**
    // *  @brief Converts an @ref NSDecimal value to a 64-bit integer.
    // *  @param decimalNumber The @ref NSDecimal value.
    // *  @return The converted value.
    // **/
    
    //int64_t CPTDecimalLongLongValue(NSDecimal decimalNumber)
    //{
    //    NSDecimalNumber *d = [NSDecimalNumber decimalNumberWithDecimal:decimalNumber];
    //
    //    d = [d decimalNumberByRoundingAccordingToBehavior:
    //         [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown
    //                                                                scale:0
    //                                                     raiseOnExactness:NO
    //                                                      raiseOnOverflow:NO
    //                                                     raiseOnUnderflow:NO
    //                                                  raiseOnDivideByZero:NO]];
    //
    //    return (int64_t)d.longLongValue;
    //}
    //
    ///**
    // *  @brief Converts an @ref NSDecimal value to an @int.
    // *  @param decimalNumber The @ref NSDecimal value.
    // *  @return The converted value.
    // **/
    //int CPTDecimalIntValue(NSDecimal decimalNumber)
    //{
    //    return [NSDecimalNumber decimalNumberWithDecimal:decimalNumber].intValue;
    //}
    //
    ///**
    // *  @brief Converts an @ref NSDecimal value to an @ref NSInteger.
    // *  @param decimalNumber The @ref NSDecimal value.
    // *  @return The converted value.
    // **/
    //NSInteger CPTDecimalIntegerValue(NSDecimal decimalNumber)
    //{
    //    NSDecimalNumber *d = [NSDecimalNumber decimalNumberWithDecimal:decimalNumber];
    //
    //    d = [d decimalNumberByRoundingAccordingToBehavior:
    //         [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown
    //                                                                scale:0
    //                                                     raiseOnExactness:NO
    //                                                      raiseOnOverflow:NO
    //                                                     raiseOnUnderflow:NO
    //                                                  raiseOnDivideByZero:NO]];
    //
    //    return (NSInteger)d.integerValue;
    //}
    //
    ///**
    // *  @brief Converts an @ref NSDecimal value to an unsigned 8-bit integer.
    // *  @param decimalNumber The @ref NSDecimal value.
    // *  @return The converted value.
    // **/
    //uint8_t CPTDecimalUnsignedCharValue(NSDecimal decimalNumber)
    //{
    //    return (uint8_t)[NSDecimalNumber decimalNumberWithDecimal:decimalNumber].unsignedCharValue;
    //}
    //
    ///**
    // *  @brief Converts an @ref NSDecimal value to an unsigned 16-bit integer.
    // *  @param decimalNumber The @ref NSDecimal value.
    // *  @return The converted value.
    // **/
    //uint16_t CPTDecimalUnsignedShortValue(NSDecimal decimalNumber)
    //{
    //    return (uint16_t)[NSDecimalNumber decimalNumberWithDecimal:decimalNumber].unsignedShortValue;
    //}
    //
    ///**
    // *  @brief Converts an @ref NSDecimal value to an unsigned 32-bit integer.
    // *  @param decimalNumber The @ref NSDecimal value.
    // *  @return The converted value.
    // **/
    //uint32_t CPTDecimalUnsignedLongValue(NSDecimal decimalNumber)
    //{
    //    NSDecimalNumber *d = [NSDecimalNumber decimalNumberWithDecimal:decimalNumber];
    //
    //    d = [d decimalNumberByRoundingAccordingToBehavior:
    //         [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown
    //                                                                scale:0
    //                                                     raiseOnExactness:NO
    //                                                      raiseOnOverflow:NO
    //                                                     raiseOnUnderflow:NO
    //                                                  raiseOnDivideByZero:NO]];
    //
    //    return (uint32_t)d.unsignedLongValue;
    //}
    //
    ///**
    // *  @brief Converts an @ref NSDecimal value to an unsigned 64-bit integer.
    // *  @param decimalNumber The @ref NSDecimal value.
    // *  @return The converted value.
    // **/
    //uint64_t CPTDecimalUnsignedLongLongValue(NSDecimal decimalNumber)
    //{
    //    NSDecimalNumber *d = [NSDecimalNumber decimalNumberWithDecimal:decimalNumber];
    //
    //    d = [d decimalNumberByRoundingAccordingToBehavior:
    //         [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown
    //                                                                scale:0
    //                                                     raiseOnExactness:NO
    //                                                      raiseOnOverflow:NO
    //                                                     raiseOnUnderflow:NO
    //                                                  raiseOnDivideByZero:NO]];
    //
    //    return (uint64_t)d.unsignedLongLongValue;
    //}
    //
    ///**
    // *  @brief Converts an @ref NSDecimal value to an @uint.
    // *  @param decimalNumber The @ref NSDecimal value.
    // *  @return The converted value.
    // **/
    //unsigned int CPTDecimalUnsignedIntValue(NSDecimal decimalNumber)
    //{
    //    return [NSDecimalNumber decimalNumberWithDecimal:decimalNumber].unsignedIntValue;
    //}
    //
    ///**
    // *  @brief Converts an @ref NSDecimal value to an @ref NSUInteger.
    // *  @param decimalNumber The @ref NSDecimal value.
    // *  @return The converted value.
    // **/
    //NSUInteger CPTDecimalUnsignedIntegerValue(NSDecimal decimalNumber)
    //{
    //    NSDecimalNumber *d = [NSDecimalNumber decimalNumberWithDecimal:decimalNumber];
    //
    //    d = [d decimalNumberByRoundingAccordingToBehavior:
    //         [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown
    //                                                                scale:0
    //                                                     raiseOnExactness:NO
    //                                                      raiseOnOverflow:NO
    //                                                     raiseOnUnderflow:NO
    //                                                  raiseOnDivideByZero:NO]];
    //
    //    return (NSUInteger)d.unsignedIntegerValue;
    //}
    //
    ///**
    // *  @brief Converts an @ref NSDecimal value to a @float.
    // *  @param decimalNumber The @ref NSDecimal value.
    // *  @return The converted value.
    // **/
    //float CPTDecimalFloatValue(NSDecimal decimalNumber)
    //{
    //    return [NSDecimalNumber decimalNumberWithDecimal:decimalNumber].floatValue;
    //}
    //
    ///**
    // *  @brief Converts an @ref NSDecimal value to a @double.
    // *  @param decimalNumber The @ref NSDecimal value.
    // *  @return The converted value.
    // **/
    //double CPTDecimalDoubleValue(NSDecimal decimalNumber)
    //{
    //    return [NSDecimalNumber decimalNumberWithDecimal:decimalNumber].doubleValue;
    //}
    //
    ///**
    // *  @brief Converts an @ref NSDecimal value to a @ref CGFloat.
    // *  @param decimalNumber The @ref NSDecimal value.
    // *  @return The converted value.
    // **/
    //CGFloat CPTDecimalCGFloatValue(NSDecimal decimalNumber)
    //{
    //#if CGFLOAT_IS_DOUBLE
    //    return (CGFloat)[NSDecimalNumber decimalNumberWithDecimal:decimalNumber].doubleValue;
    //#else
    //    return (CGFloat)[[NSDecimalNumber decimalNumberWithDecimal:decimalNumber] floatValue];
    //#endif
    //}
    //
    ///**
    // *  @brief Converts an @ref NSDecimal value to an NSString.
    // *  @param decimalNumber The @ref NSDecimal value.
    // *  @return The converted value.
    // **/
    //NSString *__nonnull CPTDecimalStringValue(NSDecimal decimalNumber)
    //{
    //    return [NSDecimalNumber decimalNumberWithDecimal:decimalNumber].stringValue;
    //}
    //
    //#pragma mark -
    //#pragma mark Convert primitive types to NSDecimal
    //
    ///**
    // *  @brief Converts an 8-bit integer value to an @ref NSDecimal.
    // *  @param anInt The integer value.
    // *  @return The converted value.
    // **/
    //NSDecimal CPTDecimalFromChar(int8_t anInt)
    //{
    //    if ((anInt >= 0) && (anInt < kCacheSize)) {
    //        if ( !cacheValueInitialized[anInt] ) {
    //            NSString *stringValue = [[NSString alloc] initWithFormat:@"%hhd", anInt];
    //            cache[anInt] = CPTDecimalFromString(stringValue);
    //
    //            cacheValueInitialized[anInt] = YES;
    //        }
    //        return cache[anInt];
    //    }
    //
    //    NSString *stringValue = [[NSString alloc] initWithFormat:@"%hhd", anInt];
    //    NSDecimal result      = CPTDecimalFromString(stringValue);
    //
    //    return result;
    //}
    //
    ///**
    // *  @brief Converts a 16-bit integer value to an @ref NSDecimal.
    // *  @param anInt The integer value.
    // *  @return The converted value.
    // **/
    //NSDecimal CPTDecimalFromShort(int16_t anInt)
    //{
    //    if ((anInt >= 0) && (anInt < kCacheSize)) {
    //        if ( !cacheValueInitialized[anInt] ) {
    //            NSString *stringValue = [[NSString alloc] initWithFormat:@"%hd", anInt];
    //            cache[anInt] = CPTDecimalFromString(stringValue);
    //
    //            cacheValueInitialized[anInt] = YES;
    //        }
    //        return cache[anInt];
    //    }
    //
    //    NSString *stringValue = [[NSString alloc] initWithFormat:@"%hd", anInt];
    //    NSDecimal result      = CPTDecimalFromString(stringValue);
    //
    //    return result;
    //}
    //
    ///**
    // *  @brief Converts a 32-bit integer value to an @ref NSDecimal.
    // *  @param anInt The integer value.
    // *  @return The converted value.
    // **/
    //NSDecimal CPTDecimalFromLong(int32_t anInt)
    //{
    //    if ((anInt >= 0) && (anInt < kCacheSize)) {
    //        if ( !cacheValueInitialized[anInt] ) {
    //            NSString *stringValue = [[NSString alloc] initWithFormat:@"%d", anInt];
    //            cache[anInt] = CPTDecimalFromString(stringValue);
    //
    //            cacheValueInitialized[anInt] = YES;
    //        }
    //        return cache[anInt];
    //    }
    //
    //    NSString *stringValue = [[NSString alloc] initWithFormat:@"%d", anInt];
    //    NSDecimal result      = CPTDecimalFromString(stringValue);
    //
    //    return result;
    //}
    //
    ///**
    // *  @brief Converts a 64-bit integer value to an @ref NSDecimal.
    // *  @param anInt The integer value.
    // *  @return The converted value.
    // **/
    //NSDecimal CPTDecimalFromLongLong(int64_t anInt)
    //{
    //    if ((anInt >= 0) && (anInt < kCacheSize)) {
    //        if ( !cacheValueInitialized[anInt] ) {
    //            NSString *stringValue = [[NSString alloc] initWithFormat:@"%lld", anInt];
    //            cache[anInt] = CPTDecimalFromString(stringValue);
    //
    //            cacheValueInitialized[anInt] = YES;
    //        }
    //        return cache[anInt];
    //    }
    //
    //    NSString *stringValue = [[NSString alloc] initWithFormat:@"%lld", anInt];
    //    NSDecimal result      = CPTDecimalFromString(stringValue);
    //
    //    return result;
    //}
    //
    ///**
    // *  @brief Converts an @int value to an @ref NSDecimal.
    // *  @param anInt The @int value.
    // *  @return The converted value.
    // **/
    //NSDecimal CPTDecimalFromInt(int anInt)
    //{
    //    if ((anInt >= 0) && (anInt < kCacheSize)) {
    //        if ( !cacheValueInitialized[anInt] ) {
    //            NSString *stringValue = [[NSString alloc] initWithFormat:@"%d", anInt];
    //            cache[anInt] = CPTDecimalFromString(stringValue);
    //
    //            cacheValueInitialized[anInt] = YES;
    //        }
    //        return cache[anInt];
    //    }
    //
    //    NSString *stringValue = [[NSString alloc] initWithFormat:@"%d", anInt];
    //    NSDecimal result      = CPTDecimalFromString(stringValue);
    //
    //    return result;
    //}
    //
    ///**
    // *  @brief Converts an @ref NSInteger value to an @ref NSDecimal.
    // *  @param anInt The @ref NSInteger value.
    // *  @return The converted value.
    // **/
    //NSDecimal CPTDecimalFromInteger(NSInteger anInt)
    //{
    //    if ((anInt >= 0) && (anInt < kCacheSize)) {
    //        if ( !cacheValueInitialized[anInt] ) {
    //            NSString *stringValue = [[NSString alloc] initWithFormat:@"%ld", (long)anInt];
    //            cache[anInt] = CPTDecimalFromString(stringValue);
    //
    //            cacheValueInitialized[anInt] = YES;
    //        }
    //        return cache[anInt];
    //    }
    //
    //    NSString *stringValue = [[NSString alloc] initWithFormat:@"%ld", (long)anInt];
    //    NSDecimal result      = CPTDecimalFromString(stringValue);
    //
    //    return result;
    //}
    //
    ///**
    // *  @brief Converts an unsigned 8-bit integer value to an @ref NSDecimal.
    // *  @param anInt The unsigned integer value.
    // *  @return The converted value.
    // **/
    //NSDecimal CPTDecimalFromUnsignedChar(uint8_t anInt)
    //{
    //    if ( anInt < kCacheSize ) {
    //        if ( !cacheValueInitialized[anInt] ) {
    //            NSString *stringValue = [[NSString alloc] initWithFormat:@"%hhu", anInt];
    //            cache[anInt] = CPTDecimalFromString(stringValue);
    //
    //            cacheValueInitialized[anInt] = YES;
    //        }
    //        return cache[anInt];
    //    }
    //
    //    NSString *stringValue = [[NSString alloc] initWithFormat:@"%hhu", anInt];
    //    NSDecimal result      = CPTDecimalFromString(stringValue);
    //
    //    return result;
    //}
    //
    ///**
    // *  @brief Converts an unsigned 16-bit integer value to an @ref NSDecimal.
    // *  @param anInt The unsigned integer value.
    // *  @return The converted value.
    // **/
    //NSDecimal CPTDecimalFromUnsignedShort(uint16_t anInt)
    //{
    //    if ( anInt < kCacheSize ) {
    //        if ( !cacheValueInitialized[anInt] ) {
    //            NSString *stringValue = [[NSString alloc] initWithFormat:@"%hu", anInt];
    //            cache[anInt] = CPTDecimalFromString(stringValue);
    //
    //            cacheValueInitialized[anInt] = YES;
    //        }
    //        return cache[anInt];
    //    }
    //
    //    NSString *stringValue = [[NSString alloc] initWithFormat:@"%hu", anInt];
    //    NSDecimal result      = CPTDecimalFromString(stringValue);
    //
    //    return result;
    //}
    //
    ///**
    // *  @brief Converts an unsigned 32-bit integer value to an @ref NSDecimal.
    // *  @param anInt The unsigned integer value.
    // *  @return The converted value.
    // **/
    //NSDecimal CPTDecimalFromUnsignedLong(uint32_t anInt)
    //{
    //    if ( anInt < kCacheSize ) {
    //        if ( !cacheValueInitialized[anInt] ) {
    //            NSString *stringValue = [[NSString alloc] initWithFormat:@"%u", anInt];
    //            cache[anInt] = CPTDecimalFromString(stringValue);
    //
    //            cacheValueInitialized[anInt] = YES;
    //        }
    //        return cache[anInt];
    //    }
    //
    //    NSString *stringValue = [[NSString alloc] initWithFormat:@"%u", anInt];
    //    NSDecimal result      = CPTDecimalFromString(stringValue);
    //
    //    return result;
    //}
    //
    ///**
    // *  @brief Converts an unsigned 64-bit integer value to an @ref NSDecimal.
    // *  @param anInt The unsigned integer value.
    // *  @return The converted value.
    // **/
    //NSDecimal CPTDecimalFromUnsignedLongLong(uint64_t anInt)
    //{
    //    if ( anInt < kCacheSize ) {
    //        if ( !cacheValueInitialized[anInt] ) {
    //            NSString *stringValue = [[NSString alloc] initWithFormat:@"%llu", anInt];
    //            cache[anInt] = CPTDecimalFromString(stringValue);
    //
    //            cacheValueInitialized[anInt] = YES;
    //        }
    //        return cache[anInt];
    //    }
    //
    //    NSString *stringValue = [[NSString alloc] initWithFormat:@"%llu", anInt];
    //    NSDecimal result      = CPTDecimalFromString(stringValue);
    //
    //    return result;
    //}
    //
    ///**
    // *  @brief Converts an @uint value to an @ref NSDecimal.
    // *  @param anInt The @uint value.
    // *  @return The converted value.
    // **/
    //NSDecimal CPTDecimalFromUnsignedInt(unsigned int anInt)
    //{
    //    if ( anInt < kCacheSize ) {
    //        if ( !cacheValueInitialized[anInt] ) {
    //            NSString *stringValue = [[NSString alloc] initWithFormat:@"%u", anInt];
    //            cache[anInt] = CPTDecimalFromString(stringValue);
    //
    //            cacheValueInitialized[anInt] = YES;
    //        }
    //        return cache[anInt];
    //    }
    //
    //    NSString *stringValue = [[NSString alloc] initWithFormat:@"%u", anInt];
    //    NSDecimal result      = CPTDecimalFromString(stringValue);
    //
    //    return result;
    //}
    //
    ///**
    // *  @brief Converts an @ref NSUInteger value to an @ref NSDecimal.
    // *  @param anInt The @ref NSUInteger value.
    // *  @return The converted value.
    // **/
    //NSDecimal CPTDecimalFromUnsignedInteger(NSUInteger anInt)
    //{
    //    if ( anInt < kCacheSize ) {
    //        if ( !cacheValueInitialized[anInt] ) {
    //            NSString *stringValue = [[NSString alloc] initWithFormat:@"%lu", (unsigned long)anInt];
    //            cache[anInt] = CPTDecimalFromString(stringValue);
    //
    //            cacheValueInitialized[anInt] = YES;
    //        }
    //        return cache[anInt];
    //    }
    //
    //    NSString *stringValue = [[NSString alloc] initWithFormat:@"%lu", (unsigned long)anInt];
    //    NSDecimal result      = CPTDecimalFromString(stringValue);
    //
    //    return result;
    //}
    //
    ///**
    // *  @brief Converts a @float value to an @ref NSDecimal.
    // *  @param aFloat The @float value.
    // *  @return The converted value.
    // **/
    //NSDecimal CPTDecimalFromFloat(float aFloat)
    //{
    //    if ( isnan(aFloat) || isinf(aFloat)) {
    //        return CPTDecimalNaN();
    //    }
    //    else {
    //        NSString *stringValue = [[NSString alloc] initWithFormat:@"%f", (double)aFloat];
    //        NSDecimal result      = CPTDecimalFromString(stringValue);
    //
    //        return result;
    //    }
    //}
    //
    ///**
    // *  @brief Converts a @double value to an @ref NSDecimal.
    // *  @param aDouble The @double value.
    // *  @return The converted value.
    // **/
    //NSDecimal CPTDecimalFromDouble(double aDouble)
    //{
    //    if ( isnan(aDouble) || isinf(aDouble)) {
    //        return CPTDecimalNaN();
    //    }
    //    else {
    //        NSString *stringValue = [[NSString alloc] initWithFormat:@"%f", aDouble];
    //        NSDecimal result      = CPTDecimalFromString(stringValue);
    //
    //        return result;
    //    }
    //}
    //
    ///**
    // *  @brief Converts a @ref CGFloat value to an @ref NSDecimal.
    // *  @param aCGFloat The @ref CGFloat value.
    // *  @return The converted value.
    // **/
    //NSDecimal CPTDecimalFromCGFloat(CGFloat aCGFloat)
    //{
    //    if ( isnan(aCGFloat) || isinf(aCGFloat)) {
    //        return CPTDecimalNaN();
    //    }
    //    else {
    //        NSString *stringValue = [[NSString alloc] initWithFormat:@"%f", (double)aCGFloat];
    //        NSDecimal result      = CPTDecimalFromString(stringValue);
    //
    //        return result;
    //    }
    //}
    //
    ///**
    // *  @brief Parses a string and extracts the numeric value as an @ref NSDecimal.
    // *  @param stringRepresentation The string value.
    // *  @return The numeric value extracted from the string.
    // **/
    //NSDecimal CPTDecimalFromString(NSString *__nonnull stringRepresentation)
    //{
    //    // The following NSDecimalNumber-based creation of NSDecimal structs from strings is slower than
    //    // the NSScanner-based method: (307000 operations per second vs. 582000 operations per second for NSScanner)
    //
    //    /*    NSDecimalNumber *newNumber = [[NSDecimalNumber alloc] initWithString:@"1.0" locale:[NSLocale currentLocale]];
    //     * newDecimal = [newNumber decimalValue];
    //     * [newNumber release];*/
    //
    //    NSDecimal result;
    //    NSScanner *theScanner = [[NSScanner alloc] initWithString:stringRepresentation];
    //
    //    [theScanner scanDecimal:&result];
    //
    //    return result;
    //}
    //
    //#pragma mark -
    //#pragma mark NSDecimal arithmetic
    //
    ///**
    // *  @brief Adds two @ref NSDecimal structs together.
    // *  @param leftOperand The left-hand side of the addition operation.
    // *  @param rightOperand The right-hand side of the addition operation.
    // *  @return The result of the addition.
    // **/
    //NSDecimal CPTDecimalAdd(NSDecimal leftOperand, NSDecimal rightOperand)
    //{
    //    NSDecimal result;
    //
    //    NSDecimalAdd(&result, &leftOperand, &rightOperand, NSRoundBankers);
    //    return result;
    //}
    //
    ///**
    // *  @brief Subtracts one @ref NSDecimal from another.
    // *  @param leftOperand The left-hand side of the subtraction operation.
    // *  @param rightOperand The right-hand side of the subtraction operation.
    // *  @return The result of the subtraction.
    // **/
    //NSDecimal CPTDecimalSubtract(NSDecimal leftOperand, NSDecimal rightOperand)
    //{
    //    NSDecimal result;
    //
    //    NSDecimalSubtract(&result, &leftOperand, &rightOperand, NSRoundBankers);
    //    return result;
    //}
    //
    ///**
    // *  @brief Multiplies two @ref NSDecimal structs together.
    // *  @param leftOperand The left-hand side of the multiplication operation.
    // *  @param rightOperand The right-hand side of the multiplication operation.
    // *  @return The result of the multiplication.
    // **/
    //NSDecimal CPTDecimalMultiply(NSDecimal leftOperand, NSDecimal rightOperand)
    //{
    //    NSDecimal result;
    //
    //    NSDecimalMultiply(&result, &leftOperand, &rightOperand, NSRoundBankers);
    //    return result;
    //}
    //
    ///**
    // *  @brief Divides one @ref NSDecimal by another.
    // *  @param numerator The numerator of the multiplication operation.
    // *  @param denominator The denominator of the multiplication operation.
    // *  @return The result of the division.
    // **/
    //NSDecimal CPTDecimalDivide(NSDecimal numerator, NSDecimal denominator)
    //{
    //    NSDecimal result;
    //
    //    NSCalculationError calcError = NSDecimalDivide(&result, &numerator, &denominator, NSRoundBankers);
    //
    //    switch ( calcError ) {
    //        case NSCalculationUnderflow:
    //        case NSCalculationDivideByZero:
    //            result = CPTDecimalFromInteger(0);
    //            break;
    //
    //        default:
    //            // no error--return the result of the division
    //            break;
    //    }
    //    return result;
    //}
    //
    //#pragma mark -
    //#pragma mark NSDecimal comparison
    //
    ///**
    // *  @brief Checks to see if one @ref NSDecimal is greater than another.
    // *  @param leftOperand The left side of the comparison.
    // *  @param rightOperand The right side of the comparison.
    // *  @return @YES if the left operand is greater than the right, @NO otherwise.
    // **/
    //BOOL CPTDecimalGreaterThan(NSDecimal leftOperand, NSDecimal rightOperand)
    //{
    //    return NSDecimalCompare(&leftOperand, &rightOperand) == NSOrderedDescending;
    //}
    //
    ///**
    // *  @brief Checks to see if one @ref NSDecimal is greater than or equal to another.
    // *  @param leftOperand The left side of the comparison.
    // *  @param rightOperand The right side of the comparison.
    // *  @return @YES if the left operand is greater than or equal to the right, @NO otherwise.
    // **/
    //BOOL CPTDecimalGreaterThanOrEqualTo(NSDecimal leftOperand, NSDecimal rightOperand)
    //{
    //    return NSDecimalCompare(&leftOperand, &rightOperand) != NSOrderedAscending;
    //}
    //
    ///**
    // *  @brief Checks to see if one @ref NSDecimal is less than another.
    // *  @param leftOperand The left side of the comparison.
    // *  @param rightOperand The right side of the comparison.
    // *  @return @YES if the left operand is less than the right, @NO otherwise.
    // **/
    //BOOL CPTDecimalLessThan(NSDecimal leftOperand, NSDecimal rightOperand)
    //{
    //    return NSDecimalCompare(&leftOperand, &rightOperand) == NSOrderedAscending;
    //}
    //
    ///**
    // *  @brief Checks to see if one @ref NSDecimal is less than or equal to another.
    // *  @param leftOperand The left side of the comparison.
    // *  @param rightOperand The right side of the comparison.
    // *  @return @YES if the left operand is less than or equal to the right, @NO otherwise.
    // **/
    //BOOL CPTDecimalLessThanOrEqualTo(NSDecimal leftOperand, NSDecimal rightOperand)
    //{
    //    return NSDecimalCompare(&leftOperand, &rightOperand) != NSOrderedDescending;
    //}
    //
    ///**
    // *  @brief Checks to see if one @ref NSDecimal is equal to another.
    // *  @param leftOperand The left side of the comparison.
    // *  @param rightOperand The right side of the comparison.
    // *  @return @YES if the left operand is equal to the right, @NO otherwise.
    // **/
    //BOOL CPTDecimalEquals(NSDecimal leftOperand, NSDecimal rightOperand)
    //{
    //    return NSDecimalCompare(&leftOperand, &rightOperand) == NSOrderedSame;
    //}
    //
    //#pragma mark -
    //#pragma mark NSDecimal utilities
    //
    ///**
    // *  @brief Creates and returns an @ref NSDecimal struct that represents the value @quote{not a number} (@NAN).
    // *
    // *  Calling @ref NSDecimalIsNotANumber() on this value will return @YES.
    // *
    // *  @return An @ref NSDecimal struct that represents the value @quote{not a number} (@NAN).
    // **/
    //NSDecimal CPTDecimalNaN(void)
    //{
    //    return [NSDecimalNumber notANumber].decimalValue;
    //}
    //
    ///**
    // *  @brief Determines the smaller of two @ref NSDecimal values.
    // *  @param leftOperand The first value to compare.
    // *  @param rightOperand The second value to compare.
    // *  @return The smaller of the two arguments.
    // **/
    //NSDecimal CPTDecimalMin(NSDecimal leftOperand, NSDecimal rightOperand)
    //{
    //    if ( NSDecimalIsNotANumber(&leftOperand)) {
    //        return rightOperand;
    //    }
    //    else if ( NSDecimalIsNotANumber(&rightOperand)) {
    //        return leftOperand;
    //    }
    //    else if ( NSDecimalCompare(&leftOperand, &rightOperand) == NSOrderedAscending ) {
    //        return leftOperand;
    //    }
    //    else {
    //        return rightOperand;
    //    }
    //}
    //
    ///**
    // *  @brief Determines the larger of two @ref NSDecimal values.
    // *  @param leftOperand The first value to compare.
    // *  @param rightOperand The second value to compare.
    // *  @return The larger of the two arguments.
    // **/
    //NSDecimal CPTDecimalMax(NSDecimal leftOperand, NSDecimal rightOperand)
    //{
    //    if ( NSDecimalIsNotANumber(&leftOperand)) {
    //        return rightOperand;
    //    }
    //    else if ( NSDecimalIsNotANumber(&rightOperand)) {
    //        return leftOperand;
    //    }
    //    else if ( NSDecimalCompare(&leftOperand, &rightOperand) == NSOrderedDescending ) {
    //        return leftOperand;
    //    }
    //    else {
    //        return rightOperand;
    //    }
    //}
    //
    ///**
    // *  @brief Determines the absolute value of an @ref NSDecimal value.
    // *  @param value The input value for the calculation.
    // *  @return The absolute value of the argument.
    // **/
    //NSDecimal CPTDecimalAbs(NSDecimal value)
    //{
    //    if ( CPTDecimalGreaterThanOrEqualTo(value, CPTDecimalFromInteger(0))) {
    //        return value;
    //    }
    //    else {
    //        return CPTDecimalMultiply(value, CPTDecimalFromInteger(-1));
    //    }
    //}
    //
    //#pragma mark -
    //#pragma mark Ranges
    //
    ///**
    // *  @brief Expands an NSRange by the given amount.
    // *
    // *  The @par{location} of the resulting NSRange will be non-negative.
    // *
    // *  @param range The NSRange to expand.
    // *  @param expandBy The amount the expand the range by.
    // *  @return The expanded range.
    // **/
    //NSRange CPTExpandedRange(NSRange range, NSInteger expandBy)
    //{
    //    NSInteger loc            = MAX(0, (NSInteger)range.location - expandBy);
    //    NSInteger lowerExpansion = (NSInteger)range.location - loc;
    //    NSInteger length         = MAX(0, (NSInteger)range.length + lowerExpansion + expandBy);
    //
    //    return NSMakeRange((NSUInteger)loc, (NSUInteger)length);
    //}
    //
    //#pragma mark -
    //#pragma mark Colors
    //
    ///**
    // *  @brief Extracts the color information from a @ref CGColorRef and returns it as a CPTRGBAColor.
    // *
    // *  Supports RGBA and grayscale color spaces.
    // *
    // *  @param color The color.
    // *  @return The RGBA components of the color.
    // **/
    //CPTRGBAColor CPTRGBAColorFromCGColor(__nonnull CGColorRef color)
    //{
    //    CPTRGBAColor rgbColor;
    //
    //    size_t numComponents = CGColorGetNumberOfComponents(color);
    //
    //    if ( numComponents == 2 ) {
    //        const CGFloat *components = CGColorGetComponents(color);
    //        CGFloat all               = components[0];
    //        rgbColor.red   = all;
    //        rgbColor.green = all;
    //        rgbColor.blue  = all;
    //        rgbColor.alpha = components[1];
    //    }
    //    else {
    //        const CGFloat *components = CGColorGetComponents(color);
    //        rgbColor.red   = components[0];
    //        rgbColor.green = components[1];
    //        rgbColor.blue  = components[2];
    //        rgbColor.alpha = components[3];
    //    }
    //
    //    return rgbColor;
    //}
    //





    // MARK: -  Coordinates
    //
    ///**
    // *  @brief Determines the CPTCoordinate that is orthogonal to the one provided.
    // *
    // *  The current implementation is two-dimensional—X is orthogonal to Y and Y is orthogonal to X.
    // *
    // *  @param coord The CPTCoordinate.
    // *  @return The orthogonal CPTCoordinate.
    // **/
    func CPTOrthogonalCoordinate(_ coord: CPTCoordinate) -> CPTCoordinate {
        return (coord == CPTCoordinate.x ? CPTCoordinate.y : CPTCoordinate.x) as! CPTCoordinate
    }
    //
    //#pragma mark -
    // MARK: Quartz pixel-alignment functions
    func CPTAlignPointToUserSpace(_ context: CGContext, _ point: CGPoint) -> CGPoint {
        var point = point
        // Compute the coordinates of the point in device space.
        point = context.convertToDeviceSpace(point)
        
        // Ensure that coordinates are at exactly the corner
        // of a device pixel.
        point.x = CGFloat(round(Double(point.x - CGFloat(0.5))) + CGFloat(0.5))
        point.y = ceil(point.y) - CGFloat(0.5)
        
        // Convert the device aligned coordinate back to user space.
        return context.convertToUserSpace(point)
    }
    
    
    func CPTAlignSizeToUserSpace(_ context: CGContext, _ size: CGSize) -> CGSize {
        var size = size
        // Compute the size in device space.
        size = context.convertToDeviceSpace(size)
        
        // Ensure that size is an integer multiple of device pixels.
        size.width = CGFloat(round(Double(size.width)))
        size.height = CGFloat(round(Double(size.height)))
        
        // Convert back to user space.
        return context.convertToUserSpace(size)
    }

    func CPTAlignRectToUserSpace(context: CGContext , rect : CGRect )-> CGRect
    {
        var rect = context.convertToDeviceSpace(rect);
        
        let oldOrigin = rect.origin;
        
        rect.origin.x   = round(rect.origin.x - CGFloat(0.5));
        rect.size.width = round(oldOrigin.x + rect.size.width - CGFloat(0.5)) - rect.origin.x;
        rect.origin.x  += CGFloat(0.5);
        
        rect.origin.y    = ceil(rect.maxY) - CGFloat(0.5);
        rect.size.height = ceil(oldOrigin.y - CGFloat(0.5) - rect.origin.y);
        
        return context.convertToUserSpace(rect);
    }
    //
    // MARK: Integral Geometry Conversions
    func CPTAlignIntegralPointToUserSpace(_ context: CGContext, _ point: CGPoint) -> CGPoint {
        var point = point
        point = context.convertToDeviceSpace(point)
        
        point.x = CGFloat(round(Double(point.x)))
        point.y = ceil(point.y - CGFloat(0.5))
        
        return context.convertToUserSpace(point)
    }
    
    func CPTAlignIntegralRectToUserSpace(context: CGContext , rect: CGRect )->CGRect
    {
        
        var rect = rect
        rect = context.convertToDeviceSpace(rect);
        
        let oldOrigin = rect.origin;
        
        rect.origin.x   = round(rect.origin.x);
        rect.size.width = round(oldOrigin.x + rect.size.width) - rect.origin.x;
        
        rect.origin.y    = ceil(rect.maxY - CGFloat(0.5));
        rect.size.height = ceil(oldOrigin.y - CGFloat(0.5) - rect.origin.y);
        
        return context.convertToUserSpace(rect);
    }
    
    func CPTAlignBorderedRectToUserSpace(context: CGContext,rect:  CGRect ,  borderLineStyle: CPTLineStyle)-> CGRect
    {
        var borderRect = CGRect.zero
        var contextScale = CGFloat(1.0);
        
        if ( rect.size.height != CGFloat(0.0)) {
            let deviceRect = context.convertToDeviceSpace(rect);
            contextScale = deviceRect.size.height / rect.size.height;
        }
        
        if ( contextScale != CGFloat(1.0)) {
            let borderWidth = borderLineStyle.lineWidth;
            if ((borderWidth > CGFloat(0.0)) && (borderWidth == round(borderWidth))) {
                borderRect = CPTAlignIntegralRectToUserSpace(context: context, rect: rect);
            }
            else {
                borderRect = CPTAlignRectToUserSpace(context: context, rect: rect);
            }
        }
        else {
            borderRect = CPTAlignRectToUserSpace(context: context, rect: rect);
        }
        
        return borderRect;
    }
    //
    // MARK: String formatting for Core Graphics structs
    //
    ///** @brief Creates a string representation of the given point.
    // *  @param point The point.
    // *  @return A string with the format <code> {x, y}</code>.
    // **/
    //    NSString *__nonnull CPTStringFromPoint(CGPoint point)
    //    {
    //        return [NSString stringWithFormat:@"{%g, %g}", (double)point.x, (double)point.y];
    //    }
    
    ///** @brief Creates a string representation of the given size.
    // *  @param size The size.
    // *  @return A string with the format <code> {width, height}</code>.
    // **/
    //    NSString *__nonnull CPTStringFromSize(CGSize size)
    //    {
    //        return [NSString stringWithFormat:@"{%g, %g}", (double)size.width, (double)size.height];
    //    }
    //
    ///** @brief Creates a string representation of the given rectangle.
    // *  @param rect The rectangle.
    // *  @return A string with the format <code> {{x, y}, {width, height}}</code>.
    // **/
    func CPTStringFromRect(rect : CGRect) ->String
    {
        return String( format: "{{%f, %f}, {%f, %f}}", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)
    }
    
    ///** @brief Creates a string representation of the given vector.
    // *  @param vector The vector.
    // *  @return A string with the format <code> {dx, dy}</code>.
    // **/
    func CPTStringFromVector(vector:CGVector )->String
    {
        //        return String stringWithFormat:@"{%g, %g}", Double(vector.dx), Double(vector.dy))
        return String(format: "{%f, %f}", Double(vector.dx), Double(vector.dy))
    }
    
    
    // MARK: CGPoint utilities
    //
    ///** @brief Computes the square of the distance between two points.
    // *  @param point1 The first point.
    // *  @param point2 The second point.
    // *  @return The square of the distance between the two points.
    // **/
    func squareOfDistanceBetweenPoints( point1: CGPoint, point2: CGPoint)-> CGFloat
    {
        let deltaX          = point1.x - point2.x;
        let deltaY          = point1.y - point2.y;
        let distanceSquared = deltaX * deltaX + deltaY * deltaY;
        
        return distanceSquared;
    }
    
    
    // MARK: Edge Inset Utilities
    ///** @brief Returns a CPTEdgeInsets struct with the given insets.
    // *  @param top The top inset.
    // *  @param left The left inset.
    // *  @param bottom The bottom inset.
    // *  @param right The right inset.
    // *  @return A CPTEdgeInsets struct with the given insets.
    // **/
    func  CPTEdgeInsetsMake(top : CGFloat, left: CGFloat , bottom: CGFloat , right: CGFloat ) -> NSEdgeInsets
    {
        var insets = NSEdgeInsets ()
    
        insets.top    = top;
        insets.left   = left;
        insets.bottom = bottom;
        insets.right  = right;
    
        return insets;
    }
    //
    ///** @brief Compares two CPTEdgeInsets structstructs.
    // *  @param insets1 The first inset.
    // *  @param insets2 The second inset.
    // *  @return @YES if the two CPTEdgeInsets structs are equal.
    // **/
    func CPTEdgeInsetsEqualToEdgeInsets(insets1: CPTEdgeInsets, insets2: CPTEdgeInsets)-> Bool
    {
        return (insets1.top == insets2.top) &&
            (insets1.left == insets2.left) &&
            (insets1.bottom == insets2.bottom) &&
            (insets1.right == insets2.right);
    }
    
    // MARK: Log Modulus
    
    ///** @brief Computes the log modulus of the given value.
    // *  @param value The value.
    // *  @return The log modulus of the given value.
    // *  @see <a href="https://blogs.sas.com/content/iml/2014/07/14/log-transformation-of-pos-neg.html">A log transformation of positive and negative values</a> for more information about the log-modulus transformation.
    // **/
    func CPTLogModulus(_ value: Double) -> Double {
        if value != 0.0 {
            let sign = (value.signbit()) ? -1.0 : +1.0
            
            return Double(sign * Double(log10(abs(CGFloat(value)) + CGFloat(1.0))))
        } else {
            return 0.0
        }
    }
    
    ///** @brief Computes the inverse log modulus of the given value.
    // *  @param value The value.
    // *  @return The inverse log modulus of the given value.
    // **/
    func CPTInverseLogModulus(value: Double)-> Double
    {
        if ( value != 0.0 ) {
            let sign = ((value.signbit()) ? -1.0 : +1.0)
            return sign * (pow(10.0, fabs(value)) - 1.0)
        }
        else {
            return 0.0
        }
    }

}

protocol Signable {
    init()
    static func <(lhs:Self, rhs:Self) -> Bool
    static func >(lhs:Self, rhs:Self) -> Bool
    static func >=(lhs:Self, rhs:Self) -> Bool
}

extension Signable {
    func signbit() -> Bool {
        return (self >= Self() ? true : false)
    }
}


extension Int: Signable { }    // already have < and init() functions, OK
extension Int8 : Signable { }  // ...
extension Int16 : Signable { }
extension Int32 : Signable { }
extension Int64 : Signable { }

/* extend floating point types to Signable */
extension Double : Signable { }
extension Float : Signable { }
extension CGFloat : Signable { }
