package de.wwu.md2.framework.generator.ios

import de.wwu.md2.framework.generator.AbstractPlatformGenerator
import de.wwu.md2.framework.generator.IExtendedFileSystemAccess
import de.wwu.md2.framework.generator.ios.controller.IOSController
import de.wwu.md2.framework.generator.ios.controller.IOSCustomAction
import de.wwu.md2.framework.generator.ios.misc.DataModel
import de.wwu.md2.framework.generator.ios.misc.ProjectBundle
import de.wwu.md2.framework.generator.ios.misc.TestTarget
import de.wwu.md2.framework.generator.ios.model.IOSContentProvider
import de.wwu.md2.framework.generator.ios.model.IOSEntity
import de.wwu.md2.framework.generator.ios.model.IOSEnum
import de.wwu.md2.framework.generator.ios.util.IOSGeneratorUtil
import de.wwu.md2.framework.generator.ios.view.WidgetMapping
import de.wwu.md2.framework.generator.ios.workflow.IOSWorkflowEvent
import de.wwu.md2.framework.generator.util.MD2GeneratorUtil
import de.wwu.md2.framework.mD2.CustomAction
import de.wwu.md2.framework.mD2.SimpleType

import static de.wwu.md2.framework.generator.ios.Settings.*
import static de.wwu.md2.framework.util.MD2Util.*
import de.wwu.md2.framework.generator.preprocessor.SmartphonePreprocessor
import de.wwu.md2.framework.generator.util.DataContainer

/**
 * Main generator class for the Swift-iOS generation process. 
 */
class IOSGenerator extends AbstractPlatformGenerator {
	
	//var rootFolder = "" // Override super type property
	
