package de.wwu.md2.framework.generator.ios.workflow

import de.wwu.md2.framework.generator.util.DataContainer
import java.lang.invoke.MethodHandles
import de.wwu.md2.framework.mD2.WorkflowEvent
import de.wwu.md2.framework.generator.ios.util.IOSGeneratorUtil

/**
 * Generates the MD2WorkflowEvent.swift enumeration type.
 */
class IOSWorkflowEvent {
	
	/**
	 * Generates the MD2WorkflowEvent Swift type.
	 * Prepares the class generation by filtering for all workflow events and call the template.
	 * 
	 * @param data The preprocessed data container.
	 * @return The file content.
	 */
	static def generateClass(DataContainer data) {
		val events = data.workflow.workflowElementEntries.map [wfe | 
			wfe.firedEvents.map [ event | 
			 	event.event		
		 	].toList
		].flatten
			 
		return generateClassContent(events)
	}
	
	/**
	 * Template to output the MD2WorkflowEvent type.
	 * 
	 * @param workflowEvents A list of all workflow elements in the MD2 model.
	 * @return The file content.
	 */
	static def generateClassContent(Iterable<WorkflowEvent> workflowEvents) '''
«IOSGeneratorUtil.generateClassHeaderComment("WorkflowEvent", MethodHandles.lookup.lookupClass)»

// Make visible to Objective-C to allow use as Dictionary key (e.g. in MD2WorkflowEventHandler)
@objc
/// Enumaration of all workflow events used throughout the app
enum MD2WorkflowEvent: Int {
	«FOR i : 0..<workflowEvents.length»
	case «workflowEvents.get(i).name.toFirstUpper» = «(i+1)»
    «ENDFOR»
    
    /// Explicit attribute to emulate enum introspection and get the event name
    var description: String {
        switch self {
        «FOR i : 0..<workflowEvents.length»
        case .«workflowEvents.get(i).name.toFirstUpper»: return "«workflowEvents.get(i).name.toFirstUpper»"
    	«ENDFOR»
    	default: return "NotFound"
        }
    }
}
	'''
}