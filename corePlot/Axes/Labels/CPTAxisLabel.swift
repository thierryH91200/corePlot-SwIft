//
//  CPTAxisLabel.swift
//  corePlot
//
//  Created by thierryH24 on 16/11/2020.
//

import AppKit

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
    
    func positionRelativeToViewPoint(point: CGPoint, coordinate: CPTCoordinate, direction : CPTSign)
    {
        let content = self.contentLayer
        guard ( content.identifier != nil) else { return  }

        var newPosition = point
        var value      = coordinate == CPTCoordinate.x ? newPosition.x : newPosition.y
        var angle       = CGFloat(0.0);

        var labelRotation = self.rotation;

        if labelRotation.isNaN == true {
            labelRotation = coordinate == CPTCoordinate.x ? CGFloat(Double.pi/2) : CGFloat(0.0)
        }
        content.transform = CATransform3DMakeRotation(labelRotation, CGFloat(0.0), CGFloat(0.0), CGFloat(1.0))
        let contentFrame = content.frame;

        // Position the anchor point along the closest edge.
        var validDirection = false;

        switch ( direction ) {
        case .none:
            fallthrough
        case .negative:
                validDirection = true

                value -= self.offset;

                switch ( coordinate ) {
                case .x:
                    angle = CGFloat.pi
                    
                        switch ( self.alignment ) {
                        case .bottom:
                                newPosition.y += contentFrame.size.height / CGFloat(2.0);
                                break;

                        case .top:
                                newPosition.y -= contentFrame.size.height / CGFloat(2.0);
                                break;

                            default: // middle
                                     // no adjustment
                                break;
                        }
                        break;

                case .y:
                    angle = -CGFloat.pi/2

                        switch ( self.alignment ) {
                        case .left:
                                newPosition.x += contentFrame.size.width / CGFloat(2.0);
                                break;

                        case .right:
                                newPosition.x -= contentFrame.size.width / CGFloat(2.0);
                                break;

                            default: // center
                                     // no adjustment
                                break;
                        }
                        break;

                    default:
                        print("Invalid coordinate in positionRelativeToViewPoint:forCoordinate:inDirection:")
                        break;
                }
                break;

        case .positive:
                validDirection = true

                value += self.offset;

                switch ( coordinate ) {
                case .x:
                        // angle = 0.0;

                        switch ( self.alignment ) {
                        case .bottom:
                                newPosition.y += contentFrame.size.height / CGFloat(2.0);
                                break;

                        case .top:
                                newPosition.y -= contentFrame.size.height / CGFloat(2.0);
                                break;

                            default: // middle
                                     // no adjustment
                                break;
                        }
                        break;

                case .y:
                    angle = CGFloat.pi/2

                        switch ( self.alignment ) {
                        case .left:
                                newPosition.x += contentFrame.size.width / CGFloat(2.0);
                                break;

                        case .right:
                                newPosition.x -= contentFrame.size.width / CGFloat(2.0);
                                break;

                            default: // center
                                     // no adjustment
                                break;
                        }
                        break;

                    default:
                        print("Invalid coordinate in positionRelativeToViewPoint:forCoordinate:inDirection:")
                        break;
                }
                break;
        }

        if validDirection == false {
            print("Invalid direction in positionRelativeToViewPoint:forCoordinate:inDirection:")
        }

        angle += CGFloat.pi
        angle -= labelRotation;
        var newAnchorX = cos(angle);
        var newAnchorY = sin(angle);

        if ( abs(newAnchorX) <= abs(newAnchorY)) {
            newAnchorX /= abs(newAnchorY);
            newAnchorY  = ((newAnchorY.signbit()) != 0) ? CGFloat(-1.0) : CGFloat(1.0);
        }
        else {
            newAnchorY /= abs(newAnchorX);
            newAnchorX  = ((newAnchorX.signbit()) != 0) ? CGFloat(-1.0) : CGFloat(1.0);
        }
        let anchor = CGPoint(x: (newAnchorX + CGFloat(1.0)) / CGFloat(2.0), y: (newAnchorY + CGFloat(1.0)) / CGFloat(2.0));

        content.anchorPoint = anchor;
        content.position    = newPosition;
        content.pixelAlign()
    }

    /** @brief Positions the axis label between two given points.
     *  @param firstPoint The first view point.
     *  @param secondPoint The second view point.
     *  @param coordinate The axis coordinate.
     *  @param direction The offset direction.
     **/
    func positionBetweenViewPoint(firstPoint: CGPoint, secondPoint:CGPoint, coordinate:CPTCoordinate, direction: CPTSign)
    {
        self.positionRelativeToViewPoint ( point: CGPoint(x: (firstPoint.x + secondPoint.x) / CGFloat(2.0), y: (firstPoint.y + secondPoint.y) / CGFloat(2.0)),
                                            coordinate:coordinate,
                                            direction:direction)
    }

//    #pragma mark -
//    #pragma mark Description
//
//    /// @cond
//
    func description() ->String
    {
        return String(format:"<%@ {%@}>", super.description, self.contentLayer);
    }
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
