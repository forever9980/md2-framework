package de.wwu.md2.framework.generator.mapapps

import de.wwu.md2.framework.generator.util.DataContainer
import de.wwu.md2.framework.mD2.CustomAction
import de.wwu.md2.framework.mD2.EventBindingTask
import de.wwu.md2.framework.mD2.EventUnbindTask
import de.wwu.md2.framework.mD2.ValidatorBindingTask
import de.wwu.md2.framework.mD2.ValidatorUnbindTask
import de.wwu.md2.framework.mD2.CallTask
import de.wwu.md2.framework.mD2.MappingTask
import de.wwu.md2.framework.mD2.UnmappingTask
import de.wwu.md2.framework.mD2.ConditionalCodeFragment
import de.wwu.md2.framework.mD2.ViewElementSetTask
import de.wwu.md2.framework.mD2.AttributeSetTask
import de.wwu.md2.framework.mD2.ContentProviderSetTask
import de.wwu.md2.framework.mD2.ActionDef
import de.wwu.md2.framework.mD2.ActionReference
import de.wwu.md2.framework.mD2.SimpleActionRef
import de.wwu.md2.framework.mD2.GotoViewAction
import de.wwu.md2.framework.mD2.DisableAction
import de.wwu.md2.framework.mD2.EnableAction
import de.wwu.md2.framework.mD2.DisplayMessageAction
import de.wwu.md2.framework.mD2.ContentProviderOperationAction
import de.wwu.md2.framework.mD2.ContentProviderResetAction

import de.wwu.md2.framework.generator.util.MD2GeneratorUtil
import static extension de.wwu.md2.framework.generator.util.MD2GeneratorUtil.*
import static extension de.wwu.md2.framework.util.StringExtensions.*
import static extension de.wwu.md2.framework.util.DateISOFormatter.*
import de.wwu.md2.framework.mD2.ContentProvider
import de.wwu.md2.framework.mD2.ViewElementEventRef
import de.wwu.md2.framework.mD2.ContentProviderEventRef
import de.wwu.md2.framework.mD2.GlobalEventRef
import de.wwu.md2.framework.mD2.ViewGUIElement
import de.wwu.md2.framework.mD2.AbstractContentProvider
import de.wwu.md2.framework.mD2.RegExValidator
import de.wwu.md2.framework.mD2.RegExValidatorParam
import de.wwu.md2.framework.mD2.ValidatorRegExParam
import de.wwu.md2.framework.mD2.StandardRegExValidator
import de.wwu.md2.framework.mD2.ValidatorMessageParam
import de.wwu.md2.framework.mD2.StandardDateTimeRangeValidator
import de.wwu.md2.framework.mD2.StandardTimeRangeValidator
import de.wwu.md2.framework.mD2.StandardDateRangeValidator
import de.wwu.md2.framework.mD2.StandardStringRangeValidator
import de.wwu.md2.framework.mD2.StandardNumberRangeValidator
import de.wwu.md2.framework.mD2.StandardNotNullValidator
import de.wwu.md2.framework.mD2.ValidatorMaxParam
import de.wwu.md2.framework.mD2.ValidatorMinParamimport de.wwu.md2.framework.mD2.ValidatorMinLengthParam
import de.wwu.md2.framework.mD2.ValidatorMaxLengthParam
import de.wwu.md2.framework.mD2.ValidatorMinDateParam
import de.wwu.md2.framework.mD2.ValidatorMaxDateParam
import de.wwu.md2.framework.mD2.ValidatorMinTimeParam
import de.wwu.md2.framework.mD2.ValidatorMaxTimeParam
import de.wwu.md2.framework.mD2.ValidatorMinDateTimeParam
import de.wwu.md2.framework.mD2.ValidatorMaxDateTimeParam
import de.wwu.md2.framework.mD2.RemoteValidator
import de.wwu.md2.framework.mD2.StandardValidatorType
import de.wwu.md2.framework.mD2.ValidatorType
import de.wwu.md2.framework.mD2.CustomizedValidatorType
import de.wwu.md2.framework.mD2.ConditionalExpression
import de.wwu.md2.framework.mD2.Or
import de.wwu.md2.framework.mD2.And
import de.wwu.md2.framework.mD2.Not
import de.wwu.md2.framework.mD2.CompareExpression
import de.wwu.md2.framework.mD2.Operator
import de.wwu.md2.framework.mD2.BooleanExpression
import de.wwu.md2.framework.mD2.GuiElementStateExpression
import de.wwu.md2.framework.mD2.SimpleExpression

class CustomActionClass {
	
