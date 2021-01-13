//
//  CPTTheme.swift
//  corePlot
//
//  Created by thierryH24 on 09/11/2020.
//

import AppKit

//typedef NSString *CPTThemeName cpt_swift_struct;
//
///// @ingroup themeNames
///// @{
//extern CPTThemeName __nonnull const kCPTDarkGradientTheme; ///< A graph theme with dark gray gradient backgrounds and light gray lines.
//extern CPTThemeName __nonnull const kCPTPlainBlackTheme;   ///< A graph theme with black backgrounds and white lines.
//extern CPTThemeName __nonnull const kCPTPlainWhiteTheme;   ///< A graph theme with white backgrounds and black lines.
//extern CPTThemeName __nonnull const kCPTSlateTheme;        ///< A graph theme with colors that match the default iPhone navigation bar, toolbar buttons, and table views.
//extern CPTThemeName __nonnull const kCPTStocksTheme;       ///< A graph theme with a gradient background and white lines.
///// @}


class CPTTheme: NSObject {

    var graphClass : CPTGraph?
    
    private var themes: Set<CPTTheme>? = nil
    typealias CPTThemeName = String
    
    // MARK: Init/Dealloc
    override init()
    {
        graphClass = nil
    }
    
    // MARK: Theme management
    func themeClasses() -> Array<Any>
    {
//        let  nameSort = NSSortDescriptor( key: "name",ascending:true, selector:#selector(caseInsensitiveCompare:))
        
        return themes?.sorted
    }
    
//    +(nullable instancetype)themeNamed:(nullable CPTThemeName)themeName
//    {
//        CPTTheme *newTheme = nil;
//
//        for ( Class themeClass in themes ) {
//            if ( [themeName isEqualToString:[themeClass name]] ) {
//                newTheme = [[themeClass alloc] init];
//                break;
//            }
//        }
//        return newTheme;
//    }
    class func themeNamed(_ themeName: CPTThemeName?) -> CPTTheme? {
        
        var newTheme: CPTTheme?

        for themeClass in themes! {
            if themeName?.isEqual(toString: themeClass.name()) != nil {
                newTheme = themeClass.init() as? CPTTheme
                break
            }
        }
        return newTheme
    }
    
    
    init (themeNamed: CPTThemeName)
    {
        let newTheme : CPTTheme?
        
        for  themeClass in themes!  {
            if ( themeName isEqualToString:[themeClass.name]] ) {
                newTheme = [[themeClass alloc] init];
                break;
            }
        }
    }
    
    // MARK : Accessors
    func setGraphClass(newGraphClass: AnyClass?)
    {
        if graphClass != newGraphClass ) {
            if ( !newGraphClass isSubclassOfClass:[CPTGraph class] ) {
                print("NSException raise:CPTException format:@ Invalid graph class for theme; must be a subclass of CPTGraph")
            }
            else if ( newGraphClass is CPTGraph ) {
                print("NSException raise:CPTException format:@Invalid graph class for theme; must be a subclass of CPTGraph")
            }
            else {
                graphClass = newGraphClass;
            }
        }
    }
    
    // MARK: apply the theme
    /** @brief Applies the theme to the provided graph.
     *  @param graph The graph to style.
     **/
    func applyThemeToGraph(graph: CPTGraph?)    {
        
        self.applyThemeToBackground(graph: graph!)
        let plotAreaFrame = graph?.plotAreaFrame
        
        if (( plotAreaFrame ) != nil) {
            self.applyThemeToPlotArea(plotAreaFrame: plotAreaFrame!)
        }
        
        let axisSet = graph?.axisSet
        if  axisSet != nil  {
            self.applyThemeToAxisSet(axisSet: axisSet!)
        }
    }
    
    
    // MARK: - implementation CPTTheme(AbstractMethods)
    
    /** @brief Creates a new graph styled with the theme.
     *  @return The new graph.
     **/
    func newGraph() -> Any?
    {
        return nil
    }
    
    func applyThemeToBackground(graph: CPTGraph)
    {
    }
    
    /** @brief Applies the theme to the provided plot area.
     *  @param plotAreaFrame The plot area to style.
     **/
    func applyThemeToPlotArea( plotAreaFrame: CPTPlotAreaFrame)
    {
    }
    
    /** @brief Applies the theme to the provided axis set.
     *  @param axisSet The axis set to style.
     **/
    func applyThemeToAxisSet(axisSet: CPTAxisSet)
    {
    }
}
