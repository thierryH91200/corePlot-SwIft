//
//  CPTTheme.swift
//  corePlot
//
//  Created by thierryH24 on 09/11/2020.
//

import Cocoa

class CPTTheme: NSObject {
    
    
    var graphClass : CPTGraph?
    
    // MARK: Init/Dealloc
    override init()
    {
        graphClass = nil
    }
    
    // MARK: Theme management

//    +(nullable NSArray<Class> *)themeClasses
    func themeClasses() -> Array<Any>
    {
        let  nameSort = NSSortDescriptor( key: : "name",ascending:true, selector:#selector(caseInsensitiveCompare:))

        return [themes.sortedArrayUsingDescriptors:@[nameSort]];
    }
    
    init instancetype)themeNamed:(nullable CPTThemeName)themeName
    {
        CPTTheme *newTheme = nil;

        for ( Class themeClass in themes ) {
            if ( [themeName isEqualToString:[themeClass name]] ) {
                newTheme = [[themeClass alloc] init];
                break;
            }
        }

        return newTheme;
    }

    /** @brief Register a theme class.
     *  @param themeClass Theme class to register.
     **/
    +(void)registerTheme:(nonnull Class)themeClass
    {
        NSParameterAssert(themeClass);

        @synchronized ( self ) {
            if ( !themes ) {
                themes = [[NSMutableSet alloc] init];
            }

            if ( [themes containsObject:themeClass] ) {
                [NSException raise:CPTException format:@"Theme class already registered: %@", themeClass];
            }
            else {
                [themes addObject:themeClass];
            }
        }
    }

    /** @brief The name used for this theme class.
     *  @return The name.
     **/
    +(nonnull CPTThemeName)name
    {
        return NSStringFromClass(self);
    }

   // MARK : Accessors

    -(void)setGraphClass:(nullable Class)newGraphClass
    {
        if ( graphClass != newGraphClass ) {
            if ( ![newGraphClass isSubclassOfClass:[CPTGraph class]] ) {
                [NSException raise:CPTException format:@"Invalid graph class for theme; must be a subclass of CPTGraph"];
            }
            else if ( [newGraphClass isEqual:[CPTGraph class]] ) {
                [NSException raise:CPTException format:@"Invalid graph class for theme; must be a subclass of CPTGraph"];
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
    func applyThemeToGraph(graph: CPTGraph)    {
        
        self.applyThemeToBackground(graph: graph)
        let plotAreaFrame = graph.plotAreaFrame;

        if ( plotAreaFrame ) {
            self.applyThemeToPlotArea(plotAreaFrame: plotAreaFrame)
        }

        let axisSet = graph.axisSet
        if  axisSet != nil  {
            self.applyThemeToAxisSet(axisSet: axisSet)
        }
    }


// MARK: -

 //   @implementation CPTTheme(AbstractMethods)

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
