package de.wwu.md2.framework.generator.ios.controller

import de.wwu.md2.framework.mD2.ValidatorType
import de.wwu.md2.framework.mD2.StandardDateTimeRangeValidator
import de.wwu.md2.framework.mD2.StandardTimeRangeValidator
import de.wwu.md2.framework.mD2.StandardDateRangeValidator
import de.wwu.md2.framework.mD2.StandardStringRangeValidator
import de.wwu.md2.framework.mD2.StandardNumberRangeValidator
import de.wwu.md2.framework.mD2.StandardRegExValidator
import de.wwu.md2.framework.mD2.StandardNotNullValidator
import de.wwu.md2.framework.mD2.ValidatorMessageParam
import de.wwu.md2.framework.generator.ios.util.SimpleExpressionUtil
import de.wwu.md2.framework.mD2.ValidatorRegExParam
import de.wwu.md2.framework.mD2.ValidatorMinParam
import de.wwu.md2.framework.mD2.ValidatorMaxParam
import de.wwu.md2.framework.mD2.ValidatorMaxLengthParam
import de.wwu.md2.framework.mD2.ValidatorMinLengthParam
import de.wwu.md2.framework.mD2.ValidatorMaxDateParam
import de.wwu.md2.framework.mD2.ValidatorMinDateParam
import de.wwu.md2.framework.mD2.ValidatorMinDateTimeParam
import de.wwu.md2.framework.mD2.ValidatorMaxDateTimeParam
import de.wwu.md2.framework.mD2.ValidatorMaxTimeParam
import de.wwu.md2.framework.mD2.ValidatorMinTimeParam
import de.wwu.md2.framework.generator.ios.util.IOSGeneratorUtil

/**
 * Generate validator declarations.
 */
class IOSValidator {
	
	/**
	 * Generates a validator declaration.
	 * 
	 * @param identifier The unique identifier of the validator instance.
	 * @param validator The validator element to create.
	 * @return The Swift code to declare a validator instance. 
	 */
	def static generateValidator(String identifier, ValidatorType validator){
		// MARK incomplete list (remoteValidator) to be extended in future version
		switch validator {
			StandardNotNullValidator: return generateStandardNotNullValidator(identifier, validator as StandardNotNullValidator)
			StandardRegExValidator: return generateStandardRegExValidator(identifier, validator as StandardRegExValidator)
			StandardNumberRangeValidator: return generateStandardNumberRangeValidator(identifier, validator as StandardNumberRangeValidator)
			StandardStringRangeValidator: return generateStandardStringRangeValidator(identifier, validator as StandardStringRangeValidator)
			StandardDateRangeValidator: return generateStandardDateRangeValidator(identifier, validator as StandardDateRangeValidator)
			StandardTimeRangeValidator: return generateStandardTimeRangeValidator(identifier, validator as StandardTimeRangeValidator)
			StandardDateTimeRangeValidator: return generateStandardDateTimeRangeValidator(identifier, validator as StandardDateTimeRangeValidator)
			default: {
				IOSGeneratorUtil.printError("IOSValidator encountered unsupported validator type: " + validator)	
				return ""
			}
		}
	}
	
	/**
	 * Template to generate a not-null validator declaration.
	 * 
	 * @param identifier The unique identifier of the validator instance.
	 * @param validator The validator element to create.
	 * @return The Swift code to declare a validator instance. 
	 */
	def static generateStandardNotNullValidator(String identifier, StandardNotNullValidator validator) '''
		MD2NotNullValidator(«identifier»
		«IF validator.params.filter(ValidatorMessageParam).length > 0»
			, message: { return «SimpleExpressionUtil.getStringValue(validator.params.filter(ValidatorMessageParam).get(0).message)» }
		«ELSE»
			, message: { return defaultMessage }
		«ENDIF»
		)
	'''
	
	/**
	 * Template to generate a regex validator declaration.
	 * 
	 * @param identifier The unique identifier of the validator instance.
	 * @param validator The validator element to create.
	 * @return The Swift code to declare a validator instance. 
	 */
	def static generateStandardRegExValidator(String identifier, StandardRegExValidator validator) '''
		MD2RegExValidator(«identifier»
		«IF validator.params.filter(ValidatorMessageParam).length > 0»
			, message: { return «SimpleExpressionUtil.getStringValue(validator.params.filter(ValidatorMessageParam).get(0).message)» }
		«ELSE»
			, message: { return defaultMessage }
		«ENDIF»
		«IF validator.params.filter(ValidatorRegExParam).length > 0»
			, regEx: "«validator.params.filter(ValidatorRegExParam).get(0).regEx»"
		«ELSE»
			, regEx: ""
		«ENDIF»
		)
	'''
	
	/**
	 * Template to generate a number range validator declaration.
	 * 
	 * @param identifier The unique identifier of the validator instance.
	 * @param validator The validator element to create.
	 * @return The Swift code to declare a validator instance. 
	 */
	def static generateStandardNumberRangeValidator(String identifier, StandardNumberRangeValidator validator) '''
		MD2NumberRangeValidator(«identifier»
		«IF validator.params.filter(ValidatorMessageParam).length > 0»
			, message: { return «SimpleExpressionUtil.getStringValue(validator.params.filter(ValidatorMessageParam).get(0).message)» }
		«ELSE»
			, message: { return defaultMessage }
		«ENDIF»
		«IF validator.params.filter(ValidatorMinParam).length > 0»
			, min: MD2Float(«validator.params.filter(ValidatorMinParam).get(0).min»)
		«ELSE»
			, min: MD2Float()
		«ENDIF»
		«IF validator.params.filter(ValidatorMaxParam).length > 0»
			, max: MD2Float(«validator.params.filter(ValidatorMaxParam).get(0).max»
		«ELSE»
			, max: MD2Float()
		«ENDIF»
		)
	'''
	
