//
//  CPTAxisLabel.swift
//  corePlot
//
//  Created by thierryH24 on 16/11/2020.
//

import Cocoa

class CPTAxisLabel: NSObject {
    
    
    var contentLayer: CPTLayer
    var offset: CGFloat = 0.0
    var rotation: CGFloat = 0.0
    var alignment: CPTAlignment?
    var tickLocation = CGFloat(0)
    
    
    
    typealias CPTAxisLabelSet = Set<CPTAxisLabel>
    
    convenience init( newText: String?, newStyle: CPTTextStyle?) {
        
        let newLayer = CPTTextLayer(text: newText, style: newStyle)
        
        self.init(layer: newLayer)
    }
    
    init(layer: CPTLayer)
    {
        super.init()
        contentLayer = layer;
        offset       = CGFloat(20.0);
        rotation     = CGFloat(0.0);
        alignment    = .center
        tickLocation = 0.0;
    }
    
    override init()
    {
        super.init()
//        super.init( newText: nil, newStyle: nil)
    }
    
    func positionRelativeToViewPoint(point: CGPoint, coordinate: CPTCoordinate, inDirection:CPTSign)
    {
        let content = self.contentLayer

        if ( content.identifier == nil) {
            return
        }

        let newPosition = point
        let value      = coordinate == CPTCoordinate.x ? newPosition.x : newPosition.y
        let angle       = CGFloat(0.0);

        var labelRotation = self.rotation;

        if ( isnan(labelRotation)) {
            labelRotation = coordinate == CPTCoordinate.x ? CGFloat(Double.pi/2) : CGFloat(0.0)
        }
        content.transform = CATransform3DMakeRotation(labelRotation, CGFloat(0.0), CGFloat(0.0), CGFloat(1.0))
        let contentFrame = content.frame;

        // Position the anchor point along the closest edge.
        var validDirection = false;

//        switch ( direction ) {
//            case CPTSignNone:
//            case CPTSignNegative:
//                validDirection = YES;
//
//                *value -= self.offset;
//
//                switch ( coordinate ) {
//                    case CPTCoordinateX:
//                        angle = CPTFloat(M_PI);
//
//                        switch ( self.alignment ) {
//                            case CPTAlignmentBottom:
//                                newPosition.y += contentFrame.size.height / CPTFloat(2.0);
//                                break;
//
//                            case CPTAlignmentTop:
//                                newPosition.y -= contentFrame.size.height / CPTFloat(2.0);
//                                break;
//
//                            default: // middle
//                                     // no adjustment
//                                break;
//                        }
//                        break;
//
//                    case CPTCoordinateY:
//                        angle = CPTFloat(-M_PI_2);
//
//                        switch ( self.alignment ) {
//                            case CPTAlignmentLeft:
//                                newPosition.x += contentFrame.size.width / CPTFloat(2.0);
//                                break;
//
//                            case CPTAlignmentRight:
//                                newPosition.x -= contentFrame.size.width / CPTFloat(2.0);
//                                break;
//
//                            default: // center
//                                     // no adjustment
//                                break;
//                        }
//                        break;
//
//                    default:
//                        [NSException raise:NSInvalidArgumentException format:@"Invalid coordinate in positionRelativeToViewPoint:forCoordinate:inDirection:"];
//                        break;
//                }
//                break;
//
//            case CPTSignPositive:
//                validDirection = YES;
//
//                *value += self.offset;
//
//                switch ( coordinate ) {
//                    case CPTCoordinateX:
//                        // angle = 0.0;
//
//                        switch ( self.alignment ) {
//                            case CPTAlignmentBottom:
//                                newPosition.y += contentFrame.size.height / CPTFloat(2.0);
//                                break;
//
//                            case CPTAlignmentTop:
//                                newPosition.y -= contentFrame.size.height / CPTFloat(2.0);
//                                break;
//
//                            default: // middle
//                                     // no adjustment
//                                break;
//                        }
//                        break;
//
//                    case CPTCoordinateY:
//                        angle = CPTFloat(M_PI_2);
//
//                        switch ( self.alignment ) {
//                            case CPTAlignmentLeft:
//                                newPosition.x += contentFrame.size.width / CPTFloat(2.0);
//                                break;
//
//                            case CPTAlignmentRight:
//                                newPosition.x -= contentFrame.size.width / CPTFloat(2.0);
//                                break;
//
//                            default: // center
//                                     // no adjustment
//                                break;
//                        }
//                        break;
//
//                    default:
//                        [NSException raise:NSInvalidArgumentException format:@"Invalid coordinate in positionRelativeToViewPoint:forCoordinate:inDirection:"];
//                        break;
//                }
//                break;
//        }
//
//        if ( !validDirection ) {
//            [NSException raise:NSInvalidArgumentException format:@"Invalid direction in positionRelativeToViewPoint:forCoordinate:inDirection:"];
//        }
//
//        angle += CPTFloat(M_PI);
//        angle -= labelRotation;
//        CGFloat newAnchorX = cos(angle);
//        CGFloat newAnchorY = sin(angle);
//
//        if ( ABS(newAnchorX) <= ABS(newAnchorY)) {
//            newAnchorX /= ABS(newAnchorY);
//            newAnchorY  = signbit(newAnchorY) ? CPTFloat(-1.0) : CPTFloat(1.0);
//        }
//        else {
//            newAnchorY /= ABS(newAnchorX);
//            newAnchorX  = signbit(newAnchorX) ? CPTFloat(-1.0) : CPTFloat(1.0);
//        }
//        CGPoint anchor = CPTPointMake((newAnchorX + CPTFloat(1.0)) / CPTFloat(2.0), (newAnchorY + CPTFloat(1.0)) / CPTFloat(2.0));
//
//        content.anchorPoint = anchor;
//        content.position    = newPosition;
//        [content pixelAlign];
    }