	/**
	 * Central generation method for the Swift-iOS generator.
	 */
	override doGenerate(IExtendedFileSystemAccess fsa) {
		System.out.println("START GENERATION")
		
		// Apply device class preprocessing
		processedInput = SmartphonePreprocessor.getPreprocessedModel(processedInput)
		dataContainer = new DataContainer(processedInput);
		
		/***************************************************
		 * 
		 * Generate apps
		 * 
		 ***************************************************/
		for (app : dataContainer.apps) {
			// Folders
			Settings.APP_NAME = app.name.replace(".", "-").toLowerCase
			val appRoot = rootFolder + "/" + Settings.APP_NAME + "." + Settings.PLATFORM_PREFIX + "/"
			val rootFolder = appRoot + Settings.APP_NAME + "/"
			IOSGeneratorUtil.printDebug("Generate App: " + rootFolder, true)
			
			// Settings used within the project
			Settings.XCODE_TARGET_APP = Settings.APP_NAME
			Settings.XCODE_TARGET_TEST = Settings.APP_NAME + "Tests"
			Settings.ROOT_FOLDER = rootFolder
			
			/***************************************************
			 * 
			 * Copy static part in target folder
			 * 
			 ***************************************************/
			//FileSystemUtil.createParentDirs(new File(targetFolderAbsolutePath)) // ensure path exists
			IOSGeneratorUtil.printDebug("Copy library files with static code: " + Settings.PLATFORM_PREFIX + "/" + Settings.STATIC_CODE_PATH + "iosLib.zip" + " -> " + rootFolder)
			extractArchive(getSystemResource(Settings.PLATFORM_PREFIX + "/" + Settings.STATIC_CODE_PATH + "iosLib.zip"), rootFolder, fsa)
				
			val targetFolderTestsPath = appRoot + Settings.XCODE_TARGET_TEST + "/";
			IOSGeneratorUtil.printDebug("Copy test project files with test code: " + Settings.PLATFORM_PREFIX + "/" + Settings.TEST_CODE_PATH + "iosTest.zip" + " -> " + targetFolderTestsPath)
			extractArchive(getSystemResource(Settings.PLATFORM_PREFIX + "/" + Settings.TEST_CODE_PATH + "iosTest.zip"), targetFolderTestsPath, fsa)
			
			/***************************************************
			 * 
			 * Misc 
			 * Data model, project file, tests
			 * 
			 ***************************************************/
			IOSGeneratorUtil.printDebug("Generate project-related files", true)
			
			// Generate data model for local storage
			val entities = dataContainer.entities
			val pathDataModel = rootFolder + Settings.MODEL_PATH 
				+ "datastore/LocalData.xcdatamodeld/LocalData.xcdatamodel/contents"
			fsa.generateFile(pathDataModel, DataModel.generateClass(entities))
			
			// Generate files for Xcode 6.3 project bundle
			// Use app root to generate project file outside of the implementation classes!
			val pathProjectBundle = appRoot + Settings.APP_NAME + ".xcodeproj/"
			
			// Project file
			IOSGeneratorUtil.printDebug("Generate project resource file", pathProjectBundle + "project.pbxproj")
			fsa.generateFile(pathProjectBundle + "project.pbxproj", ProjectBundle.generateProjectFile(dataContainer, app))  
			
			// Xcode user data
			IOSGeneratorUtil.printDebug("Generate project user data", pathProjectBundle + "xcuserdata/" + Settings.XCODE_USER_NAME + ".xcuserdatad/") 
			fsa.generateFile(pathProjectBundle + "xcuserdata/" + Settings.XCODE_USER_NAME + ".xcuserdatad/xcschemes/xcschememanagement.plist", ProjectBundle.generateXcschememanagement)
			fsa.generateFile(pathProjectBundle + "xcuserdata/" + Settings.XCODE_USER_NAME + ".xcuserdatad/xcschemes/" + Settings.APP_NAME + ".xcscheme", ProjectBundle.generateXcscheme)
			
			// Xcode workspace
			IOSGeneratorUtil.printDebug("Generate project workspace", pathProjectBundle + "project.xcworkspace/contents.xcworkspacedata") 
			fsa.generateFile(pathProjectBundle + "project.xcworkspace/contents.xcworkspacedata", ProjectBundle.generateWorkspaceContent)  
			
			// Generate (dummy) Test Target Files
			val pathTestTarget = appRoot + Settings.XCODE_TARGET_TEST + "/"
			IOSGeneratorUtil.printDebug("Generate test target", pathTestTarget + Settings.XCODE_TARGET_TEST + ".swift")
			fsa.generateFile(pathTestTarget + Settings.XCODE_TARGET_TEST + ".swift", TestTarget.generateClass())  
			
			/***************************************************
			 * 
			 * Model
			 * 
			 ***************************************************/
			IOSGeneratorUtil.printDebug("Generate Model: " + rootFolder + Settings.MODEL_PATH, true)
			 
			// Generate all model entities
			entities.forEach [entity | 
				val path = rootFolder + Settings.MODEL_PATH + "entity/" 
					+ Settings.PREFIX_ENTITY + entity.name.toFirstUpper + ".swift"
				IOSGeneratorUtil.printDebug("Generate entity: " + entity.name.toFirstUpper, path)
				fsa.generateFile(path, IOSEntity.generateClass(entity))
			]
			
			// Generate all model enums
			dataContainer.enums.forEach [enum | 
				val path = rootFolder + Settings.MODEL_PATH + "enum/" 
					+ Settings.PREFIX_ENUM + enum.name.toFirstUpper + ".swift"
				IOSGeneratorUtil.printDebug("Generate entity: " + enum.name.toFirstUpper, path)
				fsa.generateFile(path, IOSEnum.generateClass(enum))
			]
			
			// Generate content providers
			dataContainer.contentProviders.forEach [ cp |
				val path = rootFolder + Settings.MODEL_PATH + "contentProvider/"  
					+ Settings.PREFIX_CONTENT_PROVIDER + cp.name.toFirstUpper + ".swift"
				
				if (!(cp.type instanceof SimpleType)) {
					IOSGeneratorUtil.printDebug("Generate content provider: " 
						+ cp.name.toFirstUpper, path)
					println(path)
					fsa.generateFile(path, IOSContentProvider.generateClass(cp))
				}
			]
			
			/***************************************************
			 * 
			 * View
			 * 
			 ***************************************************/
			IOSGeneratorUtil.printDebug("Generate Views: " + rootFolder 
				+ Settings.VIEW_PATH, true)
				
			// Generate WidgetMapping
			/* iOS specific class because widgets cannot pass any information
			 * on event triggering except for an integer value. This iOS-enum
			 * provides the mapping between a view element and such a value 
			 * for identification in the event handlers.
			 */
			val pathWidgetMapping = rootFolder + Settings.VIEW_PATH 
				+ Settings.PREFIX_GLOBAL + "WidgetMapping.swift"
			IOSGeneratorUtil.printDebug("Generate view mapping", pathWidgetMapping)
			fsa.generateFile(pathWidgetMapping, WidgetMapping.generateClass(dataContainer.view, app.workflowElements.filter[wfe | wfe.startable == true]))

			/***************************************************
			 * 
			 * Controller
			 * 
			 ***************************************************/
		 	IOSGeneratorUtil.printDebug("Generate Controller: " + rootFolder 
			 	+ Settings.CONTROLLER_PATH, true)
			 
			app.workflowElements.forEach [wfe | 
			 	wfe.workflowElementReference.actions.filter(CustomAction).forEach[ ca |
			 		val path = rootFolder + Settings.CONTROLLER_PATH + "action/" 
						+ Settings.PREFIX_CUSTOM_ACTION 
						+ MD2GeneratorUtil.getName(ca).toFirstUpper + ".swift"
					IOSGeneratorUtil.printDebug("Generate custom action: " 
						+ MD2GeneratorUtil.getName(ca), path)
					fsa.generateFile(path, IOSCustomAction.generateClass(ca))
			 	]
			]
			 
			val pathMainController = rootFolder + Settings.CONTROLLER_PATH 
				+ Settings.PREFIX_GLOBAL + "Controller.swift"
			IOSGeneratorUtil.printDebug("Generate main controller: " 
				+ pathMainController, false)
			fsa.generateFile(pathMainController, IOSController.generateStartupController(dataContainer, app))
			
			/***************************************************
			 * 
			 * Workflow
			 * 
			 ***************************************************/
			IOSGeneratorUtil.printDebug("Generate Workflows: " + rootFolder 
			 	+ Settings.WORKFLOW_PATH, true)
			
			val pathWorkflowEvents = rootFolder + Settings.WORKFLOW_PATH 
				+ Settings.PREFIX_GLOBAL + "WorkflowEvent.swift"
			IOSGeneratorUtil.printDebug("Generate workflow events", pathWorkflowEvents) 		
 		 	fsa.generateFile(pathWorkflowEvents, IOSWorkflowEvent.generateClass(dataContainer))
				
		}

		println("\nIOS GENERATION COMPLETED\n")
	}

	/**
	 * We are generating for iOS.
	 */
	override getPlatformPrefix() {
		Settings.PLATFORM_PREFIX
	}
}