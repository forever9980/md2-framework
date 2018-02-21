package de.wwu.md2.framework.generator.ios.controller

import de.wwu.md2.framework.generator.ios.Settings
import de.wwu.md2.framework.generator.ios.util.IOSGeneratorUtil
import de.wwu.md2.framework.generator.ios.view.IOSView
import de.wwu.md2.framework.generator.ios.workflow.IOSWorkflow
import de.wwu.md2.framework.generator.util.DataContainer
import de.wwu.md2.framework.mD2.App
import de.wwu.md2.framework.mD2.ReferencedModelType
import de.wwu.md2.framework.mD2.RemoteConnection
import de.wwu.md2.framework.mD2.Style
import de.wwu.md2.framework.mD2.ViewFrame
import java.lang.invoke.MethodHandles

/**
 * Generate the main MD2Controller class.
 */
class IOSController {
	
	/**
	 * The class name.
	 */
	static var className = ""
	
	/**
	 * Flag whether any content provider communicates with a remote web service.
	 */
	static var hasRemoteContentProviders = false
	
	/**
	 * Generates the Swift type. Prepares the class generation and calls the template.
	 * 
	 * @param data The preprocessed MD2 model.
	 * @param app The app to generate a controller for.
	 * @return The file content.
	 */
	def static generateStartupController(DataContainer data, App app) {
		className = Settings.PREFIX_GLOBAL + "Controller"
		
		hasRemoteContentProviders = data.contentProviders.exists[ c |
			c.type instanceof ReferencedModelType
			&& !c.local
		]
			
		generateClassContent(data, app)
	} 
	
	/**
	 * Template to output the main MD2 controller type.
	 * 
	 * @param data The preprocessed MD2 model.
	 * @param app The app to generate a controller for.
	 * @return The file content.
	 */
	def static generateClassContent(DataContainer data, App app) '''
«IOSGeneratorUtil.generateClassHeaderComment(className, MethodHandles.lookup.lookupClass)»

import UIKit

/// Main controller class to set up and start the app
class MD2Controller {

    /**
    Main function that sets up the app. This includes creating and registering all view elements, content providers and workflows elements. 
    Finally the initial workflow element selection screen is created to trigger the app flow.
    
    :param window The device screen object to render the views.
    */
    func run(window: UIWindow) {
        // Initialize the widget registry
        var widgetRegistry = MD2WidgetRegistry.instance

		/***************************************************
		 * 
		 * Initialize all view elements
		 * 
		 ***************************************************/
		«««Only root view containers for views within the app»»
		«val relevantRootViews = data.view.eAllContents.filter(ViewFrame).toList» «««data.extractRootViews(app.workflowElements.map[wfe | wfe.workflowElementReference ]).values.flatten »»»
        «FOR view : relevantRootViews»
        // View: «view.name»
        «IOSView.generateView(view, data.view.eAllContents.filter(Style).toList)»
        «ENDFOR»
        
    	/***************************************************
		 * 
		 * Initialize content providers
		 * 
		 ***************************************************/
		«FOR contentProvider: data.contentProviders»
		MD2ContentProviderRegistry.instance.addContentProvider("«contentProvider.name»", 
			provider: «Settings.PREFIX_CONTENT_PROVIDER + contentProvider.name.toFirstUpper»(
			content: «Settings.PREFIX_ENTITY + (contentProvider.type as ReferencedModelType).entity.name.toFirstUpper»()))
        «ENDFOR»
        
		«IF hasRemoteContentProviders»
		// There are remote content providers -> Check for model version
		«FOR connection : data.controller.controllerElements.filter(RemoteConnection)»
		    if !MD2RestClient.instance.testModelVersion("«data.main.modelVersion»", basePath: "«connection.uri»") {
		       	fatalError("The data model version is not supported by the backend (or the server could not be reached): «connection.uri»")
		    }
		«ENDFOR»
		«ENDIF»
        
        /***************************************************
		 * 
		 * Initialize view manager and all views
		 * 
		 ***************************************************/
        var viewManager = MD2ViewManager.instance
        viewManager.window = window
        
        «FOR rootView : relevantRootViews»
        viewManager.setupView("«rootView.name.toFirstUpper»", view: «rootView.name.toFirstLower»)
        «ENDFOR»
        
        /***************************************************
		 * 
		 * Initialize workflow elements
		 * 
		 ***************************************************/
        
        «IOSWorkflow.generateWorkflowElements(app.workflowElements)»
        
        // Register workflow events
        «IOSWorkflow.generateWorkflowEventRegistration(data.workflow.workflowElementEntries)»
        
        /***************************************************
		 * 
		 * Initial workflow selection
		 * 
		 ***************************************************/
		
		// Show start screen
		MD2WorkflowManager.instance.generateStartScreen() 
		
		println("[Controller] Startup completed")
    }
}
	'''
}