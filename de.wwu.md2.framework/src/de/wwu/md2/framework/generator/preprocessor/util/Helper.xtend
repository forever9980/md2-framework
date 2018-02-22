package de.wwu.md2.framework.generator.preprocessor.util

import de.wwu.md2.framework.mD2.ConditionalEventRef
import de.wwu.md2.framework.mD2.ContentProviderEventRef
import de.wwu.md2.framework.mD2.ContentProviderPath
import de.wwu.md2.framework.mD2.ContentProviderPathEventRef
import de.wwu.md2.framework.mD2.ContentProviderReference
import de.wwu.md2.framework.mD2.EventDef
import de.wwu.md2.framework.mD2.GlobalEventRef
import de.wwu.md2.framework.mD2.LocationProviderPath
import de.wwu.md2.framework.mD2.LocationProviderReference
import de.wwu.md2.framework.mD2.View
import de.wwu.md2.framework.mD2.ViewElementEventRef
import de.wwu.md2.framework.mD2.ViewElementType
import java.util.HashMap
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.util.EcoreUtil

import static extension de.wwu.md2.framework.generator.util.MD2GeneratorUtil.*
import java.security.MessageDigest

/**
 * Provides static MD2 specific helper methods to be used in all preprocessing steps.
 */
class Helper {
	
	/**
	 * Returns a deep copy of a given ViewElementType and adds references to the copies of all its child elements -- along
	 * with references to the original -- to the given hash map.
	 */
	def static ViewElementType copyViewElementType(ViewElementType elem, HashMap<ViewElementType, ViewElementType> map) {
		val copier = new EcoreUtil.Copier
		val newElem = copier.copy(elem) as ViewElementType
		copier.copyReferences
		if (map !== null) {
			// Get all copied child elements in a HashSet with the copy as key and the original as value
			for (entry : copier.entrySet) {
				if (entry.value instanceof ViewElementType) {
					map.put(entry.value as ViewElementType, entry.key as ViewElementType)
				}
			}	
		}		
		newElem
	}
	
	/**
	 * Helper to create a non-ambiguous string representation for events.
	 */
	def static getStringRepresentationOfEvent(EventDef event) {
		switch (event) {
			ViewElementEventRef: {
				var EObject eObject = event.referencedField.resolveViewElement
				
				// support for autogenerated view elements
				var str = if (event.referencedField.path !== null) "." + event.referencedField.path?.tail.getPathTailAsString else ""
				while (!(eObject instanceof View)) {
					if(eObject instanceof ViewElementType) {
						str = "." + (eObject as ViewElementType).name + str
					}
					eObject = eObject.eContainer
				}
				"__gui" + str + "." + event.event.toString
			}
			ContentProviderPathEventRef: {
				val path = event.pathDefinition
				switch (path) {
					ContentProviderPath: "__contentProvider." + path.contentProviderRef.name + "." + path.tail.pathTailAsString + "." + event.event.toString
					LocationProviderPath: "__contentProvider.location." + path.locationField.toString
				}
			}
			ContentProviderEventRef: {
				val contentProviderRef = event.contentProvider
				switch (contentProviderRef) {
					ContentProviderReference: "__contentProvider." + contentProviderRef.contentProvider.name + "." + event.event.toString
					LocationProviderReference: "__contentProvider.location"
				}
			}
			GlobalEventRef: "__global." + event.event.toString
			ConditionalEventRef: "__conditional." + event.eventReference.name
		}
	}
	
	def static String sha1Hex(String input){
		val mDigest = MessageDigest.getInstance("SHA1");
        val byte[] result = mDigest.digest(input.getBytes());
        val sb = new StringBuffer();
        for (var i = 0; i < result.length; i++) {
            sb.append(Integer.toString(result.get(i).bitwiseAnd(0xff) + 0x100, 16).substring(1));
        }
         
        return sb.toString();
	}
	
}