	/**
	 * Template to generate a string range validator declaration.
	 * 
	 * @param identifier The unique identifier of the validator instance.
	 * @param validator The validator element to create.
	 * @return The Swift code to declare a validator instance. 
	 */
	def static generateStandardStringRangeValidator(String identifier, StandardStringRangeValidator validator) '''
		MD2StringRangeValidator(«identifier»
		«IF validator.params.filter(ValidatorMessageParam).length > 0»
			, message: { return «SimpleExpressionUtil.getStringValue(validator.params.filter(ValidatorMessageParam).get(0).message)» }
		«ELSE»
			, message: { return defaultMessage }
		«ENDIF»
		«IF validator.params.filter(ValidatorMinLengthParam).length > 0»
			, min: MD2Integer(«validator.params.filter(ValidatorMinLengthParam).get(0).minLength»)
		«ELSE»
			, min: MD2Integer(0)
		«ENDIF»
		«IF validator.params.filter(ValidatorMaxLengthParam).length > 0»
			, max: MD2Integer(«validator.params.filter(ValidatorMaxLengthParam).get(0).maxLength»
		«ELSE»
			, max: MD2Integer()
		«ENDIF»
		)
	'''
	
	/**
	 * Template to generate a date range validator declaration.
	 * 
	 * @param identifier The unique identifier of the validator instance.
	 * @param validator The validator element to create.
	 * @return The Swift code to declare a validator instance. 
	 */
	def static generateStandardDateRangeValidator(String identifier, StandardDateRangeValidator validator) '''
		MD2DateRangeValidator(«identifier»
		«IF validator.params.filter(ValidatorMessageParam).length > 0»
			, message: { return «SimpleExpressionUtil.getStringValue(validator.params.filter(ValidatorMessageParam).get(0).message)» }
		«ELSE»
			, message: { return defaultMessage }
		«ENDIF»
		«IF validator.params.filter(ValidatorMinDateParam).length > 0»
			, min: MD2Date(«validator.params.filter(ValidatorMinDateParam).get(0).min»)
		«ELSE»
			, min: MD2Date()
		«ENDIF»
		«IF validator.params.filter(ValidatorMaxDateParam).length > 0»
			, max: MD2Date(«validator.params.filter(ValidatorMaxDateParam).get(0).max»
		«ELSE»
			, max: MD2Date()
		«ENDIF»
		)
	'''
	
	/**
	 * Template to generate a time range validator declaration.
	 * 
	 * @param identifier The unique identifier of the validator instance.
	 * @param validator The validator element to create.
	 * @return The Swift code to declare a validator instance. 
	 */
	def static generateStandardTimeRangeValidator(String identifier, StandardTimeRangeValidator validator) '''
		MD2TimeRangeValidator(«identifier»
		«IF validator.params.filter(ValidatorMessageParam).length > 0»
			, message: { return «SimpleExpressionUtil.getStringValue(validator.params.filter(ValidatorMessageParam).get(0).message)» }
		«ELSE»
			, message: { return defaultMessage }
		«ENDIF»
		«IF validator.params.filter(ValidatorMinTimeParam).length > 0»
			, min: MD2Time(«validator.params.filter(ValidatorMinTimeParam).get(0).min»)
		«ELSE»
			, min: MD2Time()
		«ENDIF»
		«IF validator.params.filter(ValidatorMaxTimeParam).length > 0»
			, max: MD2Time(«validator.params.filter(ValidatorMaxTimeParam).get(0).max»
		«ELSE»
			, max: MD2Time()
		«ENDIF»
		)
	'''
	
	/**
	 * Template to generate a datetime range validator declaration.
	 * 
	 * @param identifier The unique identifier of the validator instance.
	 * @param validator The validator element to create.
	 * @return The Swift code to declare a validator instance. 
	 */
	def static generateStandardDateTimeRangeValidator(String identifier, StandardDateTimeRangeValidator validator) '''
		MD2DateTimeRangeValidator(«identifier»
		«IF validator.params.filter(ValidatorMessageParam).length > 0»
			, message: { return «SimpleExpressionUtil.getStringValue(validator.params.filter(ValidatorMessageParam).get(0).message)» }
		«ELSE»
			, message: { return defaultMessage }
		«ENDIF»
		«IF validator.params.filter(ValidatorMinDateTimeParam).length > 0»
			, min: MD2DateTime(«validator.params.filter(ValidatorMinDateTimeParam).get(0).min»)
		«ELSE»
			, min: MD2DateTime()
		«ENDIF»
		«IF validator.params.filter(ValidatorMaxDateTimeParam).length > 0»
			, max: MD2DateTime(«validator.params.filter(ValidatorMaxDateTimeParam).get(0).max»
		«ELSE»
			, max: MD2DateTime()
		«ENDIF»
		)
	'''
}