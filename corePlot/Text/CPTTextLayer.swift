//
//  CPTTextLayer.swift
//  corePlot
//
//  Created by thierryH24 on 09/11/2020.
//

import Cocoa

class CPTTextLayer: CPTBorderedLayer {

    let kCPTTextLayerMarginWidth = CGFloat(2.0)
    
    var inTextUpdate = false
    var attributedText = NSAttributedString()
    
    private lazy var _attributedText = NSAttributedString()
    override var attributedText: NSAttributedString {
        get { return _attributedText }
        set { _attributedText = newValue }
    }
    private lazy var _textStyle = CPTTextStyle()
    override var textStyle: CPTTextStyle {
        get { return _textStyle }
        set { _textStyle = newValue }
    }
    private lazy var _text = ""
    override var text: String {
        get { return _text }
        set { _text = newValue }
    }
    private lazy var _maximumSize = CGSize()
    override var maximumSize: CGSize {
        get { return _maximumSize }
        set { _maximumSize = newValue }
    }

    convenience init(text newText: String?, style newStyle: CPTTextStyle?) {
        self.init(frame: CGRect())
        textStyle = newStyle!
        text = newText!

        sizeToFit()
    }
    
    
    init(newText: String)
    {
        self.init(text : newText, style: textStyle)
    }

    /** @brief Initializes a newly allocated CPTTextLayer object with the provided styled text.
     *  @param newText The styled text to display.
     *  @return The initialized CPTTextLayer object.
     **/
    init WithAttributedText:(newText: NSAttributedString )
    {
        CPTTextStyle *newStyle = [CPTTextStyle textStyleWithAttributes:[newText attributesAtIndex:0 effectiveRange:NULL]];

        if ((self = [self initWithText:newText.string style:newStyle])) {
            attributedText = newText

    self.sizeToFit()
        }

    }

    init(layer: Any?)
    {
        let theLayer = layer as? CPTTextLayer
        super.init(layer: theLayer!)
        
        textStyle      = theLayer!.textStyle;
        text           = theLayer!.text
        attributedText = theLayer!.attributedText;
        inTextUpdate   = theLayer!.inTextUpdate;
    }

    override init(frame:CGRect)
    {
        super.init(frame:frame)
            text           = ""
            textStyle      = CPTTextStyle()
            attributedText = NSAttributedString()
            maximumSize    = CGSize()
            inTextUpdate   = false

            self.needsDisplayOnBoundsChange = false;
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Layout
    func sizeThatFits() -> CGSize
    {
        let textSize  = CGSize()
        var myText = self.text

        if ( myText.length > 0 ) {
            let styledText = self.attributedText
            if ( styledText.length > 0 ) {
                textSize = [styledText sizeAsDrawn];
            }
            else {
                textSize = myText (sizeWithTextStyle:self.textStyle)
            }

            // Add small margin
            textSize.width += kCPTTextLayerMarginWidth * CPTFloat(2.0);
            textSize.width  = ceil(textSize.width);

            textSize.height += kCPTTextLayerMarginWidth * CPTFloat(2.0);
            textSize.height  = ceil(textSize.height);
        }

        return textSize;
    }

    /**
     *  @brief Resizes the layer to fit its contents leaving a narrow margin on all four sides.
     **/
    func sizeToFit()
    {
        if ( self.text.length > 0 ) {
            let sizeThatFits = self.sizeThatFits()
            let newBounds    = self.bounds;
            newBounds.size         = sizeThatFits;
            newBounds.size.width  += self.paddingLeft + self.paddingRight;
            newBounds.size.height += self.paddingTop + self.paddingBottom;

            let myMaxSize = self.maximumSize;
            if  myMaxSize.width > CGFloat(0.0) {
                newBounds.size.width = MIN(newBounds.size.width, myMaxSize.width);
            }
            if ( myMaxSize.height > CPTFloat(0.0)) {
                newBounds.size.height = MIN(newBounds.size.height, myMaxSize.height);
            }

            newBounds.size.width  = ceil(newBounds.size.width);
            newBounds.size.height = ceil(newBounds.size.height);

            self.bounds = newBounds;
            self.setNeedsLayout()
            self.setNeedsDisplay()
        }
    }

}