	def static generateCustomAction(CustomAction customAction, DataContainer dataContainer) '''
		define([
			"dojo/_base/declare",
			"../../md2_runtime/actions/_Action"
		],
		function(declare, _Action) {
			
			return declare([_Action], {
				
				_actionSignature: "«customAction.name»",
				
				execute: function() {
					
					«FOR codeFragment : customAction.codeFragments»
						«generateCodeFragment(codeFragment)»
						
					«ENDFOR»
					
				}
				
			});
		});
	'''
	
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	// Custom Code Fragments
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	def private static dispatch generateCodeFragment(EventBindingTask task) '''
		«FOR event : task.events»
			«FOR action : task.actions»
				«generateEventBindingCodeFragment(event, action, true)»
			«ENDFOR»
		«ENDFOR»
	'''
	
	def private static dispatch generateCodeFragment(EventUnbindTask task) '''
		«FOR event : task.events»
			«FOR action : task.actions»
				«generateEventBindingCodeFragment(event, action, false)»
			«ENDFOR»
		«ENDFOR»
	'''
	
	def private static dispatch generateCodeFragment(ValidatorBindingTask task) '''
		«FOR validator : task.validators»
			«FOR field : task.referencedFields»
				«val validatorVar = getUnifiedName("validator")»
				«generateValidatorCodeFragment(validator, validatorVar)»
				«val widgetVar = getUnifiedName("widget")»
				«generateWidgetCodeFragment(resolveViewGUIElement(field), widgetVar)»
				«widgetVar».addValidator(«validatorVar»);
			«ENDFOR»
		«ENDFOR»
	'''
	
	def private static dispatch generateCodeFragment(ValidatorUnbindTask task) '''
		«FOR validator : task.validators»
			«FOR field : task.referencedFields»
				«val validatorVar = getUnifiedName("validator")»
				«generateValidatorCodeFragment(validator, validatorVar)»
				«val widgetVar = getUnifiedName("widget")»
				«generateWidgetCodeFragment(resolveViewGUIElement(field), widgetVar)»
				«widgetVar».removeValidator(«validatorVar»);
			«ENDFOR»
		«ENDFOR»
	'''
	
	def private static dispatch generateCodeFragment(CallTask task) '''
		«val actionVar = getUnifiedName("action")»
		«generateActionCodeFragment(task.action, actionVar)»
		«actionVar».execute();
	'''
	
	def private static dispatch generateCodeFragment(MappingTask task) '''
		«val contentProviderVar = getUnifiedName("contentProvider")»
		«generateContentProviderCodeFragment(task.pathDefinition, contentProviderVar)»
		«val widgetVar = getUnifiedName("widget")»
		«generateWidgetCodeFragment(resolveViewGUIElement(task.referencedViewField), widgetVar)»
		this.$.dataMapper.map(«widgetVar», «contentProviderVar», "«task.pathDefinition.resolveContentProviderPathAttribute»");
	'''
	
	def private static dispatch generateCodeFragment(UnmappingTask task) '''
		«val contentProviderVar = getUnifiedName("contentProvider")»
		«generateContentProviderCodeFragment(task.pathDefinition, contentProviderVar)»
		«val widgetVar = getUnifiedName("widget")»
		«generateWidgetCodeFragment(resolveViewGUIElement(task.referencedViewField), widgetVar)»
		this.$.dataMapper.unmap(«widgetVar», «contentProviderVar», "«task.pathDefinition.resolveContentProviderPathAttribute»");
	'''
	
	def private static dispatch generateCodeFragment(ConditionalCodeFragment task) '''
		if («generateCondition(task.^if.condition).trimParentheses») {
			«FOR codeFragment : task.^if.codeFragments»
				«generateCodeFragment(codeFragment)»
				
			«ENDFOR»
		}
		«FOR elseif : task.elseifs»
			else if («generateCondition(elseif.condition).trimParentheses») {
				«FOR codeFragment : elseif.codeFragments»
					«generateCodeFragment(codeFragment)»
					
				«ENDFOR»
			}
		«ENDFOR»
		«IF task.^else != null»
			else {
				«FOR codeFragment : task.^else.codeFragments»
					«generateCodeFragment(codeFragment)»
					
				«ENDFOR»
			}
		«ENDIF»
	'''
	
	def private static dispatch generateCodeFragment(ViewElementSetTask task) '''
		
	'''
	
	def private static dispatch generateCodeFragment(AttributeSetTask task) '''
		
	'''
	
	def private static dispatch generateCodeFragment(ContentProviderSetTask task) '''
		
	'''
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	// Action
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	def private static dispatch generateActionCodeFragment(ActionDef actionDefinition, String varName) {
		switch (actionDefinition) {
			ActionReference: {
				generateActionCodeFragment(actionDefinition.actionRef, varName)
			}
			SimpleActionRef: {
				generateActionCodeFragment(actionDefinition.action, varName)
			}
		}
	}
	
	def private static dispatch generateActionCodeFragment(CustomAction action, String varName) '''
		var «varName» = this.$.actionFactory.getCustomAction("«action.name»");
	'''
	