    /** @brief Positions the axis label between two given points.
     *  @param firstPoint The first view point.
     *  @param secondPoint The second view point.
     *  @param coordinate The axis coordinate.
     *  @param direction The offset direction.
     **/
//    -(void)positionBetweenViewPoint:(CGPoint)firstPoint andViewPoint:(CGPoint)secondPoint forCoordinate:(CPTCoordinate)coordinate inDirection:(CPTSign)direction
//    {
//        [self positionRelativeToViewPoint:CPTPointMake((firstPoint.x + secondPoint.x) / CPTFloat(2.0), (firstPoint.y + secondPoint.y) / CPTFloat(2.0))
//                            forCoordinate:coordinate
//                              inDirection:direction];
//    }
//
//    #pragma mark -
//    #pragma mark Description
//
//    /// @cond
//
//    -(nullable NSString *)description
//    {
//        return [NSString stringWithFormat:@"<%@ {%@}>", super.description, self.contentLayer];
//    }
//
//    /// @endcond
//
//    #pragma mark -
//    #pragma mark Label comparison
//
//    /// @name Comparison
//    /// @{
//
//    /** @brief Returns a boolean value that indicates whether the received is equal to the given object.
//     *  Axis labels are equal if they have the same @ref tickLocation.
//     *  @param object The object to be compared with the receiver.
//     *  @return @YES if @par{object} is equal to the receiver, @NO otherwise.
//     **/
//    -(BOOL)isEqual:(nullable id)object
//    {
//        if ( self == object ) {
//            return YES;
//        }
//        else if ( [object isKindOfClass:[self class]] ) {
//            NSNumber *location = ((CPTAxisLabel *)object).tickLocation;
//
//            if ( location ) {
//                return [self.tickLocation isEqualToNumber:location];
//            }
//            else {
//                return NO;
//            }
//        }
//        else {
//            return NO;
//        }
//    }
//
//    /// @}
//
//    /// @cond
//
//    -(NSUInteger)hash
//    {
//        NSUInteger hashValue = 0;
//
//        // Equal objects must hash the same.
//        double tickLocationAsDouble = self.tickLocation.doubleValue;
//
//        if ( !isnan(tickLocationAsDouble)) {
//            hashValue = (NSUInteger)lrint(fmod(ABS(tickLocationAsDouble), (double)NSUIntegerMax));
//        }
//
//        return hashValue;
//    }
//
//    /// @endcond
//
//    @end

    
}
