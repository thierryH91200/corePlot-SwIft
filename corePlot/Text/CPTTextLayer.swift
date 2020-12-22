//
//  CPTTextLayer.swift
//  corePlot
//
//  Created by thierryH24 on 09/11/2020.
//

import AppKit

class CPTTextLayer: CPTBorderedLayer {
    
    let kCPTTextLayerMarginWidth = CGFloat(2.0)
    
    var inTextUpdate = false
    
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
    
    convenience init(text newText: String) {
        self.init(text: newText, style: CPTTextStyle())
    }

    /** @brief Initializes a newly allocated CPTTextLayer object with the provided styled text.
     *  @param newText The styled text to display.
     *  @return The initialized CPTTextLayer object.
     **/
    convenience init(attributedText newText: NSAttributedString) {
        let newStyle = CPTTextStyle(attributes: newText.attributes(at: 0, effectiveRange: nil))
        
        self.init(text: newText.string, style: newStyle)
        attributedText = newText
        
        sizeToFit()
    }
    
    override init(layer: Any)
    {
        super.init(layer: layer)
        
        let theLayer = layer as? CPTTextLayer
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
    
    func textStyle(withAttributes attributes: Dictionary<NSAttributedString.Key, Any>?) -> CPTTextStyle
     {
        
        let newStyle = CPTTextStyle()
        
        // Font
        let styleFont = attributes?[NSAttributedString.Key.font] as? NSFont
        
        if let styleFont = styleFont {
            newStyle.font = styleFont
            newStyle.fontName = styleFont.fontName
            newStyle.fontSize = styleFont.pointSize
        }
        
        // Color
        let styleColor = attributes?[NSAttributedString.Key.foregroundColor] as? NSColor
        
        if let styleColor = styleColor {
            newStyle.color = CPTColor(cgColor: styleColor.cgColor)
        }
        
        // Text alignment and line break mode
        let paragraphStyle = attributes?[NSAttributedString.Key.paragraphStyle] as? NSParagraphStyle
        
        if let paragraphStyle = paragraphStyle {
            newStyle.textAlignment = paragraphStyle.alignment as? CPTTextAlignment
            newStyle.lineBreakMode = paragraphStyle.lineBreakMode
        }
        
        return newStyle
    }

    
    //MARK: - Layout
    func sizeThatFits() -> CGSize
    {
        var textSize  = CGSize()
        var myText = self.text
        
        if  myText.count > 0  {
            let styledText = self.attributedText
            if ( styledText.length > 0 ) {
                textSize = styledText.sizeAsDrawn()
            }
            else
            {
                textSize = myText.sizeWithTextStyle(self.textStyle)
                
                textSize = myText.size(withTextStyle: textStyle)
            }
            
            // Add small margin
            textSize.width += kCPTTextLayerMarginWidth * CGFloat(2.0);
            textSize.width  = ceil(textSize.width);
            
            textSize.height += kCPTTextLayerMarginWidth * CGFloat(2.0);
            textSize.height  = ceil(textSize.height);
        }
        
        return textSize;
    }
    
    /**
     *  @brief Resizes the layer to fit its contents leaving a narrow margin on all four sides.
     **/
    func sizeToFit()
    {
        if ( self.text.count > 0 ) {
            let sizeThatFits = self.sizeThatFits()
            var newBounds    = self.bounds;
            newBounds.size         = sizeThatFits;
            newBounds.size.width  += self.paddingLeft + self.paddingRight;
            newBounds.size.height += self.paddingTop + self.paddingBottom;
            
            let myMaxSize = self.maximumSize;
            if  myMaxSize.width > CGFloat(0.0) {
                newBounds.size.width = min(newBounds.size.width, myMaxSize.width);
            }
            if ( myMaxSize.height > CGFloat(0.0)) {
                newBounds.size.height = min(newBounds.size.height, myMaxSize.height);
            }
            
            newBounds.size.width  = ceil(newBounds.size.width);
            newBounds.size.height = ceil(newBounds.size.height);
            
            self.bounds = newBounds;
            self.setNeedsLayout()
            self.setNeedsDisplay()
        }
    }
}