	def private static dispatch generateActionCodeFragment(GotoViewAction action, String varName) '''
		var «varName» = this.$.actionFactory.getGotoViewAction("«getName(resolveViewGUIElement(action.view))»");
	'''
	
	def private static dispatch generateActionCodeFragment(DisableAction action, String varName) '''
		var «varName» = this.$.actionFactory.getDisableAction("«getName(resolveViewGUIElement(action.inputField))»");
	'''
	
	def private static dispatch generateActionCodeFragment(EnableAction action, String varName) '''
		var «varName» = this.$.actionFactory.getEnableAction("«getName(resolveViewGUIElement(action.inputField))»");
	'''
	
	def private static dispatch generateActionCodeFragment(DisplayMessageAction action, String varName) '''
		var «varName» = this.$.actionFactory.getDisplayMessageAction("«action.message»");
	'''
	
	def private static dispatch generateActionCodeFragment(ContentProviderOperationAction action, String varName) '''
		«val contentProviderVar = getUnifiedName("contentProvider")»
		«generateContentProviderCodeFragment(action.contentProvider.contentProvider, contentProviderVar)»
		var «varName» = this.$.actionFactory.getContentProviderOperationAction(«contentProviderVar», "«action.operation.toString»");
	'''
	
	def private static dispatch generateActionCodeFragment(ContentProviderResetAction action, String varName) '''
		«val contentProviderVar = getUnifiedName("contentProvider")»
		«generateContentProviderCodeFragment(action.contentProvider.contentProvider, contentProviderVar)»
		var «varName» = this.$.actionFactory.getContentProviderResetAction(«contentProviderVar»);
	'''
	
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	// Event
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	def private static dispatch generateEventBindingCodeFragment(ViewElementEventRef event, ActionDef actionDefinition, boolean isBinding) '''
		«val widgetVar = getUnifiedName("widget")»
		«generateWidgetCodeFragment(resolveViewGUIElement(event.referencedField), widgetVar)»
		«val actionVar = getUnifiedName("action")»
		«generateActionCodeFragment(actionDefinition, actionVar)»
		this.$.eventRegistry.get("widget/«event.event.toString»").«IF !isBinding»un«ENDIF»registerAction(«widgetVar», «actionVar»);
	'''
	
	def private static dispatch generateEventBindingCodeFragment(ContentProviderEventRef event, ActionDef actionDefinition, boolean isBinding) '''
		«val contentProviderVar = getUnifiedName("contentProvider")»
		«generateContentProviderCodeFragment(event.pathDefinition, contentProviderVar)»
		«val actionVar = getUnifiedName("action")»
		«generateActionCodeFragment(actionDefinition, actionVar)»
		this.$.eventRegistry.get("widget/«event.event.toString»").«IF !isBinding»un«ENDIF»registerAction(«contentProviderVar», "«event.pathDefinition.resolveContentProviderPathAttribute»", «actionVar»);
	'''
	
	def private static dispatch generateEventBindingCodeFragment(GlobalEventRef event, ActionDef actionDefinition, boolean isBinding) '''
		«val actionVar = getUnifiedName("action")»
		«generateActionCodeFragment(actionDefinition, actionVar)»
		this.$.eventRegistry.get("global/«event.event.toString»").«IF !isBinding»un«ENDIF»registerAction(«actionVar»);
	'''
	
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	// Content Provider
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	def private static dispatch generateContentProviderCodeFragment(ContentProvider contentProvider, String varName) '''
		var «varName» = this.$.contentProviderRegistry.getContentProvider("«contentProvider.name»");
	'''
	
	def private static dispatch generateContentProviderCodeFragment(AbstractContentProvider contentProvider, String varName) '''
		var «varName» = this.$.contentProviderRegistry.getContentProvider("«contentProvider.resolveContentProviderName»");
	'''
	
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	// Widget
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	def private static generateWidgetCodeFragment(ViewGUIElement guiElement, String varName) '''
		var «varName» = this.$.widgetRegistry.getWidget("«getName(guiElement)»");
	'''
	
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	// Validator
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	def private static dispatch generateValidatorCodeFragment(ValidatorType validator, String varName) {
		switch (validator) {
			StandardValidatorType: {
				generateValidatorCodeFragment(validator.validator, varName)
			}
			CustomizedValidatorType: {
				generateValidatorCodeFragment(validator.validator, varName)
			}
		}
	}
	
	def private static dispatch generateValidatorCodeFragment(StandardRegExValidator validator, String varName) {
		val regEx = validator.resolveValidatorParam(typeof(ValidatorRegExParam))?.regEx ?: ".*"
		val message = validator.resolveValidatorParam(typeof(ValidatorMessageParam))?.message
		'''
			var «varName» = this.$.validatorFactory.getRegExValidator("«regEx»"«IF message != null», "«message»"«ENDIF»);
		'''
	}
	
	def private static dispatch generateValidatorCodeFragment(StandardNotNullValidator validator, String varName) {
		val message = validator.resolveValidatorParam(typeof(ValidatorMessageParam))?.message
		'''
			var «varName» = this.$.validatorFactory.getNotNullValidator(«IF message != null»"«message»"«ENDIF»);
		'''
	}
	
	def private static dispatch generateValidatorCodeFragment(StandardNumberRangeValidator validator, String varName) {
		val min = validator.resolveValidatorParam(typeof(ValidatorMinParam))?.min.toString ?: "null"
		val max = validator.resolveValidatorParam(typeof(ValidatorMaxParam))?.max.toString ?: "null"
		val message = validator.resolveValidatorParam(typeof(ValidatorMessageParam))?.message.quotify
		'''
			var «varName» = this.$.validatorFactory.getNumberRangeValidator(«min», «max»«IF message != null», "«message»"«ENDIF»);
		'''
	}
	
	def private static dispatch generateValidatorCodeFragment(StandardStringRangeValidator validator, String varName) {
		val min = validator.resolveValidatorParam(typeof(ValidatorMinLengthParam))?.minLength.toString ?: "null"
		val max = validator.resolveValidatorParam(typeof(ValidatorMaxLengthParam))?.maxLength.toString ?: "null"
		val message = validator.resolveValidatorParam(typeof(ValidatorMessageParam))?.message.quotify
		'''
			var «varName» = this.$.validatorFactory.getStringRangeValidator(«min», «max»«IF message != null», "«message»"«ENDIF»);
		'''
	}
	
	def private static dispatch generateValidatorCodeFragment(StandardDateRangeValidator validator, String varName) {
		val min = validator.resolveValidatorParam(typeof(ValidatorMinDateParam))?.min.toISODate.quotify ?: "null"
		val max = validator.resolveValidatorParam(typeof(ValidatorMaxDateParam))?.max.toISODate.quotify ?: "null"
		val message = validator.resolveValidatorParam(typeof(ValidatorMessageParam))?.message.quotify
		'''
			var «varName» = this.$.validatorFactory.getDateRangeValidator(«min», «max»«IF message != null», "«message»"«ENDIF»);
		'''
	}
	
	def private static dispatch generateValidatorCodeFragment(StandardTimeRangeValidator validator, String varName) {
		val min = validator.resolveValidatorParam(typeof(ValidatorMinTimeParam))?.min.toISOTime.quotify ?: "null"
		val max = validator.resolveValidatorParam(typeof(ValidatorMaxTimeParam))?.max.toISODate.quotify ?: "null"
		val message = validator.resolveValidatorParam(typeof(ValidatorMessageParam))?.message.quotify
		'''
			var «varName» = this.$.validatorFactory.getTimeRangeValidator(«min», «max»«IF message != null», "«message»"«ENDIF»);
		'''
	}
	
	def private static dispatch generateValidatorCodeFragment(StandardDateTimeRangeValidator validator, String varName) {
		val min = validator.resolveValidatorParam(typeof(ValidatorMinDateTimeParam))?.min.toISODateTime.quotify ?: "null"
		val max = validator.resolveValidatorParam(typeof(ValidatorMaxDateTimeParam))?.max.toISODateTime.quotify ?: "null"
		val message = validator.resolveValidatorParam(typeof(ValidatorMessageParam))?.message.quotify
		'''
			var «varName» = this.$.validatorFactory.getDateTimeRangeValidator(«min», «max»«IF message != null», "«message»"«ENDIF»);
		'''
	}
	
	def private static dispatch generateValidatorCodeFragment(RemoteValidator validator, String varName) '''
		// TODO
	'''
	
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	// Conditional Expressions
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	def private static String generateCondition(ConditionalExpression expression) {
		switch (expression) {
			Or: '''(«generateCondition(expression.leftExpression)» || «generateCondition(expression.rightExpression)»)'''
			And: '''«generateCondition(expression.leftExpression)» && «generateCondition(expression.rightExpression)»'''
			Not: '''!(«generateCondition(expression.expression).trimParentheses»)'''
			BooleanExpression: '''«expression.value.toString»'''
			CompareExpression: {
				val operator = switch expression.op {
					case Operator::EQUALS: "==="
					case Operator::GREATER: ">"
					case Operator::SMALLER: "<"
					case Operator::GREATER_OR_EQUAL: ">="
					case Operator::SMALLER_OR_EQUAL: "<="
				}
				'''«generateSimpleExpression(expression.eqLeft)» «operator» «generateSimpleExpression(expression.eqRight)»'''
			}
			GuiElementStateExpression: '''<StateExpr>'''
		}
	}
	
	def private static generateSimpleExpression(SimpleExpression expression) {
		'''<SimpleExpr>'''
	}
	
}
